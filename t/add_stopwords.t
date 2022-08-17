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

use Test::More 0.88;

use Scalar::Util qw(refaddr);

use Test::Spelling::Comment 0.003;

main();

sub main {
    my $class = 'Test::Spelling::Comment';

    note('add single word');
    {
        my $obj      = $class->new();
        my $wordlist = $obj->_stopwords->wordlist;

        my $word = 'this_is_not_a_stopword_12345';

        ok( !exists $wordlist->{$word},                             "'$word' is not a stopword" );
        ok( refaddr( $obj->add_stopwords($word) ) == refaddr($obj), "add_stopwords($word) returns \$self" );
        ok( exists $wordlist->{$word},                              "'$word' is a stopword" );
    }

    note('add two words');
    {
        my $obj      = $class->new();
        my $wordlist = $obj->_stopwords->wordlist;

        my @words = qw(this_is_not_a_stopword_12345 this_is_not_a_stopword_23456);

        ok( !exists $wordlist->{ $words[0] },                        "'$words[0]' is not a stopword" );
        ok( !exists $wordlist->{ $words[1] },                        "'$words[1]' is not a stopword" );
        ok( refaddr( $obj->add_stopwords(@words) ) == refaddr($obj), "add_stopwords(@words) returns \$self" );
        ok( exists $wordlist->{ $words[0] },                         "'$words[0]' is a stopword" );
        ok( exists $wordlist->{ $words[1] },                         "'$words[1]' is a stopword" );
    }

    note('add two words (with 2 calls)');
    {
        my $obj      = $class->new();
        my $wordlist = $obj->_stopwords->wordlist;

        my @words = qw(this_is_not_a_stopword_12345 this_is_not_a_stopword_23456);

        ok( !exists $wordlist->{ $words[0] },                             "'$words[0]' is not a stopword" );
        ok( !exists $wordlist->{ $words[1] },                             "'$words[1]' is not a stopword" );
        ok( refaddr( $obj->add_stopwords( $words[0] ) ) == refaddr($obj), "add_stopwords($words[0]) returns \$self" );
        ok( refaddr( $obj->add_stopwords( $words[1] ) ) == refaddr($obj), "add_stopwords($words[1]) returns \$self" );
        ok( exists $wordlist->{ $words[0] },                              "'$words[0]' is a stopword" );
        ok( exists $wordlist->{ $words[1] },                              "'$words[1]' is a stopword" );
    }

    note('add three words from __DATA__');
    {
        my $obj      = $class->new();
        my $wordlist = $obj->_stopwords->wordlist;

        my @words = qw(this_is_not_a_stopword_34567 this_is_not_a_stopword_45678 this_is_not_a_stopword_56789);

        ok( !exists $wordlist->{ $words[0] },                        "'$words[0]' is not a stopword" );
        ok( !exists $wordlist->{ $words[1] },                        "'$words[1]' is not a stopword" );
        ok( !exists $wordlist->{ $words[2] },                        "'$words[2]' is not a stopword" );
        ok( refaddr( $obj->add_stopwords(<DATA>) ) == refaddr($obj), 'add_stopwords(DATA) returns $self' );
        ok( exists $wordlist->{ $words[0] },                         "'$words[0]' is a stopword" );
        ok( exists $wordlist->{ $words[1] },                         "'$words[1]' is a stopword" );
        ok( exists $wordlist->{ $words[2] },                         "'$words[2]' is a stopword" );
    }

    done_testing();

    exit 0;
}

# vim: ts=4 sts=4 sw=4 et: syntax=perl
__DATA__
this_is_not_a_stopword_34567
this_is_not_a_stopword_45678
this_is_not_a_stopword_56789
