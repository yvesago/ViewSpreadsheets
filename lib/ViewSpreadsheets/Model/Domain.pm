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
    column msg =>
        label is 'Message',
        render_as 'Jifty::Plugin::WikiToolbar::Textarea',
        type is 'text';
};

# Your model-specific methods go here.

sub before_delete {
    my $self = shift;

    # remove offers
    my $offers = ViewSpreadsheets::Model::OfferCollection->new();
    $offers->limit(column => 'sdomain', value => $self->id);
    while (my $offer = $offers->next ) { $offer->delete; };
    # remove versions
    my $versions = ViewSpreadsheets::Model::VersionCollection->new();
    $versions->limit(column => 'sdomain', value => $self->id);
    while (my $ver = $versions->next ) { $ver->delete; };
    # remove uploaders
    my $uploaders = ViewSpreadsheets::Model::uploaderCollection->new();
    $uploaders->limit(column => 'sdomain', value => $self->id);
    while (my $up = $uploaders->next ) { $up->delete; };

    # clear session
    Jifty->web->session->set('Dom' => undef);

    return 1;
};

=head2 is_uploader

return value if current user is uploader for this domain

=cut

sub is_uploader {
    my $self = shift;
    my $uploader = ViewSpreadsheets::Model::uploaderCollection->new();
    $uploader->limit(column => 'sdomain', value => $self->id);
    $uploader->limit(column => 'people', value => Jifty->web->current_user->id);
    return $uploader->count;
};

=head2 current_offers

return a collection of current_offers

=cut

sub current_offers {
    my $self = shift;
    my $reftime = Jifty->web->session->get('RefTime') || Jifty::DateTime->now;
    my $col = ViewSpreadsheets::Model::OfferCollection->new();
       $col->limit(column => 'sdomain', value => $self->id);
       $col->limit(column => 'start_date', value => $reftime, operator => '<');
       $col->limit(column => 'end_date', value => $reftime, operator => '>');

    return $col;
};

=head2 current_version

return today current version

=cut

sub current_version {
    my $self = shift;
    my $reftime = Jifty->web->session->get('RefTime') || Jifty::DateTime->now;
    my $ver = ViewSpreadsheets::Model::VersionCollection->new();
       $ver->limit(column => 'sdomain', value => $self->id);
       $ver->limit(column => 'start_date', value => $reftime, operator => '<');
       $ver->order_by(column => 'start_date', order=> 'DESC');
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

