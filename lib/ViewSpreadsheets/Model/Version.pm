use strict;
use warnings;

package ViewSpreadsheets::Model::Version;
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
        type is 'datetime',
        filters are 'Jifty::DBI::Filter::DateTime',
        render as 'DateTime';
     column end_date =>
        label is 'Date de fin',
        type is 'datetime',
        filters are 'Jifty::DBI::Filter::DateTime',
        render as 'DateTime';
};

# Your model-specific methods go here.

sub validate_start_date {
     my $self      = shift;
     my $new_value = shift;
     return ( 0, 'Format de date faux ou incomplet' )
      if ($new_value !~ m/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/);
     return 1;
};


sub before_delete {
    my $self = shift;

    # remove spreadsheet
    my $FileContent = ViewSpreadsheets::Model::SpreadsheetCollection->new();
    $FileContent->limit(column => 'version', value => $self->id);
    while (my $line = $FileContent->next) {
        $line->delete;
    };

    # clear session
    Jifty->web->session->set('Version' => undef);

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
    # allow uploader
    my $dom = Jifty->web->session->get('Dom');
    return 1
        if $dom && $dom->is_uploader;

    return $self->SUPER::current_user_can($type, @_);

};


1;
