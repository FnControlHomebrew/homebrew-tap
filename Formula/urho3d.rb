class Urho3d < Formula
  desc "Cross-platform 2D and 3D game engine"
  homepage "https://urho3d.github.io/"
  url "https://github.com/urho3d/Urho3D/archive/refs/tags/1.7.1.tar.gz"
  sha256 "57c15249d5339f12c301dfe5cce4a1468262329b7c0b18a11b7283eb37ec5e9e"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "openssl@1.1"

  on_linux do
    depends_on "libx11"
    depends_on "libxcursor"
    depends_on "libxext"
    depends_on "libxi"
    depends_on "libxinerama"
    depends_on "libxrandr"
    depends_on "libxrender"
    depends_on "libxscrnsaver"
    depends_on "libxxf86vm"
    depends_on "mesa"
    depends_on "pulseaudio"
  end

  def install
    args = std_cmake_args + %w[
      -DURHO3D_LIB_TYPE=SHARED
      -DURHO3D_SAMPLES=FALSE
    ]
    on_macos do
      args << "-DURHO3D_PCH=FALSE"
    end
    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system "true"
  end
end
