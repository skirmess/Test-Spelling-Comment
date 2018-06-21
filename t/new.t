#!perl

use 5.006;
use strict;
use warnings;

use Test::Fatal;
use Test::More 0.88;

use Test::Spelling::Comment;

use FindBin qw($RealBin);
use lib "$RealBin/lib";

use Local::Pod::Wordlist;

main();

sub main {

    my $class = 'Test::Spelling::Comment';

    {
        my $obj = $class->new();
        isa_ok( $obj, $class, "new() returns a $class object" );
        ok( !$obj->_has_stopwords, '... which has no _stopwords defined' );

        isa_ok( $obj->_stopwords, 'Pod::Wordlist', q{... _stopwords returns a 'Pod::Wordlist'} );
        ok( $obj->_has_stopwords, '... and now has a _stopwords defined' );
    }

    {
        like( exception { $class->new( stopwords => 17 ); }, qr{stopwords must have method 'wordlist'}, 'new throws an exception if stopwords is not an object' );
        my $stopwords = bless {}, 'Local::Pod::Wordlist2';
        like( exception { $class->new( stopwords => $stopwords ); }, qr{stopwords must have method 'wordlist'}, q{... or doesn't have a method 'wordlist'} );
    }

    {
        my $stopwords = bless {}, 'Local::Pod::Wordlist';
        my $obj = $class->new( stopwords => $stopwords );
        ok( $obj->_has_stopwords, '... and has a _stopwords defined' );
        isa_ok( $obj->_stopwords, 'Local::Pod::Wordlist', q{... _stopwords returns a 'Local::Pod::Wordlist'} );
    }

    #
    done_testing();

    exit 0;
}

# vim: ts=4 sts=4 sw=4 et: syntax=perl
