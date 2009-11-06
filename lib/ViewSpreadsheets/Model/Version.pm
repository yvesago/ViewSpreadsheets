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
        render as 'DateTime',
        is mandatory;
     column end_date =>
        type is 'datetime',
        render as 'DateTime';
};

# Your model-specific methods go here.

sub before_delete {
# TODO remove spreadsheet
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




