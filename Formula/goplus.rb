class Goplus < Formula
  desc "Go designed for data science"
  homepage "https://goplus.org/"
  url "https://github.com/goplus/gop/archive/refs/tags/v0.7.19.tar.gz"
  sha256 "1903e7ae09962e16dadae07a86f32af06fd616529b9302e926c529aa7f36c915"
  license "Apache-2.0"
  head "https://github.com/goplus/gop.git"

  depends_on "go" => :build

  def install
    system "go", "build", "-ldflags", "-s -w", *std_go_args
    chmod "+x", bin/"goplus"
  end

  test do
    system "true"
  end
end
