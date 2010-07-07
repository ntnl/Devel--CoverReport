#!/usr/bin/perl
# Copyright 2009-2010, Bartłomiej Syguła (natanael@natanael.krakow.pl)
#
# This is free software. It is licensed, and can be distributed under the same terms as Perl itself.
#
# For more, see my website: http://natanael.krakow.pl/

use strict; use warnings;

use Test::XT 'WriteXT';

WriteXT(
    'Test::Pod'            => 't/02-pod-TX.t',
    'Test::CPAN::Meta'     => 't/02-meta-TX.t',
    'Test::MinimumVersion' => 't/02-minimumversion-TX.t',
    'Test::Perl::Critic'   => 't/02-critic-TX.t',
);

