class GlpkDev < Formula
  desc "Library for Linear and Mixed-Integer Programming"
  homepage "https://www.gnu.org/software/glpk/"
  url "https://ftp.gnu.org/gnu/glpk/glpk-5.0.tar.gz"
  mirror "https://ftpmirror.gnu.org/glpk/glpk-5.0.tar.gz"
  sha256 "4a1013eebb50f728fc601bdd833b0b2870333c3b3e5a816eeba921d95bec6f15"
  license "GPL-3.0-or-later"

  depends_on "gmp"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--with-gmp"
    system "make", "install"

    # Sanitise references to Homebrew shims
    rm "examples/Makefile"
    rm "examples/glpsol"

    # Install the examples so we can easily write a meaningful test
    pkgshare.install "examples"
    pkgshare.install "doc"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include "glpk.h"

      int main(int argc, const char *argv[])
      {
        printf("%s", glp_version());
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-I#{include}", "-lglpk", "-o", "test"
    assert_match version.to_s, shell_output("./test")

    system ENV.cc, pkgshare/"examples/sample.c",
                   "-L#{lib}", "-I#{include}",
                   "-lglpk", "-o", "test"
    assert_match "OPTIMAL LP SOLUTION FOUND", shell_output("./test")
  end
end
