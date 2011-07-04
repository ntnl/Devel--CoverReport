#!/usr/bin/perl
# Copyright 2009-2011, Bartłomiej Syguła (perl@bs502.pl)
#
# This is free software. It is licensed, and can be distributed under the same terms as Perl itself.
#
# For more, see my website: http://bs502.pl/

use strict; use warnings;

use Test::XT 'WriteXT';

WriteXT(
    'Test::Pod'            => 't/02-pod-TX.t',
    'Test::CPAN::Meta'     => 't/02-meta-TX.t',
    'Test::MinimumVersion' => 't/02-minimumversion-TX.t',
    'Test::Perl::Critic'   => 't/02-critic-TX.t',
);

