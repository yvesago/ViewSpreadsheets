use strict;
use warnings;

package ViewSpreadsheets::Model::Spreadsheet;
use Jifty::DBI::Schema;

use ViewSpreadsheets::Record schema {
    column version =>
        refers_to ViewSpreadsheets::Model::Version;
    column 'ref1' =>
        label is 'Réf. 1';
    column 'plabel' =>
        label is 'Label';
    column 'refplabel' =>
        label is 'Réf. 2';
    column 'pdesc' =>
        label is 'Description',
        render as 'textarea',
        type is 'text';    
    column 'pp' =>
        type is 'float',
        label is 'Prix public';
    column 'rate' =>
        type is 'float',
        label is 'Remise';
    column 'price' =>
        type is 'float',
        label is 'Prix';
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



