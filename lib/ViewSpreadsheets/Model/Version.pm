use strict;
use warnings;

package ViewSpreadsheets::Model::Version;
use Jifty::DBI::Schema;

use ViewSpreadsheets::Record schema {
     column sdomain =>
        is mandatory,
        refers_to ViewSpreadsheets::Model::Domain;
     column filename =>
        type is 'text',
    #    render as 'Upload',
        is mandatory;
     column start_date =>
        type is 'datetime',
        render as 'DateTime';
     column end_date =>
        type is 'datetime',
        render as 'DateTime';
};

# Your model-specific methods go here.

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




