# Homebrew Tap for Abhiuday's Tools (`abhiudayg/tap`)

This is the common Homebrew tap repository for all CLI applications and developer tools built by [Abhiuday](https://github.com/abhiudayg).

## How to Install Tools

### 1. Anode — Bare-Metal Go Orchestration Engine
Deploy unmodified Go backends to Linux VPS without Dockerfiles or Kubernetes.

```bash
# Add the tap
brew tap abhiudayg/tap

# Install Anode
brew install anode

# Or install in a single command
brew install abhiudayg/tap/anode
```

To install the latest development build from `main`:
```bash
brew install --HEAD abhiudayg/tap/anode
```

## Available Formulas

| Formula | Description | Install Command |
|---|---|---|
| [`anode`](Formula/anode.rb) | Bare-metal Go orchestration engine & 4-Pillar Proof of Topology | `brew install abhiudayg/tap/anode` |

## Updating

```bash
brew update
brew upgrade anode
```

---

## Automated Daily Release Bumper

This repository runs an automated GitHub Actions workflow daily (`.github/workflows/update-formulae.yml`) that checks upstream GitHub releases for each formula in [`formulae.json`](formulae.json), parses release checksums (`checksums.txt` or calculates SHA-256 for binaries), bumps the version in `Formula/*.rb`, and commits the updates.

### Adding a New Formula

To register a new tool in the tap:
1. Create `Formula/<name>.rb`.
2. Add an entry to [`formulae.json`](formulae.json):
   ```json
   {
     "name": "my-tool",
     "repo": "abhiudayg/my-tool",
     "formula": "Formula/my-tool.rb",
     "description": "Description of the tool"
   }
   ```
3. Test locally:
   ```bash
   python3 scripts/update-formulae.py
   ```
