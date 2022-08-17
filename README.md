# NAME

Test::Spelling::Comment - check for spelling errors in code comments

# VERSION

Version 0.005

# SYNOPSIS

    use Test::Spelling::Comment;
    Test::Spelling::Comment->new->add_stopwords(<DATA>)->all_files_ok;

# DESCRIPTION

`Test::Spelling::Comment` lets you check the spelling of your code
comments, and report its results in standard [Test::More](https://metacpan.org/pod/Test%3A%3AMore)
fashion. This module uses [Comment::Spell::Check](https://metacpan.org/pod/Comment%3A%3ASpell%3A%3ACheck) to
do the checking, which requires a spellcheck program such as `spell`,
`aspell`, `ispell`, or `hunspell`.

This test is an author test and should not run on end-user installations.
Recommendation is to put it into your `xt` instead of your `t` directory.

# USAGE

## new( \[ ARGS \] )

Returns a new `Test::Spelling::Comment` instance. `new` takes an optional
hash with its arguments.

    Test::Spelling::Comment->new(
        skip      => pattern,
        stopwords => Pod::Wordlist,
    );

The following arguments are supported:

### skip (optional)

The `skip` argument is either a string or an array ref of strings or regex
patterns. Every pattern is substituted for the empty string on every line of
the input file. This happens before passing the file over to
[Comment::Spell::Check](https://metacpan.org/pod/Comment%3A%3ASpell%3A%3ACheck) for spell checking.

Use this option to remove parts of the file that would otherwise require you
to add multiple `stopwords`. An example would be lines like these:

    # vim: ts=4 sts=4 sw=4 et: syntax=perl

### stopwords (optional)

The `stopwords` argument must be a [Pod::Wordlist](https://metacpan.org/pod/Pod%3A%3AWordlist) instance,
or something compatible. You can use that argument to configure
[Pod::Wordlist](https://metacpan.org/pod/Pod%3A%3AWordlist) to your liking.

## file\_ok( FILENAME )

`file_ok` will ok the test and return something _true_ if no spelling
error is found in the code comments. Otherwise it fails the test and returns
something _false_.

## all\_files\_ok

Calls the `all_files` method of [Test::XTFiles](https://metacpan.org/pod/Test%3A%3AXTFiles) to get all the files to
be tested. All files will be checked by calling `file_ok`.

It calls `done_testing` or `skip_all` so you can't have already called
`plan`.

`all_files_ok` returns something _true_ if all files test ok and _false_
otherwise.

Please see [XT::Files](https://metacpan.org/pod/XT%3A%3AFiles) for how to configure the files to be checked.

WARNING: The API was changed with 0.005. Arguments to `all_files_ok`
are now silently discarded and the method is now configured with
[XT::Files](https://metacpan.org/pod/XT%3A%3AFiles).

## add\_stopwords( @entries )

Adds the words passed in `@entries` as stopwords. These words are not
passed to the spell checker and are therefore accepted as correct.

The `add_stopwords` method always returns `$self` and can therefore be
used to chain methods together.

This method can be called multiple times.

This method only adds the words as passed in `@entries`. Unlike
`learn_stopwords` from [Pod::Wordlist](https://metacpan.org/pod/Pod%3A%3AWordlist) it does not add the
words plural too.

# EXAMPLES

## Example 1 Default usage

Check the spelling in all files returned by [XT::Files](https://metacpan.org/pod/XT%3A%3AFiles).

    use 5.006;
    use strict;
    use warnings;

    use Test::Spelling::Comment 0.002;

    if ( exists $ENV{AUTOMATED_TESTING} ) {
        print "1..0 # SKIP these tests during AUTOMATED_TESTING\n";
        exit 0;
    }

    Test::Spelling::Comment->new->add_stopwords(<DATA>)->all_files_ok;

    __DATA__
    your
    stopwords
    go
    here

## Example 2 Check non-default directories or files

Use the same test file as in Example 1 and create a `.xtfilesrc` config
file in the root directory of your distribution.

    [Dirs]
    module = lib
    module = tools
    module = corpus/hello

    [Files]
    module = corpus/my.pm

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

    my $comment = Test::Spelling::Comment->new;
    $comment->file_ok('corpus/hello.pl');
    $comment->file_ok('tools/update.pl');

    done_testing();

## Example 4 Skip vim line

Check the spelling in all files in the `bin`, `script` and `lib`
directory and remove the `vim` comment.

    use 5.006;
    use strict;
    use warnings;

    use Test::Spelling::Comment 0.003;

    if ( exists $ENV{AUTOMATED_TESTING} ) {
        print "1..0 # SKIP these tests during AUTOMATED_TESTING\n";
        exit 0;
    }

    Test::Spelling::Comment->new(
        skip => '^# vim: .*'
    )->add_stopwords(<DATA>)->all_files_ok();

    __DATA__
    your
    stopwords
    go
    here

# SEE ALSO

[Comment::Spell::Check](https://metacpan.org/pod/Comment%3A%3ASpell%3A%3ACheck),
[Comment::Spell](https://metacpan.org/pod/Comment%3A%3ASpell), [Test::More](https://metacpan.org/pod/Test%3A%3AMore),
[XT::Files](https://metacpan.org/pod/XT%3A%3AFiles)

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
