class Anode < Formula
  desc "Proof-of-Topology Bare-Metal Orchestrator for Unmodified Go Backends"
  homepage "https://anode.abhiudayg.dev"
  version "1.6.0"
  license "MIT"
  head "https://github.com/abhiudayg/anode.git", branch: "master"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/abhiudayg/anode/releases/download/v1.6.0/anode_darwin_arm64.tar.gz"
      sha256 "f237226631589d346598f5dc822be93e558b5fc19eb8ede71d3b14465580e2b0"
    else
      url "https://github.com/abhiudayg/anode/releases/download/v1.6.0/anode_darwin_amd64.tar.gz"
      sha256 "3a37b0d77b60019edf0d7b7aa89443a2c9e1bd78bcc9b781487376479c1e8a2b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/abhiudayg/anode/releases/download/v1.6.0/anode_linux_arm64.tar.gz"
      sha256 "9962b52b34b8e02b02681b18ceafb192ab543aafd84ba05c0748f930c215860e"
    else
      url "https://github.com/abhiudayg/anode/releases/download/v1.6.0/anode_linux_amd64.tar.gz"
      sha256 "dd830ec359a9f5de263d84b585ee9568d3f3d1572816e188ecddc84edc332e04"
    end
  end

  depends_on "go" => :build if build.head?

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
