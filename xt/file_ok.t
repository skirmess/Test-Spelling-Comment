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
use Test::Fatal;
use Test::MockModule 0.14;
use Test::More 0.88;

use Cwd            ();
use File::Basename ();
use File::Spec     ();
use lib File::Spec->catdir( File::Basename::dirname( Cwd::abs_path __FILE__ ), '../t/lib' );

use Local::Test::TempDir qw(tempdir);

use Test::Spelling::Comment 0.003;

main();

sub main {
    my $class = 'Test::Spelling::Comment';

    note('argument checks');
    {
        my $obj = $class->new;

        #
        like( exception { $obj->file_ok() },                 qr{usage: file_ok[(]FILE[)]}, 'file_ok() throws an exception with too few arguments' );
        like( exception { $obj->file_ok(undef) },            qr{usage: file_ok[(]FILE[)]}, '... undef for a file name' );
        like( exception { $obj->file_ok( 'file', 'name' ) }, qr{usage: file_ok[(]FILE[)]}, '... too many arguments' );
    }

    note('files does not exist');
    {
        my $obj = $class->new;

        #
        my $tmp               = tempdir();
        my $non_existing_file = File::Spec->catfile( $tmp, 'no_such_file' );

        #
        test_out("not ok 1 - $non_existing_file");
        test_fail(+3);
        test_diag(q{});
        test_diag("File $non_existing_file does not exist or is not a file");
        my $rc = $obj->file_ok($non_existing_file);
        test_test('file_ok fails on a non-existing file');

        is( $rc, undef, '... returns undef' );
    }

    note('file exists, without spelling errors');
  SKIP:
    {
        my $tmp  = tempdir();
        my $file = File::Spec->catfile( $tmp, 'file.pm' );

        my $string_orig = "hello world\nfrom\nfile\n";
        _touch( $file, $string_orig );

        my $module = Test::MockModule->new('Comment::Spell::Check');

        my $result_print;
        my $result_return = { counts => {}, fails => [] };

        my $string;
        $module->redefine( 'parse_from_string', sub { $_[0]->output_filehandle->print($result_print); $string = $_[1]; return $result_return; } );

        my $obj = $class->new;

        test_out("ok 1 - $file");
        my $rc = $obj->file_ok($file);
        test_test('file_ok success');

        is( $rc,     1,            '... returns 1' );
        is( $string, $string_orig, 'parse_from_string got passed the correct file content' );
    }

    note('skip, single regex');
  SKIP:
    {
        my $tmp  = tempdir();
        my $file = File::Spec->catfile( $tmp, 'file.pm' );

        my $string_base     = "hello world\nfrom\nfile\n";
        my $string_orig     = "${string_base}# vim: ts=4 sts=4 sw=4 et: syntax=perl\n";
        my $string_expected = "${string_base}\n";

        _touch( $file, $string_orig );

        my $module = Test::MockModule->new('Comment::Spell::Check');

        my $result_print;
        my $result_return = { counts => {}, fails => [] };

        my $string;
        $module->redefine( 'parse_from_string', sub { $_[0]->output_filehandle->print($result_print); $string = $_[1]; return $result_return; } );

        my $obj = $class->new( skip => qr{ ^ [#] [ ] vim: [ ] .*}xs );

        test_out("ok 1 - $file");
        my $rc = $obj->file_ok($file);
        test_test('file_ok success');

        is( $rc,     1,                '... returns 1' );
        is( $string, $string_expected, 'parse_from_string got passed the correct file content' );
    }

    note('skip, two regex');
  SKIP:
    {
        my $tmp  = tempdir();
        my $file = File::Spec->catfile( $tmp, 'file.pm' );

        my $string_base     = "hello world\nfrom\nfile\n";
        my $string_orig     = "${string_base}# vim: ts=4 sts=4 sw=4 et: syntax=perl\n";
        my $string_expected = "${string_base}\n";

        _touch( $file, $string_orig );

        my $module = Test::MockModule->new('Comment::Spell::Check');

        my $result_print;
        my $result_return = { counts => {}, fails => [] };

        my $string;
        $module->redefine( 'parse_from_string', sub { $_[0]->output_filehandle->print($result_print); $string = $_[1]; return $result_return; } );

        my $obj = $class->new( skip => [ qr{this will not match anything}, qr{ ^ [#] [ ] vim: [ ] .*}xs ] );

        test_out("ok 1 - $file");
        my $rc = $obj->file_ok($file);
        test_test('file_ok success');

        is( $rc,     1,                '... returns 1' );
        is( $string, $string_expected, 'parse_from_string got passed the correct file content' );
    }

    note('skip, two regex as string');
  SKIP:
    {
        my $tmp  = tempdir();
        my $file = File::Spec->catfile( $tmp, 'file.pm' );

        my $string_base     = "hello world\nfrom\nfile\n";
        my $string_orig     = "${string_base}# vim: ts=4 sts=4 sw=4 et: syntax=perl\n";
        my $string_expected = "${string_base}\n";

        _touch( $file, $string_orig );

        my $module = Test::MockModule->new('Comment::Spell::Check');

        my $result_print;
        my $result_return = { counts => {}, fails => [] };

        my $string;
        $module->redefine( 'parse_from_string', sub { $_[0]->output_filehandle->print($result_print); $string = $_[1]; return $result_return; } );

        my $obj = $class->new( skip => [ 'this will not match anything', '^[#][ ]vim:[ ].*' ] );

        test_out("ok 1 - $file");
        my $rc = $obj->file_ok($file);
        test_test('file_ok success');

        is( $rc,     1,                '... returns 1' );
        is( $string, $string_expected, 'parse_from_string got passed the correct file content' );
    }

    note('skip, one regex as string');
  SKIP:
    {
        my $tmp  = tempdir();
        my $file = File::Spec->catfile( $tmp, 'file.pm' );

        my $string_base     = "hello world\nfrom\nfile\n";
        my $string_orig     = "${string_base}# vim: ts=4 sts=4 sw=4 et: syntax=perl\n";
        my $string_expected = "${string_base}\n";

        _touch( $file, $string_orig );

        my $module = Test::MockModule->new('Comment::Spell::Check');

        my $result_print;
        my $result_return = { counts => {}, fails => [] };

        my $string;
        $module->redefine( 'parse_from_string', sub { $_[0]->output_filehandle->print($result_print); $string = $_[1]; return $result_return; } );

        my $obj = $class->new( skip => '^[#][ ]vim:[ ].*' );

        test_out("ok 1 - $file");
        my $rc = $obj->file_ok($file);
        test_test('file_ok success');

        is( $rc,     1,                '... returns 1' );
        is( $string, $string_expected, 'parse_from_string got passed the correct file content' );
    }

    note('skip twice on same line');
  SKIP:
    {
        my $tmp  = tempdir();
        my $file = File::Spec->catfile( $tmp, 'file.pm' );

        my $string_orig     = "hello world\nfrom http://url HTTP://another\nfile\nhttps://third xx";
        my $string_expected = "hello world\nfrom  \nfile\n xx\n";

        _touch( $file, $string_orig );

        my $module = Test::MockModule->new('Comment::Spell::Check');

        my $result_print;
        my $result_return = { counts => {}, fails => [] };

        my $string;
        $module->redefine( 'parse_from_string', sub { $_[0]->output_filehandle->print($result_print); $string = $_[1]; return $result_return; } );

        my $obj = $class->new( skip => '(?i)http(s)?://[^\s]+' );

        test_out("ok 1 - $file");
        my $rc = $obj->file_ok($file);
        test_test('file_ok success');

        is( $rc,     1,                '... returns 1' );
        is( $string, $string_expected, 'parse_from_string got passed the correct file content' );
    }

    note('file exists, with spelling errors');
  SKIP:
    {
        my $tmp  = tempdir();
        my $file = File::Spec->catfile( $tmp, 'file.pm' );

        _touch($file);

        my $module = Test::MockModule->new('Comment::Spell::Check');

        my $result_print  = "line\t #2: helol wordl\n\nAll incorrect words, by number of occurrences:\n     1: helol, wordl";
        my $result_return = {
            counts => { helol => 1, wordl => 1 },
            fails  => [ { counts => { helol => 1, wordl => 1 }, line => 2 } ],
        };

        $module->redefine( 'parse_from_string', sub { $_[0]->output_filehandle->print($result_print); return $result_return; } );

        my $obj = $class->new;

        test_out("not ok 1 - $file");
        test_fail(+6);
        test_diag(q{});
        for my $line ( split /\n/, $result_print ) {
            test_diag($line);
        }
        test_diag(q{});
        my $rc = $obj->file_ok($file);
        test_test('file_ok failure');

        is( $rc, undef, '... returns undef' );
    }

    note('file exists, Comment::Spell::Check throws an exception, without stopwords');
  SKIP:
    {
        my $tmp  = tempdir();
        my $file = File::Spec->catfile( $tmp, 'file.pm' );

        _touch($file);

        my $module = Test::MockModule->new('Comment::Spell::Check');

        $module->redefine( 'parse_from_string', sub { die "PARSE FROM STRING FAILED\n"; } );

        my $new_args_ref;
        $module->redefine( 'new', sub { $new_args_ref = [@_]; $module->original('new')->(@_); } );

        my $obj = $class->new;

        test_out("not ok 1 - $file");
        test_fail(+4);
        test_diag(q{});
        test_diag('PARSE FROM STRING FAILED');
        test_diag( q{}, q{} );
        my $rc = $obj->file_ok($file);
        test_test('file_ok failure');

        is( $rc, undef, '... returns undef' );

        is( @{$new_args_ref},    1,                       '... 1 arguments was passed to new' );
        is( ${$new_args_ref}[0], 'Comment::Spell::Check', '... the class name' );
    }

    note('file exists, Comment::Spell::Check throws an exception, with stopwords');
  SKIP:
    {
        my $tmp  = tempdir();
        my $file = File::Spec->catfile( $tmp, 'file.pm' );

        _touch($file);

        my $module = Test::MockModule->new('Comment::Spell::Check');

        $module->redefine( 'parse_from_string', sub { die "PARSE FROM FILE FAILED\n"; } );

        my $new_args_ref;
        $module->redefine( 'new', sub { $new_args_ref = [@_]; $module->original('new')->(@_); } );

        my $obj = $class->new;
        $obj->add_stopwords('abcdefg');

        test_out("not ok 1 - $file");
        test_fail(+4);
        test_diag(q{});
        test_diag('PARSE FROM FILE FAILED');
        test_diag( q{}, q{} );
        my $rc = $obj->file_ok($file);
        test_test('file_ok failure');

        is( $rc, undef, '... returns undef' );

        is( @{$new_args_ref},    3,                       '... 3 arguments were passed to new' );
        is( ${$new_args_ref}[0], 'Comment::Spell::Check', '... the class name' );
        is( ${$new_args_ref}[1], 'stopwords',             '... stopwords' );
        isa_ok( ${$new_args_ref}[2], 'Pod::Wordlist', '... and a Pod::Wordlist object' );
    }

    #
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
