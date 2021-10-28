class Pijul < Formula
  desc "Distributed version control system"
  homepage "https://pijul.com/"
  url "https://static.crates.io/crates/pijul/pijul-1.0.0-alpha.55.crate"
  sha256 "19ec8cd342f29cbe42656dfc876e28fc14ec37e242685396bf86910f9465743b"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://crates.io/api/v1/crates/pijul/versions"
    regex(/"num":\s*"(\d+(?:\.\d+|[._-](?:alpha|beta))+)"/i)
  end

  bottle do
    root_url "https://github.com/FnControlOption/homebrew-tap/releases/download/pijul-1.0.0-alpha.55"
    sha256 cellar: :any,                 big_sur:      "4230c54ddea3ad976e5e49727379df87001ec1596bf9c44da0b4028918bf77e5"
    sha256 cellar: :any,                 catalina:     "e1c583d4fe5725b25bcb6e63e616f230b356f4d2d824ef7ae3be20ffdfda7040"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "61a1ee2370c729358ae6440eac10f74380efa151b0ce3fa929fea3508277381e"
  end

  depends_on "rust" => :build
  depends_on "libgit2"
  depends_on "libsodium"
  depends_on "xxhash"
  depends_on "zstd"

  uses_from_macos "openssl"

  def install
    system "tar", "--strip-components", "1", "-xzvf", "pijul-#{version}.crate"
    system "cargo", "install", "--features", "git", *std_cargo_args
  end

  test do
    system bin/"pijul", "init"
    %w[haunted house].each { |f| touch testpath/f }
    system bin/"pijul", "add", "haunted", "house"
    # system bin/"pijul", "key", "generate", "AUThor", "--email", "author@example.com"
    # assert_predicate testpath/"Library/Application Support/pijul/secretkey.json", :exist?
    # system bin/"pijul", "record", "-a", "-m", "Initial Change"
    assert_equal "haunted\nhouse", shell_output("#{bin}/pijul list").strip
  end
end
