class Anode < Formula
  desc "Proof-of-Topology Bare-Metal Orchestrator for Unmodified Go Backends"
  homepage "https://anode.abhiudayg.dev"
  version "1.2.0"
  license "MIT"
  head "https://github.com/abhiudayg/anode.git", branch: "master"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/abhiudayg/anode/releases/download/v1.2.0/anode_darwin_arm64.tar.gz"
      sha256 "b5c2d47fc94993d459393023952a101c4a2c42308cfc594160b35df2bc532141"
    else
      url "https://github.com/abhiudayg/anode/releases/download/v1.2.0/anode_darwin_amd64.tar.gz"
      sha256 "2e6c73df59a9ed3517ddd593e087e978e7d723cb7271654ce17201bfc0563e7c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/abhiudayg/anode/releases/download/v1.2.0/anode_linux_arm64.tar.gz"
      sha256 "3ce72bad36aea254daa8fbae6427fbc4c68592d660dc2e6bba8e6bff77d226c6"
    else
      url "https://github.com/abhiudayg/anode/releases/download/v1.2.0/anode_linux_amd64.tar.gz"
      sha256 "70f9248c2f4f6af56e6c06349a3b303b2c0a8f3deaabf8790d743d372678f4ea"
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
