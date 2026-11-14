class Anode < Formula
  desc "Proof-of-Topology Bare-Metal Orchestrator for Unmodified Go Backends"
  homepage "https://anode.abhiudayg.dev"
  version "1.1.1"
  license "MIT"
  head "https://github.com/abhiudayg/anode.git", branch: "master"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/abhiudayg/anode/releases/download/v1.1.1/anode_darwin_arm64.tar.gz"
      sha256 "37750ebf7165e46d37d3e28088d607d0d7ccafaf7c2db2efda2d5ceace63ff1d"
    else
      url "https://github.com/abhiudayg/anode/releases/download/v1.1.1/anode_darwin_amd64.tar.gz"
      sha256 "a99f148f5b0d30e87ae5d84cfd1494ed6657c2ec0f85163442184acbb3a01c68"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/abhiudayg/anode/releases/download/v1.1.1/anode_linux_arm64.tar.gz"
      sha256 "90ff5837d9792c92ff4dacf4fb2e637995b8f5254b52da5400c3533233d4ae1b"
    else
      url "https://github.com/abhiudayg/anode/releases/download/v1.1.1/anode_linux_amd64.tar.gz"
      sha256 "d7c398525352b9403b7da423d5afecf7500807450941db7048260404cf27d474"
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
