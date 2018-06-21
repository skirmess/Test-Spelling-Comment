# NAME

Test::Spelling::Comment - Check for spelling errors in code comments

# VERSION

Version 0.001

# SYNOPSIS

    use Test::Spelling::Comment;
    my $tsc = Test::Spelling::Comment->new;
    $tsc->add_stopwords(<DATA>);
    $tsc->all_files_ok();

# DESCRIPTION

`Test::Spelling::Comment` lets you check the spelling of your code
comments, and report its results in standard [Test::More](https://metacpan.org/pod/Test::More)
fashion. This module uses [Comment::Spell::Check](https://metacpan.org/pod/Comment::Spell::Check) to
do the checking, which requires a spellcheck program such as `spell`,
`aspell`, `ispell`, or `hunspell`.

This test is an author test and should not run on end-user installations.
Recommendation is to put it into your `xt` instead of your `t` directory.

# USAGE

## new( \[ ARGS \] )

Returns a new `Test::Spelling::Comment` instance. `new` takes an optional
hash with its arguments.

    Test::Spelling::Comment->new(
        stopwords => Pod::Wordlist,
    );

The following arguments are supported:

### stopwords (optional)

The `stopwords` argument must be a [Pod::Wordlist](https://metacpan.org/pod/Pod::Wordlist) instance,
or something compatible. You can use that argument to configure
[Pod::Wordlist](https://metacpan.org/pod/Pod::Wordlist) to your liking.

## file\_ok( FILENAME )

`file_ok` will ok the test and return something _true_ if no spelling
error is found in the code comments. Otherwise it fails the test and returns
something _false_.

## all\_files\_ok( \[ @entries \] )

Checks all the spelling of the code comments in all files under `@entries`
by calling `file_ok` on every file. Directories are recursive searched for
files. Everything not a file and not a directory (e.g. a symlink) is
ignored. It calls `done_testing` or `skip_all` so you can't have already
called `plan`.

If `@entries` is empty default directories are searched for files. The
default directories are `blib`, or `lib` if it doesn't exist, `bin` and
`script`.

`all_files_ok` returns something _true_ if no spelling errors were found
and _false_ otherwise.

Filenames ending with a `~` are always ignored.

# EXAMPLES

## Example 1 Default Usage

Check the spelling in all files in the `bin`, `script` and `lib`
directory.

    use 5.006;
    use strict;
    use warnings;

    use Test::Spelling::Comment;

    if ( exists $ENV{AUTOMATED_TESTING} ) {
        print "1..0 # SKIP these tests during AUTOMATED_TESTING\n";
        exit 0;
    }

    my $tsc = Test::Spelling::Comment->new;
    $tsc->add_stopwords(<DATA>);
    $tsc->all_files_ok();
    __DATA__
    your
    stopwords
    go
    here

## Example 2 Check non-default directories or files

    use 5.006;
    use strict;
    use warnings;

    use Test::Spelling::Comment;

    if ( exists $ENV{AUTOMATED_TESTING} ) {
        print "1..0 # SKIP these tests during AUTOMATED_TESTING\n";
        exit 0;
    }

    my $tsc = Test::Spelling::Comment->new;
    $tsc->all_files_ok(qw(
        corpus/hello.pl
        lib
        tools
    ));

## Example 3 Call `file_ok` directly

    use 5.006;
    use strict;
    use warnings;

    use Test::More 0.88;
    use Test::Spelling::Comment;

    if ( exists $ENV{AUTOMATED_TESTING} ) {
        print "1..0 # SKIP these tests during AUTOMATED_TESTING\n";
        exit 0;
    }

    my $tsc = Test::Spelling::Comment->new;
    $tsc->file_ok('corpus/hello.pl');
    $tsc->file_ok('tools/update.pl');

    done_testing();

# SEE ALSO

[Comment::Spell::Check](https://metacpan.org/pod/Comment::Spell::Check),
[Comment::Spell](https://metacpan.org/pod/Comment::Spell), [Test::More](https://metacpan.org/pod/Test::More)

# SUPPORT

## Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at [https://github.com/skirmess/Test-Spelling-Comment/issues](https://github.com/skirmess/Test-Spelling-Comment/issues).
You will be notified automatically of any progress on your issue.

## Source Code

This is open source software. The code repository is available for
public review and contribution under the terms of the license.

[https://github.com/skirmess/Test-Spelling-Comment](https://github.com/skirmess/Test-Spelling-Comment)

    git clone https://github.com/skirmess/Test-Spelling-Comment.git

# AUTHOR

Sven Kirmess <sven.kirmess@kzone.ch>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Sven Kirmess.

This is free software, licensed under:

    The (two-clause) FreeBSD License
