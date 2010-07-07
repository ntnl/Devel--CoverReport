#!/usr/bin/perl
# Copyright 2009-2010, Bartłomiej Syguła (natanael@natanael.krakow.pl)
#
# This is free software. It is licensed, and can be distributed under the same terms as Perl itself.
#
# For more, see my website: http://natanael.krakow.pl/
use strict; use warnings;

use Module::Build;
my $build = Module::Build->new (
    # Who I am :)
    module_name => 'Devel::CoverReport',
    license     => 'perl',

    dist_abstract => 'Advanced coverage reports based on Devel::Cover',
    dist_author   => 'Bartłomiej Syguła <natanael@natanael.krakow.pl>',

    # What You must have, and what will do You good.
    requires => {
        'perl' => '5.8.0',

        'Devel::Cover'       => '0.64',

        'App::Prove'         => '3.11',
        'Cwd'                => '3.12',
        'Carp::Assert::More' => '1.12',
        'File::Path'         => '1.07',
        'File::Slurp'        => '9999.13',
        'FindBin'            => '1.47',
        'Getopt::Long'       => '2.36',
        'Params::Validate'   => '0.88',
        'Pod::Usage'         => '1.35',
        'Storable'           => '2.15',
        'YAML::Syck'         => '1.05',
    },
#    recommends => {
#        'Devel::Cover' => '0.64',
#    },

    # Play nice with friends ;)
    create_makefile_pl => 'traditional',
    create_packlist    => 1,
    create_readme      => 1,
    dynamic_config     => 0, # No dynamics needed, as of now.
);

$build->create_build_script;

# vim: fdm=marker
