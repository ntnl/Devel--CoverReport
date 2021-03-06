# Copyright 2009-2011, Bartłomiej Syguła (perl@bs502.pl)
#
# This is free software. It is licensed, and can be distributed under the same terms as Perl itself.
#
# For more, see my website: http://bs502.pl/

package Devel::CoverReport::Formatter::Html;

use strict;
use warnings;

our $VERSION = "0.05";

use base 'Devel::CoverReport::Formatter';

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use File::Slurp qw( write_file );
use Params::Validate qw( :all );

=encoding UTF-8

=head1 DESCRIPTION

HTML backend for L<Devel::CoverReport> reports.

=head1 WARNING

Consider this module to be an early ALPHA. It does the job for me, so it's here.

This is my first CPAN module, so I expect that some things may be a bit rough around edges.

The plan is, to fix both those issues, and remove this warning in next immediate release.

=head1 API

=over

=item process_formatter_start

=item process_report_start

=item process_table_start

=item process_row

=item process_summary

=item process_table_end

=item process_report_end

=item process_formatter_end

See: L<Devel::CoverReport::Formatter>.

=back

=cut

sub process_formatter_start { # {{{
    my ( $self ) = @_;

    # Prepare CSS template.
    local $INPUT_RECORD_SEPARATOR = undef;
    my $css_contents = <DATA>;

    write_file($self->{'basedir'} . q{/cover_report.css}, $css_contents);

    return;
} # }}}

sub process_report_start { # {{{
    my ( $self, $report ) = @_;

    $self->{'Instance'}->{'html'} = [
        qq{<html>\n},

        qq{<head>\n},
        qq{<title>} . $report->{'title'} . qq{</title>\n},
        qq{<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />\n},
        qq{<link media=screen href="cover_report.css" rel="stylesheet" type="text/css" />\n},
        qq{</style>\n},
        qq{</head>\n},

        qq{<body>\n},
        qq{<h1>} . $report->{'title'} . qq{</h1>\n},
    ];

    return;
} # }}}

sub process_table_start { # {{{
    my ( $self, $report, $table ) = @_;

    # Open the table:
    push @{ $self->{'Instance'}->{'html'} }, $table->{'label'} .q{<br>};
    push @{ $self->{'Instance'}->{'html'} }, q{<table>};
    
    # Add headers:
    $self->{'Instance'}->{'headers'}       = $table->get_headers();
    $self->{'Instance'}->{'headers_order'} = $table->get_headers_order();

    push @{ $self->{'Instance'}->{'html'} }, q{<tr>};
    foreach my $header_id (@{ $table->get_headers_order() }) {
        push @{ $self->{'Instance'}->{'html'} }, q{<th>} . $self->{'Instance'}->{'headers'}->{$header_id}->{'caption'} . q{</td>};
    }
    push @{ $self->{'Instance'}->{'html'} }, qq{</tr>\n};

    return;
} # }}}

sub process_row { # {{{
    my ( $self, $report, $table, $row ) = @_;

    if ($row->{'_class'}) {
        push @{ $self->{'Instance'}->{'html'} }, q{<tr class=}. $row->{'_class'} .q{>};
    }
    else {
        push @{ $self->{'Instance'}->{'html'} }, q{<tr>};
    }
    
    $self->_process_in_row($report, $table, $row, 'f');

    push @{ $self->{'Instance'}->{'html'} }, q{</tr>};

    return;
} # }}}

sub process_summary { # {{{
    my ( $self, $report, $table, $summary ) = @_;

    push @{ $self->{'Instance'}->{'html'} }, q{<tr class=summary>};

    $self->_process_in_row($report, $table, $summary, 'fs');

    push @{ $self->{'Instance'}->{'html'} }, q{</tr>};

    return;
} # }}}

sub _process_in_row { # {{{
    my ( $self, $report, $table, $row, $f_field ) = @_;

    foreach my $header_id (@{ $self->{'Instance'}->{'headers_order'} }) {
        my $header = $self->{'Instance'}->{'headers'}->{$header_id};

        my $content = q{};
        if (defined $row->{$header_id}) {
            $content = _format_value($row->{$header_id}, $header, $f_field);
        }

        if ($header->{'class'}) {
            push @{ $self->{'Instance'}->{'html'} }, q{<td class=} . $header->{'class'} . q{>}, $content, q{</td>};
        }
        else {
            push @{ $self->{'Instance'}->{'html'} }, q{<td>}, $content, q{</td>};
        }
    }

    return;
} # }}}

sub process_table_end { # {{{
    my ( $self, $report, $table ) = @_;

    push @{ $self->{'Instance'}->{'html'} }, qq{</table>\n};

    return;
} # }}}

sub process_report_end { # {{{
    my ( $self, $report ) = @_;

    assert_defined($self->{'basedir'},    'Missing basedir!');
    assert_defined($report->{'basename'}, 'Missing basename!');

    push @{ $self->{'Instance'}->{'html'} }, qq{<div class=footer>Generated by Devel::CoverReport v$VERSION &copy; Bartłomiej Syguła</div>\n};
    push @{ $self->{'Instance'}->{'html'} }, qq{</body>\n};
    push @{ $self->{'Instance'}->{'html'} }, qq{</html>};

    my $report_filename = $self->{'basedir'} . q{/} . $report->{'basename'} . q{.html};

    write_file($report_filename, $self->{'Instance'}->{'html'});

    $self->{'Instance'}->{'html'} = undef;

    return $report_filename;
} # }}}

sub process_formatter_end { # {{{
    my ( $self ) = @_;

    return;
} # }}}

# Private methods, do not call from outside!

# reserved space ;)

# Private FUNCTIONS, do not call from outside!

sub _format_value { # {{{
    my ( $value, $header, $f_field ) = @_;

    if (ref $value eq 'ARRAY') {
        my @value_parts;
        foreach my $value_part (@{ $value }) {
            if (defined $value_part) {
                push @value_parts, _format_value($value_part, $header, $f_field);
            }
        }
        return join q{}, @value_parts;
    }
    elsif (ref $value eq 'HASH') {
        my $_prefix = q{<div};
        my $_sufix  = q{</div>};
        my $_class  = q{};

        my $_content;
        if (defined $value->{'v'}) {
            $_content = sprintf $header->{$f_field}, _html_quote($value->{'v'});
        }
        else {
            $_content = q{n/a};
        }

        if ($value->{'class'}) {
            $_class = q{ class=} . $value->{'class'};
        }
        if ($value->{'href'}) {
            my $_anchor = q{};
            if ($value->{'anchor'}) {
                $_anchor = q{#} . $value->{'anchor'};
            }

            $_prefix = q{<a href="} . $value->{'href'} . q{.html} . $_anchor . q{"};

            $_sufix  = q{</a>};
        }

        return $_prefix . $_class .q{>}. $_content . $_sufix;
    }
    elsif (defined $value) {
        return sprintf $header->{$f_field}, _html_quote($value);
    }

    # Last resort... ALWAYS well-defined output :)
    return q{n/a};
} # }}}

# Quick, dependency-free HTML-unsafe characters quotting.
sub _html_quote { # {{{
    my ( $string ) = @_;

    $string =~ s{&}{&amp;}sgi;
    $string =~ s{>}{&gt;}sgi;
    $string =~ s{<}{&lt;}sgi;

    $string =~ s{\t}{        }sgi;

    return $string;
} # }}}

1;

=head1 LICENCE

Copyright 2009-2011, Bartłomiej Syguła (perl@bs502.pl)

This is free software. It is licensed, and can be distributed under the same terms as Perl itself.

For more, see my website: http://bs502.pl/

=cut

__DATA__
body {
    font-family: sans-serif;
    font-size: 8pt;
    margin: 5px;
    color: #000;
}

table {
   border-collapse: collapse;
   border-spacing: 0px;
   margin: 5px 5px 15px 5px;
}
tr {
   text-align : center;
   vertical-align: top;
}
th, .head {
   background-color: #ccc;
   border: solid 1px #333;
   padding: 0em 0.2em;
}
td {
   border: solid 1px #ccc;
}
tr.summary,
tr.partial_summary {
   border-top: solid 1px #111;
}
tr.summary td,
tr.partial_summary td {
   text-align: left;
   border-top: solid 1px #111;
   background-color: #eee
}
tr.summary td.head,
tr.partial_summary td.head {
   text-align: center;
   border-top: solid 1px #111;
   background-color: #aaa
}
tr.partial_summary {
    color: #444;
}
.footer {
    margin: 5px;
    text-align: center;
    color: gray;
}

a:link, a:hover, a:active, a:visited {
    color: #000;
}

/* lines of source code */
.src {
    text-align: left;
    font-family: monospace;
    white-space: pre;
    padding: 1px;
    vertical-align: bottom;
}
/* file, directories and paths */
.file, .vcs {
    text-align: left;
    white-space: pre;
    padding: 0em 0.5em 0em 0.5em;
    font-family: monospace;
}

/* Classes for color-coding coverage information:
 *   c0  : not covered or coverage < 50%
 *   c1  : coverage >= 50%
 *   c2  : coverage >= 75%
 *   c3  : coverage >= 90%
 *   c4  : covered or coverage = 100%
 */
.c0, .c1, .c2, .c3, .c4 {
    display: block;
    text-align: right;
    padding: 0 1px;
    color: black;
}
.c0 {
	background-color: #f99;
	border: 1px solid #c00;
}
.c1 {
	background-color: #fa7;
	border: 1px solid #f71;
}
.c2 {
	background-color: #fc9;
	border: 1px solid #f93;
}
.c3 {
	background-color: #ff9;
	border: 1px solid #cc6;
}
.c4 {
	background-color: #9f9;
	border: 1px solid #090;
}

/*
vim: fdm=marker
*/
