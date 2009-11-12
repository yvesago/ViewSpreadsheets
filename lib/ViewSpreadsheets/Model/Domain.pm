use strict;
use warnings;

package ViewSpreadsheets::Model::Domain;
use Jifty::DBI::Schema;

use ViewSpreadsheets::Record schema {
    column name =>
        label is 'Fournisseur - march� - lot',
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

=head2 show_fields

return array of fields name by original xls position, start with 'line' the xls position

=cut

sub show_fields {
    my $self = shift;
    my @fields_name = qw(line);
    my %order = ();
    foreach my $field ( qw( ref1 ref2 text1 text2 pp rate price ) ) {
        my $fname = 'pos_'.$field;
        $order{$self->filedesc->$fname} = $field
            if $self->filedesc->$fname;
    };
    foreach my $pos (sort keys %order) {
        push @fields_name, $order{$pos};
    };
    return @fields_name;
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

