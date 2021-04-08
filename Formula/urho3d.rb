class Urho3d < Formula
  desc "Cross-platform 2D and 3D game engine"
  homepage "https://urho3d.github.io/"
  url "https://github.com/urho3d/Urho3D/archive/refs/tags/1.7.1.tar.gz"
  sha256 "57c15249d5339f12c301dfe5cce4a1468262329b7c0b18a11b7283eb37ec5e9e"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "libx11"
  depends_on "libxcursor"
  depends_on "libxext"
  depends_on "libxi"
  depends_on "libxinerama"
  depends_on "libxrandr"
  depends_on "libxrender"
  depends_on "libxscrnsaver"
  depends_on "libxxf86vm"
  depends_on "openssl@1.1"
  depends_on "pulseaudio"

  def install
    # ENV.deparallelize
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args, "-DURHO3D_LIB_TYPE=SHARED"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system "true"
  end
end
