use 5.006;
use strict;
use warnings;

use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
    ABSTRACT           => 'check for spelling errors in code comments',
    AUTHOR             => 'Sven Kirmess <sven.kirmess@kzone.ch>',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    DISTNAME         => 'Test-Spelling-Comment',
    LICENSE          => 'open_source',
    MIN_PERL_VERSION => '5.006',
    NAME             => 'Test::Spelling::Comment',
    PREREQ_PM        => {
        Carp                    => 0,
        'Comment::Spell::Check' => 0,
        Moo                     => 0,
        'Pod::Wordlist'         => 0,
        'Scalar::Util'          => 0,
        'Test::Builder'         => 0,
        'Test::XTFiles'         => 0,
        strict                  => 0,
        warnings                => 0,
    },
    TEST_REQUIRES => {
        Cwd                     => 0,
        Exporter                => '5.57',
        'File::Basename'        => 0,
        'File::Path'            => 0,
        'File::Spec'            => 0,
        'Test::Builder::Tester' => 0,
        'Test::More'            => '0.88',
        lib                     => 0,
        subs                    => 0,
    },
    VERSION => '0.005',
    test    => {
        TESTS => 't/*.t',
    },
);

my %FallbackPrereqs = (
    Carp                    => 0,
    'Comment::Spell::Check' => 0,
    Cwd                     => 0,
    Exporter                => '5.57',
    'File::Basename'        => 0,
    'File::Path'            => 0,
    'File::Spec'            => 0,
    Moo                     => 0,
    'Pod::Wordlist'         => 0,
    'Scalar::Util'          => 0,
    'Test::Builder'         => 0,
    'Test::Builder::Tester' => 0,
    'Test::More'            => '0.88',
    'Test::XTFiles'         => 0,
    lib                     => 0,
    strict                  => 0,
    subs                    => 0,
    warnings                => 0,
);

if ( $ENV{AUTOMATED_TESTING} || $ENV{EXTENDED_TESTING} ) {
    $WriteMakefileArgs{test}{TESTS} .= ' xt/*.t';
    _add_extended_test_requirements();
}

if ( !eval { ExtUtils::MakeMaker->VERSION('6.63_03') } ) {
    delete $WriteMakefileArgs{TEST_REQUIRES};
    delete $WriteMakefileArgs{BUILD_REQUIRES};
    $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

if ( !eval { ExtUtils::MakeMaker->VERSION(6.52) } ) {
    delete $WriteMakefileArgs{CONFIGURE_REQUIRES};
}

WriteMakefile(%WriteMakefileArgs);

sub test_requires {
    my ( $module, $version_or_range ) = @_;
    $WriteMakefileArgs{TEST_REQUIRES}{$module} = $FallbackPrereqs{$module} = $version_or_range;
    return;
}

sub _add_extended_test_requirements {
    test_requires( 'Test::Fatal',      0 );
    test_requires( 'Test::MockModule', 0 );
    test_requires( 'constant',         0 );
    return;
}

# vim: ts=4 sts=4 sw=4 et: syntax=perl
