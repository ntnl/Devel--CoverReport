#!/usr/bin/perl
# Copyright 2009-2010, Bartłomiej Syguła (natanael@natanael.krakow.pl)
#
# This is free software. It is licensed, and can be distributed under the same terms as Perl itself.
#
# For more, see my website: http://natanael.krakow.pl/
use strict; use warnings;

BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More;

# This test is targetted at the module maintainer.
# Users do not need to run it.
unless ( $ENV{AUTOMATED_TESTING} or $ENV{RELEASE_TESTING} ) {
	plan( skip_all => "Author tests not required for installation" );
}

eval "use Test::Distribution";
if ($@) {
    plan skip_all => 'Test::Distribution not installed';
}
else {
    import Test::Distribution distversion => 0.01;
}

# vim: fdm=marker
