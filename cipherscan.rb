require 'formula'

class Cipherscan < Formula
  homepage 'https://github.com/jvehent/cipherscan'
  url 'https://github.com/jvehent/cipherscan.git', branch: 'master'
  version '1.0'

  depends_on 'bash'
  depends_on 'coreutils'

  def install
    bin.install_symlink prefix/'cipherscan'
  end

  def caveats; <<-EOS.undent
    cipherscan example.com
    EOS
  end

  test do
    system "./cipherscan", "brew.sh"
  end
end
