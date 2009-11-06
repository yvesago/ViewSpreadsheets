use strict;
use warnings;

package ViewSpreadsheets::Model::Spreadsheet;
use Jifty::DBI::Schema;

use ViewSpreadsheets::Record schema {
    column version =>
        refers_to ViewSpreadsheets::Model::Version;
    column name =>
        is mandatory;
    column 'ref1' ;
    column 'plabel' ;
    column 'refplabel';
    column 'pdesc' =>
        render as 'textarea',
        type is 'text';    
    column 'pp';
    column 'rate';
    column 'price';
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



