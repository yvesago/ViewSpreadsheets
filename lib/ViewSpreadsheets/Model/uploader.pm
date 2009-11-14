use strict;
use warnings;

package ViewSpreadsheets::Model::uploader;
use Jifty::DBI::Schema;

use ViewSpreadsheets::Record schema {
    column sdomain =>
        is mandatory,
        refers_to ViewSpreadsheets::Model::Domain;
    column people =>
        is mandatory,
        refers_to ViewSpreadsheets::Model::User;
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

