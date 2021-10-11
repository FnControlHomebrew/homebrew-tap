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

  def self.skip_install?
    false
  end

  depends_on "atk" unless skip_install?
  depends_on "cairo" unless skip_install?
  depends_on "fontconfig" unless skip_install?
  depends_on "freetype" unless skip_install?
  depends_on "fribidi" unless skip_install?
  depends_on "glib" unless skip_install?
  depends_on "gmp" unless skip_install?
  depends_on "harfbuzz" unless skip_install?
  depends_on "jpeg" unless skip_install?
  depends_on "libpng" unless skip_install?
  depends_on "mpfr" unless skip_install?
  depends_on "openssl@1.1" unless skip_install?
  depends_on "pango" unless skip_install?
  depends_on "pixman" unless skip_install?
  depends_on "poppler" unless skip_install?
  depends_on "util-linux" unless skip_install? # for libuuid

  uses_from_macos "expat" unless skip_install?
  uses_from_macos "libffi" unless skip_install?
  uses_from_macos "sqlite" unless skip_install?
  uses_from_macos "zlib" unless skip_install?

  on_macos do
    next if skip_install?

    depends_on "gettext" # for libintl
    depends_on "mmtabbarview"
  end

  on_linux do
    next if skip_install?

    depends_on "gdk-pixbuf"
    depends_on "gtk+"
    depends_on "libx11"
    depends_on "libxau"
    depends_on "libxcb"
    depends_on "libxext"
    depends_on "libxrender"
  end

  conflicts_with "minimal-racket", because: "both install `racket` and `raco` binaries"

  # these two files are amended when (un)installing packages
  skip_clean "lib/racket/launchers.rktd", "lib/racket/mans.rktd"

  def skip_install?
    self.class.skip_install?
  end

  def install
    if skip_install?
      touch prefix/"foo"
      return
    end

    # configure racket's package tool (raco) to do the Right Thing
    # see: https://docs.racket-lang.org/raco/config-file.html
    inreplace "etc/config.rktd", /(?<=\))(?=\)\n$)/, <<~EOS

      (default-scope . "installation")
      (gui-bin-dir . "#{libexec}")
      (collects-search-dirs . ("#{share}/racket/pkgs" #f))
    EOS

    # use libraries from macOS or Homebrew
    # https://github.com/racket/racket/issues/3279
    inreplace "src/native-libs/install.rkt" do |s|
      s.gsub! "libedit.0", "libedit.3" if OS.mac?
      s.gsub! "libpoppler.44", "libpoppler"
    end
    inreplace [
      "src/native-libs/install.rkt",
      "share/pkgs/draw-lib/racket/draw/unsafe/glib.rkt",
    ] do |s|
      s.gsub! "libffi.6", "libffi"
      s.gsub! "libintl.9", "libintl"
    end
    inreplace [
      "src/native-libs/install.rkt",
      "share/pkgs/math-lib/math/private/bigfloat/mpfr.rkt",
    ] do |s|
      s.gsub! "libmpfr.4", "libmpfr"
    end
    if OS.mac?
      # inreplace "src/lt/configure" do |s|
      #   s.gsub! " -bundle ", " "
      #   s.gsub! "${wl}-flat_namespace ${wl}-undefined ${wl}suppress", ""
      # end
      # inreplace "share/pkgs/dynext-lib/dynext/link-unit.rkt",
      #   '"-bundle" "-flat_namespace" "-undefined" "suppress"', ""
      inreplace "share/pkgs/gui-lib/mred/private/wx/cocoa/tab-panel.rkt" do |s|
        s.gsub! "(directory-exists? mm-tab-bar-dir)", ""
        s.gsub! '(build-path mm-tab-bar-dir "MMTabBarView")',
                "\"#{Formula["mmtabbarview"].opt_frameworks}/MMTabBarView.framework/MMTabBarView\""
      end
      inreplace "share/pkgs/gui-lib/info.rkt", '("gui-x86_64-macosx" #:platform "x86_64-macosx" #:version "1.3")', ""
      inreplace "share/pkgs/draw-lib/info.rkt", '("draw-x86_64-macosx-3" #:platform "x86_64-macosx")', ""
      inreplace "share/pkgs/math-lib/info.rkt", '("math-x86_64-macosx" #:platform "x86_64-macosx")', ""
      inreplace "share/pkgs/racket-lib/info.rkt", '("racket-x86_64-macosx-3" #:platform "x86_64-macosx")', ""
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

      ENV["LDFLAGS"] = "-Wl,-rpath,#{Formula["openssl@1.1"].opt_lib} -Wl,-rpath,#{Formula["util-linux"].opt_lib}"

      system "./configure", *args
      system "make"
      system "make", "install"
    end

    bin.install Dir["#{libexec}/*"].select { |f| File.file?(f) && File.executable?(f) }
  end

  test do
    return if skip_install?

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
      assert_match "init: #{HOMEBREW_PREFIX}/lib/#{shared_library("libssl")}", output
    end
  end
end
