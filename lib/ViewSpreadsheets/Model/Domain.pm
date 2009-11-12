use strict;
use warnings;

package ViewSpreadsheets::Model::Domain;
use Jifty::DBI::Schema;

use ViewSpreadsheets::Record schema {
    column name =>
        label is 'Fournisseur - marché - lot',
        is mandatory;
    column filedesc =>
        refers_to ViewSpreadsheets::Model::FileDesc;

};

# Your model-specific methods go here.

sub before_delete {
    # TODO: remove version
};

=head2 current_version

return today current version

=cut

sub current_version {
    my $self = shift;
    my $ver = ViewSpreadsheets::Model::VersionCollection->new();
       $ver->limit(column => 'sdomain', value => $self->id);
       $ver->limit(column => 'start_date', value => Jifty::DateTime->now, operator => '<');
    return $ver->first || undef;
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

