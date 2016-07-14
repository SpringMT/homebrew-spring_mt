require 'formula'

class Cipherscan < Formula
  homepage 'https://github.com/jvehent/cipherscan'
  head 'https://github.com/jvehent/cipherscan.git'

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
