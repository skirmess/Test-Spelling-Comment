#!perl

use 5.006;
use strict;
use warnings;

#use Test::Fatal;
use Test::More 0.88;

use Test::Spelling::Comment;

#use FindBin qw($RealBin);
#use lib "$RealBin/lib";

#use Local::HTTP::NoUA;

main();

sub main {
    my $class = 'Test::Spelling::Comment';

    note('add single word');
    {
        my $obj      = $class->new();
        my $wordlist = $obj->_stopwords->wordlist;

        my $word = 'this_is_not_a_stopword_12345';

        ok( !exists $wordlist->{$word}, "'$word' is not a stopword" );
        is( $obj->add_stopwords($word), undef, "add_stopwords($word) returns undef" );
        ok( exists $wordlist->{$word}, "'$word' is a stopword" );
    }

    note('add two words');
    {
        my $obj      = $class->new();
        my $wordlist = $obj->_stopwords->wordlist;

        my @words = qw(this_is_not_a_stopword_12345 this_is_not_a_stopword_23456);

        ok( !exists $wordlist->{ $words[0] }, "'$words[0]' is not a stopword" );
        ok( !exists $wordlist->{ $words[1] }, "'$words[1]' is not a stopword" );
        is( $obj->add_stopwords(@words), undef, "add_stopwords(@words) returns undef" );
        ok( exists $wordlist->{ $words[0] }, "'$words[0]' is a stopword" );
        ok( exists $wordlist->{ $words[1] }, "'$words[1]' is a stopword" );
    }

    note('add two words (with 2 calls)');
    {
        my $obj      = $class->new();
        my $wordlist = $obj->_stopwords->wordlist;

        my @words = qw(this_is_not_a_stopword_12345 this_is_not_a_stopword_23456);

        ok( !exists $wordlist->{ $words[0] }, "'$words[0]' is not a stopword" );
        ok( !exists $wordlist->{ $words[1] }, "'$words[1]' is not a stopword" );
        is( $obj->add_stopwords( $words[0] ), undef, "add_stopwords($words[0]) returns undef" );
        is( $obj->add_stopwords( $words[1] ), undef, "add_stopwords($words[1]) returns undef" );
        ok( exists $wordlist->{ $words[0] }, "'$words[0]' is a stopword" );
        ok( exists $wordlist->{ $words[1] }, "'$words[1]' is a stopword" );
    }

    note('add three words from __DATA__');
    {
        my $obj      = $class->new();
        my $wordlist = $obj->_stopwords->wordlist;

        my @words = qw(this_is_not_a_stopword_34567 this_is_not_a_stopword_45678 this_is_not_a_stopword_56789);

        ok( !exists $wordlist->{ $words[0] }, "'$words[0]' is not a stopword" );
        ok( !exists $wordlist->{ $words[1] }, "'$words[1]' is not a stopword" );
        ok( !exists $wordlist->{ $words[2] }, "'$words[2]' is not a stopword" );
        is( $obj->add_stopwords(<DATA>), undef, 'add_stopwords(DATA) returns undef' );
        ok( exists $wordlist->{ $words[0] }, "'$words[0]' is a stopword" );
        ok( exists $wordlist->{ $words[1] }, "'$words[1]' is a stopword" );
        ok( exists $wordlist->{ $words[2] }, "'$words[2]' is a stopword" );
    }

    done_testing();

    exit 0;
}

# vim: ts=4 sts=4 sw=4 et: syntax=perl
__DATA__
this_is_not_a_stopword_34567
this_is_not_a_stopword_45678
this_is_not_a_stopword_56789
