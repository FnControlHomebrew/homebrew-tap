class Goplus < Formula
  desc "Go designed for data science"
  homepage "https://goplus.org/"
  url "https://github.com/goplus/gop/archive/refs/tags/v0.7.19.tar.gz"
  sha256 "1903e7ae09962e16dadae07a86f32af06fd616529b9302e926c529aa7f36c915"
  license "Apache-2.0"
  head "https://github.com/goplus/gop.git"

  depends_on "go" => :build

  def install
    ENV["GOBIN"] = bin
    ENV["GO111MODULE"] = "auto"

    system "go", "install", "-v", "./..."
  end

  test do
    (testpath/"hello.gop").write <<~EOS
      a := [1, 3, 5, 7, 11]
      b := [x*x for x <- a, x > 3]
      println(b)

      mapData := {"Hi": 1, "Hello": 2, "Go+": 3}
      reverseMap := {v: k for k, v <- mapData}
      println(reverseMap)
    EOS

    output = shell_output("#{bin}/gop run hello.gop")
    assert_match "[25 49 121]", output
    assert_match "map[1:Hi 2:Hello 3:Go+]", output
  end
end
