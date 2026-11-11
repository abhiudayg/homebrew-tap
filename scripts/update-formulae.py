#!/usr/bin/env python3
"""
Automated Homebrew Formulae Version Bumper
Checks upstream GitHub releases for registered formulae, fetches SHA-256 checksums,
and updates formula files automatically.
"""

import os
import sys
import json
import re
import urllib.request
import urllib.error
import hashlib
from typing import Dict, Optional, List, Tuple


def get_github_token() -> Optional[str]:
    return os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")


def fetch_json(url: str) -> dict:
    req = urllib.request.Request(url)
    req.add_header("Accept", "application/vnd.github.v3+json")
    req.add_header("User-Agent", "Homebrew-Tap-Updater/1.0")
    token = get_github_token()
    if token:
        req.add_header("Authorization", f"Bearer {token}")

    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def download_bytes(url: str) -> bytes:
    req = urllib.request.Request(url)
    req.add_header("User-Agent", "Homebrew-Tap-Updater/1.0")
    token = get_github_token()
    if token and "api.github.com" in url:
        req.add_header("Authorization", f"Bearer {token}")

    with urllib.request.urlopen(req, timeout=60) as resp:
        return resp.read()


def calculate_sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def get_latest_release(repo: str) -> dict:
    url = f"https://api.github.com/repos/{repo}/releases/latest"
    return fetch_json(url)


def parse_checksums_txt(content: str) -> Dict[str, str]:
    """Parse standard sha256 checksums file: '<sha256>  <filename>'."""
    checksums = {}
    for line in content.strip().splitlines():
        parts = line.strip().split()
        if len(parts) >= 2:
            sha, filename = parts[0], parts[1].lstrip("*./")
            # Strip path prefix if any
            filename = os.path.basename(filename)
            checksums[filename] = sha
    return checksums


def update_formula_content(content: str, repo: str, new_tag: str, new_version: str, checksums: Dict[str, str], release_assets: List[dict]) -> Tuple[str, bool]:
    modified = False

    # 1. Update version "X.Y.Z"
    version_pattern = r'(version\s+)"([^"]+)"'
    match = re.search(version_pattern, content)
    if match and match.group(2) != new_version:
        content = re.sub(version_pattern, rf'\g<1>"{new_version}"', content, count=1)
        modified = True

    # 2. Update release download URLs and their subsequent sha256
    # Pattern: url "https://github.com/<repo>/releases/download/<old_tag>/<asset>"
    # followed by sha256 "<hash>"
    def replace_release_url(m):
        nonlocal modified
        full_prefix = m.group(1) # url "https://github.com/.../download/
        old_tag = m.group(2)
        asset_name = m.group(3)
        old_sha = m.group(4)

        new_url_block = f'{full_prefix}{new_tag}/{asset_name}"'

        # Find checksum for this asset
        sha = checksums.get(asset_name)
        if not sha:
            # Look up asset download URL
            for a in release_assets:
                if a.get("name") == asset_name:
                    print(f"      Downloading asset {asset_name} to compute SHA-256...")
                    data = download_bytes(a["browser_download_url"])
                    sha = calculate_sha256(data)
                    checksums[asset_name] = sha
                    break

        if sha:
            if sha != old_sha or old_tag != new_tag:
                modified = True
            return f'{new_url_block}\n      sha256 "{sha}"'
        else:
            print(f"⚠️ Warning: Could not resolve checksum for asset {asset_name}")
            return m.group(0)

    url_asset_pattern = re.compile(
        rf'(url\s+"https://github\.com/{re.escape(repo)}/releases/download/)([^/]+)/([^"]+)"\s*\n\s*sha256\s+"([a-fA-F0-9]{{64}})"',
        re.MULTILINE
    )
    content = url_asset_pattern.sub(replace_release_url, content)

    # 3. Update source tarball URLs: https://github.com/<repo>/archive/refs/tags/<old_tag>.tar.gz
    def replace_archive_url(m):
        nonlocal modified
        full_prefix = m.group(1)
        old_tag = m.group(2)
        old_sha = m.group(3)

        new_archive_url = f'{full_prefix}{new_tag}.tar.gz"'
        download_url = f"https://github.com/{repo}/archive/refs/tags/{new_tag}.tar.gz"
        print(f"      Downloading source archive {new_tag}.tar.gz to compute SHA-256...")
        data = download_bytes(download_url)
        sha = calculate_sha256(data)

        if sha != old_sha or old_tag != new_tag:
            modified = True
        return f'{new_archive_url}\n  sha256 "{sha}"'

    archive_pattern = re.compile(
        rf'(url\s+"https://github\.com/{re.escape(repo)}/archive/refs/tags/)([^/]+)\.tar\.gz"\s*\n\s*sha256\s+"([a-fA-F0-9]{{64}})"',
        re.MULTILINE
    )
    content = archive_pattern.sub(replace_archive_url, content)

    return content, modified


def process_formula(item: dict, base_dir: str) -> bool:
    name = item["name"]
    repo = item["repo"]
    formula_path = os.path.join(base_dir, item.get("formula", f"Formula/{name}.rb"))

    if not os.path.isfile(formula_path):
        print(f"❌ Formula file not found: {formula_path}")
        return False

    with open(formula_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Extract current version
    current_ver_match = re.search(r'version\s+"([^"]+)"', content)
    current_version = current_ver_match.group(1) if current_ver_match else "unknown"

    print(f"\n📦 Checking {name} ({repo})...")
    print(f"   Current formula version: {current_version}")

    try:
        release = get_latest_release(repo)
    except Exception as e:
        print(f"   ❌ Error fetching release for {repo}: {e}")
        return False

    tag_name = release.get("tag_name", "")
    new_version = tag_name.lstrip("v")
    print(f"   Latest GitHub release : {tag_name} (v{new_version})")

    if current_version == new_version:
        print(f"   ✓ {name} is already up to date ({current_version}).")
        return False

    print(f"   🚀 Upgrading {name}: {current_version} -> {new_version}...")

    # Check for checksums.txt asset
    checksums = {}
    assets = release.get("assets", [])
    for a in assets:
        if a.get("name") in ("checksums.txt", "SHA256SUMS", "checksums.sha256"):
            print(f"   Found {a['name']}, downloading...")
            raw = download_bytes(a["browser_download_url"]).decode("utf-8")
            checksums = parse_checksums_txt(raw)
            print(f"   Parsed {len(checksums)} checksums from {a['name']}")
            break

    new_content, modified = update_formula_content(
        content=content,
        repo=repo,
        new_tag=tag_name,
        new_version=new_version,
        checksums=checksums,
        release_assets=assets
    )

    if modified:
        with open(formula_path, "w", encoding="utf-8") as f:
            f.write(new_content)
        print(f"   ✅ Successfully updated {formula_path} to {new_version}!")
        return True
    else:
        print(f"   ℹ No content changes generated for {name}.")
        return False


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    tap_root = os.path.abspath(os.path.join(script_dir, ".."))
    manifest_path = os.path.join(tap_root, "formulae.json")

    if not os.path.isfile(manifest_path):
        print(f"❌ Manifest not found: {manifest_path}")
        sys.exit(1)

    with open(manifest_path, "r", encoding="utf-8") as f:
        formulae = json.load(f)

    updated_count = 0
    for item in formulae:
        if process_formula(item, tap_root):
            updated_count += 1

    print("\n--------------------------------------------------")
    print(f"Finished. Total formulae updated: {updated_count}")
    print("--------------------------------------------------")

    if updated_count > 0:
        # Exit with 0 to allow GitHub Actions to commit
        sys.exit(0)


if __name__ == "__main__":
    main()
