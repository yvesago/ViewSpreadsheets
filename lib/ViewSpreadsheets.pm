use strict;
use warnings;

package ViewSpreadsheets;

use Text::Markdown 'markdown';

=head1 NAME 

ViewSpreadsheets - access and view spreadsheets

=head1 DESCRIPTION


=cut

sub start {
    my $self = shift;
    Jifty->web->add_javascript(
    qw(
    jquery.colorPicker.js
    datetimefr.js
    )
    );
};


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

=head2 conv2ascii

 convert accent character to ascii

=cut

sub conv2ascii {
 my ($self,$string) = @_;
 return unac_string('latin1',$string);
};

=head2 clean_file_name


=cut

use Text::Unaccent;

sub clean_file_name {
    my $self = shift;
    my $string = shift;
    $string=~s/[ ']/-/g;
    $string=~s/#/Sharp/g;
    $string=$self->conv2ascii($string);
    $string=~s/[^A-Za-z0-9>\-_]//g;
    return $string;
};

=head1 AUTHOR

Yves Agostini, C<< <agostini@univ-metz.fr> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2009 Universite Paul Verlaine - Metz. 

This program is free software and may be modified or distributed under the same terms as Perl itself.

=cut

1;

