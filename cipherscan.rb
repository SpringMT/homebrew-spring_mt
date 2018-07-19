require 'formula'

class Cipherscan < Formula
  homepage 'https://github.com/jvehent/cipherscan'
  url 'https://github.com/jvehent/cipherscan.git', branch: 'master'
  version '1.0'

  patch <<"PATCH"
diff --git a/cipherscan b/cipherscan
index 236b34f..2c1fa58 100755
--- a/cipherscan
+++ b/cipherscan
@@ -2042,7 +2042,7 @@ fi

 if [[ -z $CACERTS ]] && ! [[ -n $CACERTS_ARG_SET ]]; then
     # find a list of trusted CAs on the local system, or use the provided list
-    for f in /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt; do
+    for f in #{HOMEBREW_PREFIX}/etc/openssl/cert.pem; do
         if [[ -e "$f" ]]; then
             CACERTS="$f"
             break
PATCH

  depends_on 'bash'
  depends_on 'coreutils'

  def install
    bin.install 'cipherscan'
  end

  def caveats; <<-EOS
    cipherscan example.com
    EOS
  end

  test do
    system "./cipherscan", "brew.sh"
  end
end

__END__
diff --git a/cipherscan b/cipherscan
index 236b34f..2c1fa58 100755
--- a/cipherscan
+++ b/cipherscan
@@ -2042,7 +2042,7 @@ fi

 if [[ -z $CACERTS ]] && ! [[ -n $CACERTS_ARG_SET ]]; then
     # find a list of trusted CAs on the local system, or use the provided list
-    for f in /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt; do
+    for f in /usr/local/etc/openssl/cert.pem; do
         if [[ -e "$f" ]]; then
             CACERTS="$f"
             break
