class Dxc < Formula
  desc "Compile HLSL programs into DXIL representation"
  homepage "https://github.com/microsoft/DirectXShaderCompiler"
  url "https://github.com/microsoft/DirectXShaderCompiler.git",
    tag:      "v1.6.2106",
    revision: "dad1cfc308e4a0dd49b2589e10b5427803ea6a6e"
  license all_of: ["NCSA", "MIT", "Spencer-94", "BSD-3-Clause"]

  depends_on "cmake" => :build
  depends_on "python@3.9" => :build

  def install
    # ENV.deparallelize
    args = std_cmake_args
    args += (buildpath/"utils/cmake-predefined-config-params").read.split.reject do |s|
      s["HLSL_INCLUDE_TESTS"] || s["SPIRV_BUILD_TESTS"]
    end
    args += %w[
      -DHLSL_INCLUDE_TESTS=OFF
      -DSPIRV_BUILD_TESTS=OFF
    ]
    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system "true"
  end
end
