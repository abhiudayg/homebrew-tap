class Anode < Formula
  desc "Proof-of-Topology Bare-Metal Orchestrator for Unmodified Go Backends"
  homepage "https://anode.abhiudayg.dev"
  version "1.1.0"
  license "MIT"
  head "https://github.com/abhiudayg/anode.git", branch: "master"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/abhiudayg/anode/releases/download/v1.1.0/anode_darwin_arm64.tar.gz"
      sha256 "2fdc5dfca612d276f155d2aadb68111794d8359f336ab54576023caf10d49eed"
    else
      url "https://github.com/abhiudayg/anode/releases/download/v1.1.0/anode_darwin_amd64.tar.gz"
      sha256 "6182926222a3cfd957ea67b1e14ad05c9f88fca542241e036e2a0c460ea331ef"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/abhiudayg/anode/releases/download/v1.1.0/anode_linux_arm64.tar.gz"
      sha256 "2551d29bcf5fec6e77e9411b20813ac34c97f0301e0eba9cfa968d9262500f8c"
    else
      url "https://github.com/abhiudayg/anode/releases/download/v1.1.0/anode_linux_amd64.tar.gz"
      sha256 "672c555c7e74f9b2ae1d86c454a96fa36bd40b69ae6e2ea7a8a054333dcfa92a"
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
