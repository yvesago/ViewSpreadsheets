use strict;
use warnings;

package ViewSpreadsheets;

use Text::Markdown 'markdown';

=head1 NAME 

ViewSpreadsheets - access and view spreadsheets

=head1 DESCRIPTION

=head2 myprint

clean markdown output

=cut

sub myprint {
    my $text = shift;
    return if ( !$text );

    my $mytext = markdown($text);

    # I prefer a compact style
    $mytext =~ s/\n/<BR>/g;
    $mytext =~ s/<(\S+?)>(?:<BR>)+/<$1>\n/gi;

    return $mytext;
};

=head2 mydate

parse a datetime return a jifty::datetime usable with strftime

=cut

sub mydate {
  my $date  = shift;
  my $dt;

  if ( $date =~ m/^(\d{4})-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)$/ ) {
        $dt = Jifty::DateTime->new(
            year   => $1,
            month  => $2,
            day    => $3,
            hour => $4,
            minute => $5,
            second => $6,
            time_zone => 'Europe/Paris',
        );
    }
    else {
        warn "can't parse date from ", $date;
    }

  return $dt;
};


=head1 AUTHOR

Yves Agostini, C<< <agostini@univ-metz.fr> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2009 Universite Paul Verlaine - Metz. 

This program is free software and may be modified or distributed under the same terms as Perl itself.

=cut

1;

