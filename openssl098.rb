class Openssl098 < Formula
  desc "SSL/TLS cryptography library"
  homepage "https://www.openssl.org"
  url "https://www.openssl.org/source/openssl-0.9.8zh.tar.gz"
  sha256 "f1d9f3ed1b85a82ecf80d0e2d389e1fda3fca9a4dba0bf07adbf231e1a5e2fd6"

  bottle do
    sha256 "7543cbff1b366dcbde0f554033b7531d162acd9682a0773e7b8bfbf495ef9751" => :yosemite
    sha256 "f6b0ccc6cbcbfb60ea1e960a45351497d664c4172361b1c8ccb9db657549e60a" => :mavericks
    sha256 "c832d4b68e71c13d82d064bb6a7813871d59f862dd2b7c48f5c0fa2a1ea8f2dc" => :mountain_lion
  end

  keg_only :provided_by_osx

  def install
    args = %W[
      --prefix=#{prefix}
      --openssldir=#{etc}/openssl
      no-ssl2
      zlib-dynamic
      shared
    ]

    if MacOS.prefer_64_bit?
      args << "darwin64-x86_64-cc" << "enable-ec_nistp_64_gcc_128"
    else
      args << "darwin-i386-cc"
    end

    system "perl", "./Configure", *args

    ENV.deparallelize # Parallel compilation fails
    system "make"
    system "make", "test"
    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"
  end

  test do
    (testpath/"testfile.txt").write("This is a test file")
    expected_checksum = "91b7b0b1e27bfbf7bc646946f35fa972c47c2d32"
    system "#{bin}/openssl", "dgst", "-sha1", "-out", "checksum.txt", "testfile.txt"
    open("checksum.txt") do |f|
      checksum = f.read(100).split("=").last.strip
      assert_equal checksum, expected_checksum
    end
  end
end
