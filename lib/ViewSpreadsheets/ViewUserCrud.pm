use warnings;
use strict;

package ViewSpreadsheets::ViewUserCrud;
use Jifty::View::Declare -base;
use base qw/ Jifty::View::Declare::CRUD /;

=head1 NAME - ViewUserCrud

override some CRUD template for User model

=cut

=head2 teamplate view

override view to add a close button and subviews for one to many relation ship

=cut

template 'view' => sub {
    my $self   = shift;
    my $id = get('id');
    my $block = get('view_block')||0;
    return if (!$id);
    my $record = $self->_get_record( get('id') );

    my $update = $record->as_update_action(
        moniker => "update-" . Jifty->web->serial,
    );

    div {
        { class is 'crud read item inline' };
        my @fields = $self->display_columns($update);
        foreach my $field (@fields) {
            div { { class is 'view-argument-'.$field};
            render_param( $update => $field,  render_mode => 'read'  );
            }; 
        };
   #show ('./view_item_controls', $record, $update); 
    show ('../sub_list','uploader','people', $id);
    show ('./view_item_controls', $record, $update); 
     };
    hr {};

};


1;
