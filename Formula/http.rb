class Http < Formula
  desc "Basic HTTP server for hosting a folder fast and simply"
  homepage "https://github.com/thecoshman/http"
  url "https://github.com/thecoshman/http/archive/v1.10.0.tar.gz"
  sha256 "712e3bd4eac58105829e9708b2d6178a58a4e3fa7b2bcc26c19b24a63a391d02"
  license "MIT"
  head "https://github.com/thecoshman/http.git"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    system "true"
  end
end
