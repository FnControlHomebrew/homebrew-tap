class Goplus < Formula
  desc "Go designed for data science"
  homepage "https://goplus.org/"
  url "https://github.com/goplus/gop/archive/refs/tags/v0.7.19.tar.gz"
  sha256 ""
  license "Apache-2.0"
  head "https://github.com/goplus/gop.git"

  depends_on "go" => :build

  def install
    system "go", "build", "-ldflags", "-s -w", *std_go_args
  end

  test do
    system "true"
  end
end
