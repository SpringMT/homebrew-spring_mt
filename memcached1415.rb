class Memcached1415 < Formula
  desc "High performance, distributed memory object caching system"
  homepage "https://memcached.org/"
  url "http://www.memcached.org/files/memcached-1.4.15.tar.gz"
  sha256 "169721ab7a7531add6ae9f6b14b6b5641725fe0b1f0bdf5c3a4327725901e2b4"

  bottle do
    cellar :any
    #sha256 "fb390a87a44bd89f281e51c0c7b97c0ecd96563cbf1bbf5e74dd322c97c2cf94" => :sierra
    #sha256 "df17c1f2e4dba8c70e1ba7b0e5f47c6dfe2e5edf240ff036756226089062292a" => :el_capitan
    #sha256 "4f74ff764fa09d840fd2826d4d65521a2168a8f69d4f9150371781f7ba20351f" => :yosemite
  end

  option "with-sasl", "Enable SASL support -- disables ASCII protocol!"
  option "with-sasl-pwdb", "Enable SASL with memcached's own plain text password db support -- disables ASCII protocol!"

  depends_on "libevent"

  deprecated_option "enable-sasl" => "with-sasl"
  deprecated_option "enable-sasl-pwdb" => "with-sasl-pwdb"

  conflicts_with "mysql-cluster", :because => "both install `bin/memcached`"
  conflicts_with "memcached", :because => "duplicate"

  def install
    args = ["--prefix=#{prefix}", "--disable-coverage"]
    args << "--enable-sasl" if build.with? "sasl"
    args << "--enable-sasl-pwdb" if build.with? "sasl-pwdb"

    system "./configure", *args
    system "make", "install"
  end

  plist_options :manual => "#{HOMEBREW_PREFIX}/opt/memcached/bin/memcached"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>KeepAlive</key>
      <true/>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/memcached</string>
        <string>-l</string>
        <string>localhost</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
    </dict>
    </plist>
    EOS
  end

  test do
    pidfile = testpath/"memcached.pid"
    # Assumes port 11211 is not already taken
    system bin/"memcached", "--listen=localhost:11211", "--daemon", "--pidfile=#{pidfile}"
    sleep 1
    assert_predicate pidfile, :exist?, "Failed to start memcached daemon"
    pid = (testpath/"memcached.pid").read.chomp.to_i
    Process.kill "TERM", pid
  end
end
