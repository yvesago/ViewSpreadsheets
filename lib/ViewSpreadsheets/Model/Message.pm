use strict;
use warnings;

package ViewSpreadsheets::Model::Message;
use Jifty::DBI::Schema;

use ViewSpreadsheets::Record schema {
    column 'publicmsg' =>
        label is 'Accueil',
        hints is 'Message affiché en page d\'accueil publique',
        render_as 'Jifty::Plugin::WikiToolbar::Textarea',
        type is 'text';
};

# Your model-specific methods go here.

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

