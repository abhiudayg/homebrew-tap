class Anode < Formula
  desc "Proof-of-Topology Bare-Metal Orchestrator for Unmodified Go Backends"
  homepage "https://anode.abhiudayg.dev"
  version "1.3.0"
  license "MIT"
  head "https://github.com/abhiudayg/anode.git", branch: "master"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/abhiudayg/anode/releases/download/v1.3.0/anode_darwin_arm64.tar.gz"
      sha256 "1a4fa09ef6c5735aeffdc076885d38e371df3787270025379cd91212608a82cc"
    else
      url "https://github.com/abhiudayg/anode/releases/download/v1.3.0/anode_darwin_amd64.tar.gz"
      sha256 "722f836bf72828ee381b65cd9b70985493f9ce77730458e44e0d75ee8712710a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/abhiudayg/anode/releases/download/v1.3.0/anode_linux_arm64.tar.gz"
      sha256 "9912f5ade87d535c35402940f4d43eafcac97d730891a9da1b56c5bb3d326c57"
    else
      url "https://github.com/abhiudayg/anode/releases/download/v1.3.0/anode_linux_amd64.tar.gz"
      sha256 "c3cc6706e85b7f3ab56285e992cdcf30a2caebae38b8d31f1827680fda6d3af7"
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
