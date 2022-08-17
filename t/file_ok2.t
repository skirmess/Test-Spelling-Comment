#!perl

# vim: ts=4 sts=4 sw=4 et: syntax=perl
#
# Copyright (c) 2018-2022 Sven Kirmess
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

use 5.006;
use strict;
use warnings;

use Test::Builder::Tester;
use Test::More 0.88;

use Cwd            ();
use File::Basename ();
use File::Spec     ();
use lib File::Spec->catdir( File::Basename::dirname( Cwd::abs_path __FILE__ ), 'lib' );

use Local::Test::TempDir qw(tempdir);

package Test::Spelling::Comment;
use subs qw(open);

package main;

use Test::Spelling::Comment 0.003;

main();

sub main {
  SKIP:
    {
        my $class = 'Test::Spelling::Comment';

        *Test::Spelling::Comment::open = sub { return };

        my $obj = $class->new;

        my $tmp  = tempdir();
        my $file = File::Spec->catfile( $tmp, 'file.pm' );

        _touch($file);

        #
        test_out("not ok 1 - $file");
        test_fail(+3);
        test_diag(q{});
        test_err(qr{[#]\s+\QCannot read file '$file': \E.*\n?});
        my $rc = $obj->file_ok($file);
        test_test('file_ok fails if file cannot be read');

        is( $rc, undef, '... returns undef' );
    }

    # ----------------------------------------------------------
    done_testing();

    exit 0;
}

sub _touch {
    my ( $file, @content ) = @_;

    if ( open my $fh, '>', $file ) {
        if ( print {$fh} @content ) {
            return if close $fh;
        }
    }

    skip "Test setup failed: Cannot write file '$file': $!";
}
