use strict;
use warnings;

package ViewSpreadsheets::Model::Offer;
use Jifty::DBI::Schema;

use ViewSpreadsheets::Record schema {
     column sdomain =>
        is mandatory,
        label is 'Domaine',
        refers_to ViewSpreadsheets::Model::Domain;
     column filename =>
        label is 'Fichier',
        type is 'text',
    #    render as 'Upload',
        is mandatory;
     column start_date =>
        label is 'Date de début',
        is mandatory,
        type is 'datetime',
        filters are 'Jifty::DBI::Filter::DateTime',
        render as 'DateTime';
     column end_date =>
        label is 'Date de fin',
        is mandatory,
        type is 'datetime',
        filters are 'Jifty::DBI::Filter::DateTime',
        render as 'DateTime';
    column msg =>
        label is 'Message',
        render_as 'Jifty::Plugin::WikiToolbar::Textarea',
        type is 'text';
};

# Your model-specific methods go here.

sub validate_start_date {
     my $self      = shift;
     my $new_value = shift;
     return ( 0, 'Format de date faux ou incomplet' )
      if ($new_value !~ m/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/);
     return 1;
};

sub validate_end_date {
     my $self      = shift;
     my $new_value = shift;
     return ( 0, 'Format de date faux ou incomplet' )
      if ($new_value !~ m/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/);
     return 1;
};


=head2 current_user_can

=cut

sub current_user_can {
    my $self = shift;
    my $type = shift;
    my %args = (@_);

    return 1 if
          $self->current_user->is_superuser;
    return 1
        if ($type eq 'read');

    return $self->SUPER::current_user_can($type, @_);

};


1;
