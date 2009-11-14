use strict;
use warnings;

package ViewSpreadsheets::Model::Spreadsheet;
use Jifty::DBI::Schema;

use ViewSpreadsheets::Record schema {
    column version =>
        refers_to ViewSpreadsheets::Model::Version;
    column line =>
        label is 'ligne XLS',
        type is 'int';
    column 'ref1' =>
        label is 'Réf. 1';
    column 'ref2' =>
        label is 'Réf. 2';
    column 'text1' =>
        label is 'Texte 1';
    column 'text2' =>
        label is 'Texte 2',
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
    column 'highlight' =>
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



