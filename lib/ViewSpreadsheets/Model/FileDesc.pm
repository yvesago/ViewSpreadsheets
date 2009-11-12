use strict;
use warnings;

package ViewSpreadsheets::Model::FileDesc;
use Jifty::DBI::Schema;

use ViewSpreadsheets::Record schema {
    column name =>
        is mandatory;
    column pos_ref1 =>
        type is 'int';
    column pos_ref2 =>
        type is 'int';
    column pos_text1 =>
        label is 'position label',
        type is 'int';
    column pos_text2 =>
        label is 'position desc',
        type is 'int';    
    column pos_pp =>
        type is 'int';
    column pos_rate =>
        type is 'int';
    column pos_price =>
        type is 'int';

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


