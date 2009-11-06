use strict;
use warnings;

package ViewSpreadsheets::Model::User;
use Jifty::DBI::Schema;

use ViewSpreadsheets::Record schema {
    column 'user_role' =>
        valid_values are qw(admin user guest),
        default is 'user';
};

# Your model-specific methods go here.

use Jifty::Plugin::User::Mixin::Model::User;
#use Jifty::Plugin::Authentication::Ldap::Mixin::Model::User;
use Jifty::Plugin::Authentication::CAS::Mixin::Model::User;


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

