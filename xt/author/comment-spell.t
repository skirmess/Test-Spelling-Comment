#!perl

use 5.006;
use strict;
use warnings;

# Automatically generated file; DO NOT EDIT.

use Test::Spelling::Comment 0.003;

if ( exists $ENV{AUTOMATED_TESTING} ) {
    print "1..0 # SKIP these tests during AUTOMATED_TESTING\n";
    exit 0;
}

my @files;
push @files, grep { -d } qw( bin lib t/lib );
push @files, glob q{ t/*.t xt/*.t xt/*/*.t };

Test::Spelling::Comment->new(
    skip => [
        '^[#] vim: .*',
        '^[#]!/.*perl$',
        '(?i)http(?:s)?://[^\s]+',
    ],
)->add_stopwords(<DATA>)->all_files_ok(@files);

__DATA__
Analyse
CPANTS
Dist
ErrorHandling
LinkCheck
RegularExpressions
RemoveDevelopPrereqs
RequireCheckingReturnValueOfEval
RequireDotMatchAnything
RequireExtendedFormatting
RequireLineBoundaryMatching
SKIRMESS
TBT
Zilla
cpanfile
lib
pl
subtests