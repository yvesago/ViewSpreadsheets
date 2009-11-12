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


=head1 AUTHOR

Yves Agostini, C<< <agostini@univ-metz.fr> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2009 Universite Paul Verlaine - Metz. 

This program is free software and may be modified or distributed under the same terms as Perl itself.

=cut

1;

