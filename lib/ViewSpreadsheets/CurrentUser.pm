package ViewSpreadsheets::CurrentUser;

use strict;
use warnings;

use base qw(Jifty::CurrentUser);

__PACKAGE__->mk_accessors(qw(group));

sub _init {
    my $self = shift;
    my %args = (@_);

    if (keys %args) {
        $self->user_object(ViewSpreadsheets::Model::User->new(current_user => $self));
        $self->user_object->load_by_cols(%args);

        if ( $self->user_object->user_role eq 'admin') {
            $self->is_superuser(1);
        };

        $self->group($self->user_object->user_role);
    };
    $self->SUPER::_init(%args);
};

1;
