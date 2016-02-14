require 'formula'
require 'tmpdir'

class Handlersocket < Formula
  url 'https://github.com/DeNA/HandlerSocket-Plugin-for-MySQL/archive/1.1.2.tar.gz'
  homepage 'https://github.com/DeNA/HandlerSocket-Plugin-for-MySQL'
  sha1 'fa329644b39fe8b17ed5469c7fac217ed8017ec3'

  MYSQL_VERSION = '5.6.28'

  depends_on 'cmake' => :build
  depends_on 'libtool' => :build
  depends_on 'mysql56-with-q4m'

  def extract_mysql
    tarball = File.join HOMEBREW_CACHE, "mysql56-with-q4m-#{MYSQL_VERSION}.tar.gz"
    raise unless FileTest.exist? tarball
    Dir.chdir mysql_source_dir do
      safe_system "/usr/bin/tar", "xf", tarball
    end
  end

  def mysql_source_dir
    unless @mysql_source_dir
      @mysql_source_dir = Dir.mktmpdir 'handlersocket'
      # at_exit{ FileUtils.remove_entry_secure @mysql_source_dir }
    end
    @mysql_source_dir
  end

  def install
    extract_mysql
    ENV['PATH'] = "#{ENV['PATH']}:#{HOMEBREW_PREFIX}/bin"
    system "./autogen.sh"
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}", "--with-mysql-source=#{mysql_source_dir}/mysql-#{MYSQL_VERSION}",
                          "--with-mysql-bindir=#{HOMEBREW_PREFIX}/bin"
    system "make install"
  end

  def caveats
    <<-EOS.undent
      To confirm successfuly installed, run the following command
      and confirm that 'handlersocket' is in the list:
         mysql> SHOW PLUGINS;
         +------------------+----------+-----------+--------------------+---------+
         | Name             | Status   | Type      | Library            | License |
         +------------------+----------+-----------+--------------------+---------+
         | ...              | ...      | ...       | ...                | ...     |
         | handlersocket    | ACTIVE   | DAEMON    | handlersocket.so   | BSD     |
         +------------------+----------+-----------+--------------------+---------+
         xx rows in set (0.00 sec)

      To install handlersocket plugin manually, run the following command:
         mysql> INSTALL PLUGIN handlersocket SONAME 'handlersocket.so';
      To uninstall handlersocket plugin, run the following command:
         mysql> UNINSTALL PLUGIN handlersocket;
    EOS
  end

end
