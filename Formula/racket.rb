class Racket < Formula
  desc "Modern programming language in the Lisp/Scheme family"
  homepage "https://racket-lang.org/"
  url "https://mirror.racket-lang.org/installers/8.2/racket-8.2-src.tgz"
  sha256 "a0f3cf72938e7ae0f4f3eab70360812a2ec4e40efe327f1b449feb447b4f7482"
  license any_of: ["MIT", "Apache-2.0"]

  # File links on the download page are created using JavaScript, so we parse
  # the filename from a string in an object.
  livecheck do
    url "https://download.racket-lang.org/"
    regex(/["'][^"']*?racket[._-]v?(\d+(?:\.\d+)+)-src\.t/i)
  end

  depends_on "cairo"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "gettext"
  depends_on "glib"
  depends_on "jpeg"
  depends_on "libffi"
  depends_on "libpng"
  depends_on "openssl@1.1"
  depends_on "pixman"
  depends_on "util-linux"

  conflicts_with "minimal-racket", because: "both install `racket` and `raco` binaries"

  # these two files are amended when (un)installing packages
  skip_clean "lib/racket/launchers.rktd", "lib/racket/mans.rktd"

  def install
    # configure racket's package tool (raco) to do the Right Thing
    # see: https://docs.racket-lang.org/raco/config-file.html
    inreplace "etc/config.rktd", /\)\)\n$/, ") (default-scope . \"installation\"))\n"

    # use libraries from Homebrew
    # https://github.com/racket/racket/issues/3279
    inreplace [
      "share/pkgs/draw-lib/racket/draw/unsafe/glib.rkt",
      "src/native-libs/install.rkt",
    ] do |s|
      s.gsub! "libintl.9", "libintl.8"
      s.gsub! "libffi.6", "libffi.7"
    end

    cd "src" do
      args = %W[
        --disable-debug
        --disable-dependency-tracking
        --enable-origtree=no
        --enable-macprefix
        --prefix=#{prefix}
        --mandir=#{man}
        --sysconfdir=#{etc}
        --enable-useprefix
      ]

      ENV.append "LDFLAGS", "-Wl,-rpath,#{Formula["libffi"].opt_lib}"
      ENV.append "LDFLAGS", "-Wl,-rpath,#{Formula["openssl@1.1"].opt_lib}"
      ENV.append "LDFLAGS", "-Wl,-rpath,#{Formula["util-linux"].opt_lib}"

      system "./configure", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    output = shell_output("#{bin}/racket -e '(displayln \"Hello Homebrew\")'")
    assert_match "Hello Homebrew", output

    # show that the config file isn't malformed
    output = shell_output("'#{bin}/raco' pkg config")
    assert $CHILD_STATUS.success?
    assert_match Regexp.new(<<~EOS), output
      ^name:
        #{version}
      catalogs:
        https://download.racket-lang.org/releases/#{version}/catalog/
        https://pkgs.racket-lang.org
        https://planet-compats.racket-lang.org
      default-scope:
        installation
    EOS

    # ensure Homebrew openssl is used
    on_macos do
      output = shell_output("DYLD_PRINT_LIBRARIES=1 #{bin}/racket -e '(require openssl)' 2>&1")
      assert_match(%r{loaded: .*openssl@1\.1/.*/libssl.*\.dylib}, output)
    end
    on_linux do
      output = shell_output("LD_DEBUG=libs #{bin}/racket -e '(require openssl)' 2>&1")
      assert_match "init: #{Formula["openssl@1.1"].opt_lib}/#{shared_library("libssl")}", output
    end
  end
end
