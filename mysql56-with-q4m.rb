require "formula"

class Mysql56WithQ4m < Formula
  homepage "http://dev.mysql.com/doc/refman/5.6/en/"
  url "https://cdn.mysql.com/archives/mysql-5.6/mysql-5.6.28.tar.gz"
  sha256 "217cd96921abdd709b9b4ff3ce2af4cbd237de43679cf19385d19df03a037b21"

  bottle do
    sha256 "09add752ac02612bf95e696500e74fdfd281f54a98faf5ae49f135eb60c34f61" => :yosemite
    sha256 "b6ea5c4f3eebbfeba9710aeaedefe60f6a6b280b1a48834b9a5387d4df71fd5c" => :mavericks
    sha256 "d1c79bbf500f6845b0b29f169267e80280f4993f8abf524fd2d888127347233d" => :mountain_lion
  end

  resource 'q4m' do
    url 'http://q4m.kazuhooku.com/dist/q4m-0.9.14.tar.gz'
    version '0.9.14'
    sha1 '7d865bd6588923fcf867e361eba99585d009d66a'
  end

  option :universal
  option 'with-tests', 'Build with unit tests'
  option 'with-embedded', 'Build the embedded server'
  option 'with-archive-storage-engine', 'Compile with the ARCHIVE storage engine enabled'
  option 'with-blackhole-storage-engine', 'Compile with the BLACKHOLE storage engine enabled'
  option 'enable-local-infile', 'Build with local infile loading support'
  option 'enable-memcached', 'Enable innodb-memcached support'
  option 'enable-debug', 'Build with debug support'

  depends_on 'cmake' => :build
  depends_on 'pidof' unless MacOS.version >= :mountain_lion
  depends_on 'openssl'

  conflicts_with 'mysql', 'mysql-cluster', 'mariadb', 'percona-server',
    :because => "mysql, mariadb, and percona install the same binaries."
  conflicts_with 'mysql-connector-c',
    :because => 'both install MySQL client libraries'

  fails_with :llvm do
    build 2326
    cause "https://github.com/Homebrew/homebrew/issues/issue/144"
  end

  def install
    # Don't hard-code the libtool path. See:
    # https://github.com/Homebrew/homebrew/issues/20185
    inreplace "cmake/libutils.cmake",
      "COMMAND /usr/bin/libtool -static -o ${TARGET_LOCATION}",
      "COMMAND libtool -static -o ${TARGET_LOCATION}"

    # Build without compiler or CPU specific optimization flags to facilitate
    # compilation of gems and other software that queries `mysql-config`.
    ENV.minimal_optimization

    # -DINSTALL_* are relative to prefix
    args = %W[
      .
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_FIND_FRAMEWORK=LAST
      -DCMAKE_VERBOSE_MAKEFILE=ON
      -DMYSQL_DATADIR=#{var}/mysql
      -DINSTALL_INCLUDEDIR=include/mysql
      -DINSTALL_MANDIR=share/man
      -DINSTALL_DOCDIR=share/doc/#{name}
      -DINSTALL_INFODIR=share/info
      -DINSTALL_MYSQLSHAREDIR=share/mysql
      -DWITH_SSL=bundled
      -DDEFAULT_CHARSET=utf8
      -DDEFAULT_COLLATION=utf8_general_ci
      -DSYSCONFDIR=#{etc}
      -DCOMPILATION_COMMENT=Homebrew
      -DWITH_EDITLINE=system
    ]

    # To enable unit testing at build, we need to download the unit testing suite
    if build.with? 'tests'
      args << "-DENABLE_DOWNLOADS=ON"
    else
      args << "-DWITH_UNIT_TESTS=OFF"
    end

    # Build the embedded server
    args << "-DWITH_EMBEDDED_SERVER=ON" if build.with? 'embedded'

    # Compile with ARCHIVE engine enabled if chosen
    args << "-DWITH_ARCHIVE_STORAGE_ENGINE=1" if build.with? 'archive-storage-engine'

    # Compile with BLACKHOLE engine enabled if chosen
    args << "-DWITH_BLACKHOLE_STORAGE_ENGINE=1" if build.with? 'blackhole-storage-engine'

    # Make universal for binding to universal applications
    if build.universal?
      ENV.universal_binary
      args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.universal_archs.as_cmake_arch_flags}"
    end

    # Build with local infile loading support
    args << "-DENABLED_LOCAL_INFILE=1" if build.include? 'enable-local-infile'

    # Build with memcached support
    args << "-DWITH_INNODB_MEMCACHED=1" if build.include? 'enable-memcached'

    # Build with debug support
    args << "-DWITH_DEBUG=1" if build.include? 'enable-debug'

    resource('q4m').stage do
      mkdir "#{buildpath}/storage/q4m"
      cp_r Dir["*"], "#{buildpath}/storage/q4m/"
    end

    system "cmake", *args
    system "make"
    system "make install"

    # Don't create databases inside of the prefix!
    # See: https://github.com/Homebrew/homebrew/issues/4975
    rm_rf prefix+'data'

    # Link the setup script into bin
    bin.install_symlink prefix/"scripts/mysql_install_db"

    # Fix up the control script and link into bin
    inreplace "#{prefix}/support-files/mysql.server" do |s|
      s.gsub!(/^(PATH=".*)(")/, "\\1:#{HOMEBREW_PREFIX}/bin\\2")
      # pidof can be replaced with pgrep from proctools on Mountain Lion
      s.gsub!(/pidof/, 'pgrep') if MacOS.version >= :mountain_lion
    end

    bin.install_symlink prefix/"support-files/mysql.server"

    # Move mysqlaccess to libexec
    libexec.mkpath
    mv "#{bin}/mysqlaccess", libexec
    mv "#{bin}/mysqlaccess.conf", libexec
  end

  def post_install
    # Make sure the var/mysql directory exists
    (var+"mysql").mkpath
    unless File.exist? "#{var}/mysql/mysql/user.frm"
      ENV['TMPDIR'] = nil
      system "#{bin}/mysql_install_db", '--verbose', "--user=#{ENV['USER']}",
        "--basedir=#{prefix}", "--datadir=#{var}/mysql", "--tmpdir=/tmp"
    end
  end

  def caveats; <<-EOS.undent
    A "/etc/my.cnf" from another install may interfere with a Homebrew-built
    server starting up correctly.

    To connect:
        mysql -uroot
    EOS
  end

  plist_options :manual => "mysql.server start"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/mysqld_safe</string>
        <string>--bind-address=127.0.0.1</string>
        <string>--datadir=#{var}/mysql</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{var}</string>
    </dict>
    </plist>
    EOS
  end

  test do
    (prefix+'mysql-test').cd do
      system './mysql-test-run.pl', 'status'
    end
  end
end

