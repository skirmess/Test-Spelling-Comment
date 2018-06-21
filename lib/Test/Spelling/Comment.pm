package Test::Spelling::Comment;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.001';

use Moo;

use Carp                  ();
use Comment::Spell::Check ();
use File::Find            ();
use Pod::Wordlist         ();
use Scalar::Util          ();
use Test::Builder         ();

has _stopwords => (
    is        => 'ro',
    isa       => sub { Carp::croak q{stopwords must have method 'wordlist'} if !Scalar::Util::blessed( $_[0] ) || !$_[0]->can('wordlist'); },
    init_arg  => 'stopwords',
    lazy      => 1,
    default   => sub { Pod::Wordlist->new },
    predicate => 1,
);

my $TEST = Test::Builder->new();

# - Do not use subtests because subtests cannot be tested with
#   Test::Builder:Tester.
# - Do not use a plan because a method that sets a plan cannot be tested
#   with Test::Builder:Tester.
# - Do not call done_testing in a method that should be tested by
#   Test::Builder::Tester because TBT cannot test them.

sub add_stopwords {
    my $self = shift;

    my $wordlist = $self->_stopwords->wordlist;

  WORD:
    for (@_) {

        # explicit copy
        my $word = $_;
        $word =~ s{ ^ \s* }{}xsm;
        $word =~ s{ \s+ $ }{}xsm;
        next WORD if $word eq q{};

        $wordlist->{$word} = 1;
    }

    return;
}

sub all_files_ok {
    my $self = shift;

    my @args = scalar @_ ? @_ : $self->_default_dirs();
    if ( !@args ) {
        $TEST->skip_all("No files found\n");
        return 1;
    }

    my @files;
  ARG:
    for my $arg (@args) {
        if ( !-e $arg ) {
            $TEST->carp("File '$arg' does not exist");
            next ARG;
        }

        if ( -l $arg ) {
            $TEST->carp("Ignoring symlink '$arg'");
            next ARG;
        }

        if ( -f $arg ) {
            push @files, $arg;
            next ARG;
        }

        if ( !-d $arg ) {
            $TEST->carp("File '$arg' is not a file nor a directory. Ignoring it.");
            next ARG;
        }

        File::Find::find(
            {
                no_chdir   => 1,
                preprocess => sub {
                    my @sorted = sort grep { !-l "$File::Find::dir/$_" } @_;
                    return @sorted;
                },
                wanted => sub {
                    return if !-f $File::Find::name;
                    push @files, $File::Find::name;
                },
            },
            $arg,
        );
    }

    if ( !@files ) {
        $TEST->skip_all("No files found in (@args)\n");
        return 1;
    }

    my $rc = 1;
    for my $file ( grep { $_ !~ m{ [~] $ }xsm } @files ) {
        if ( !$self->file_ok($file) ) {
            $rc = 0;
        }
    }

    $TEST->done_testing;

    return 1 if $rc;
    return;
}

sub file_ok {
    my ( $self, $file ) = @_;

    Carp::croak 'usage: file_ok(FILE)' if @_ != 2 || !defined $file;

    if ( !-f $file ) {
        $TEST->ok( 0, $file );
        $TEST->diag("\n");
        $TEST->diag("File $file does not exist or is not a file");

        return;
    }

    my $speller = Comment::Spell::Check->new( $self->_has_stopwords ? ( stopwords => $self->_stopwords ) : () );
    my $buf;
    $speller->set_output_string($buf);
    my $result;
    if ( !eval { $result = $speller->parse_from_file($file); 1 } ) {
        my $error_msg = $@;
        $TEST->ok( 0, $file );
        $TEST->diag("\n$error_msg\n\n");

        return;
    }

    if ( @{ $result->{fails} } == 0 ) {
        $TEST->ok( 1, $file );

        return 1;
    }

    $TEST->ok( 0, $file );
    $TEST->diag("\n$buf\n\n");

    return;
}

sub _default_dirs {
    my ($self) = @_;

    my @dirs;
    if ( -d 'blib' ) {
        push @dirs, 'blib';
    }
    elsif ( -d 'lib' ) {
        push @dirs, 'lib';
    }

    if ( -d 'bin' ) {
        push @dirs, 'bin';
    }

    if ( -d 'script' ) {
        push @dirs, 'script';
    }

    my @sorted = sort @dirs;
    return @sorted;
}

no Moo;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test::Spelling::Comment - Check for spelling errors in code comments

=head1 VERSION

Version 0.001

=head1 SYNOPSIS

    use Test::Spelling::Comment;
    my $tsc = Test::Spelling::Comment->new;
    $tsc->add_stopwords(<DATA>);
    $tsc->all_files_ok();


=head1 DESCRIPTION

C<Test::Spelling::Comment> lets you check the spelling of your code
comments, and report its results in standard L<Test::More|Test::More>
fashion. This module uses L<Comment::Spell::Check|Comment::Spell::Check> to
do the checking, which requires a spellcheck program such as C<spell>,
C<aspell>, C<ispell>, or C<hunspell>.

This test is an author test and should not run on end-user installations.
Recommendation is to put it into your F<xt> instead of your F<t> directory.

=head1 USAGE

=head2 new( [ ARGS ] )

Returns a new C<Test::Spelling::Comment> instance. C<new> takes an optional
hash with its arguments.

    Test::Spelling::Comment->new(
        stopwords => Pod::Wordlist,
    );

The following arguments are supported:

=head3 stopwords (optional)

The C<stopwords> argument must be a L<Pod::Wordlist|Pod::Wordlist> instance,
or something compatible. You can use that argument to configure
L<Pod::Wordlist|Pod::Wordlist> to your liking.

=head2 file_ok( FILENAME )

C<file_ok> will ok the test and return something I<true> if no spelling
error is found in the code comments. Otherwise it fails the test and returns
something I<false>.

=head2 all_files_ok( [ @entries ] )

Checks all the spelling of the code comments in all files under C<@entries>
by calling C<file_ok> on every file. Directories are recursive searched for
files. Everything not a file and not a directory (e.g. a symlink) is
ignored. It calls C<done_testing> or C<skip_all> so you can't have already
called C<plan>.

If C<@entries> is empty default directories are searched for files. The
default directories are F<blib>, or F<lib> if it doesn't exist, F<bin> and
F<script>.

C<all_files_ok> returns something I<true> if no spelling errors were found
and I<false> otherwise.

Filenames ending with a C<~> are always ignored.

=head1 EXAMPLES

=head2 Example 1 Default Usage

Check the spelling in all files in the F<bin>, F<script> and F<lib>
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

=head2 Example 2 Check non-default directories or files

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

=head2 Example 3 Call C<file_ok> directly

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

=head1 SEE ALSO

L<Comment::Spell::Check|Comment::Spell::Check>,
L<Comment::Spell|Comment::Spell>, L<Test::More|Test::More>

=head1 SUPPORT

=head2 Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at L<https://github.com/skirmess/Test-Spelling-Comment/issues>.
You will be notified automatically of any progress on your issue.

=head2 Source Code

This is open source software. The code repository is available for
public review and contribution under the terms of the license.

L<https://github.com/skirmess/Test-Spelling-Comment>

  git clone https://github.com/skirmess/Test-Spelling-Comment.git

=head1 AUTHOR

Sven Kirmess <sven.kirmess@kzone.ch>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Sven Kirmess.

This is free software, licensed under:

  The (two-clause) FreeBSD License

=cut

# vim: ts=4 sts=4 sw=4 et: syntax=perl
