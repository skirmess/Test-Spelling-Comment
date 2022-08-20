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

package Local::Test::Exception;

our $VERSION = '0.001';

# Support Exporter < 5.57
require Exporter;
our @ISA       = qw(Exporter);    ## no critic (ClassHierarchies::ProhibitExplicitISA)
our @EXPORT_OK = qw(exception);

sub exception(&) {
    my ($code) = @_;

    my $e;
    {
        local $@;    ## no critic (Variables::RequireInitializationForLocalVars)
        if ( !eval { $code->(); 1; } ) {
            $e = $@;
        }
    }

    return $e;
}

1;