class Anode < Formula
  desc "Proof-of-Topology Bare-Metal Orchestrator for Unmodified Go Backends"
  homepage "https://anode.abhiudayg.dev"
  version "1.1.2"
  license "MIT"
  head "https://github.com/abhiudayg/anode.git", branch: "master"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/abhiudayg/anode/releases/download/v1.1.2/anode_darwin_arm64.tar.gz"
      sha256 "43679b91ccfe844502dd50eb8b1f36af10af76c2fc5ba8375add52188232393e"
    else
      url "https://github.com/abhiudayg/anode/releases/download/v1.1.2/anode_darwin_amd64.tar.gz"
      sha256 "38e5e2b68d86a8a87b4e5338a2ecef336da0036b8366c7a19d5e3a6a6a84b244"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/abhiudayg/anode/releases/download/v1.1.2/anode_linux_arm64.tar.gz"
      sha256 "e1cb82a014e1a6dbb84a9b525711df94245829f539e43c8cc28202d63e18cf0a"
    else
      url "https://github.com/abhiudayg/anode/releases/download/v1.1.2/anode_linux_amd64.tar.gz"
      sha256 "a299d9996008e74ba2ce175eae7b71cc39a6b5aa148503289ca5a08045f0b2ec"
    end
  end

  head do
    depends_on "go" => :build
  end

  def install
    if build.head?
      system "go", "build", *std_go_args(ldflags: "-s -w -X main.Version=head"), "./cmd/anode"
    else
      bin.install "anode"
    end
  end

  test do
    output = shell_output("#{bin}/anode version")
    assert_match "anode version", output
  end
end
