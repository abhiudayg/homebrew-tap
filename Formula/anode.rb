class Anode < Formula
  desc "Proof-of-Topology Bare-Metal Orchestrator for Unmodified Go Backends"
  homepage "https://anode.abhiudayg.dev"
  version "1.5.0"
  license "MIT"
  head "https://github.com/abhiudayg/anode.git", branch: "master"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/abhiudayg/anode/releases/download/v1.5.0/anode_darwin_arm64.tar.gz"
      sha256 "642d2c01ed37adfbf876b5e5f2880469694229709195e170f2a903867534f60f"
    else
      url "https://github.com/abhiudayg/anode/releases/download/v1.5.0/anode_darwin_amd64.tar.gz"
      sha256 "baff95a2bdd6f55fcde06afcb10a1eca023f0196e17d999ea7223ad602f9a085"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/abhiudayg/anode/releases/download/v1.5.0/anode_linux_arm64.tar.gz"
      sha256 "59dff9b0e258c1ade4036b33e460abfe629938df32390b3cb9d5aacdf68cbf41"
    else
      url "https://github.com/abhiudayg/anode/releases/download/v1.5.0/anode_linux_amd64.tar.gz"
      sha256 "ea3eeee83cafc59f2a047558df8170a3a456b57bb1a3a21c583c9239c80b513f"
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
