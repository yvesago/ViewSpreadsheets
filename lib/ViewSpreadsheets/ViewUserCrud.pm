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
    my $record = $self->_get_record( get('id') );

    return unless $record->id;
    my $update = $record->as_update_action(
        moniker => "update-" . Jifty->web->serial,
    );

    #my @fields = $self->display_columns($update);
    my @fields = $self->display_columns();
    foreach my $field (@fields) {
        div { { class is 'crud-field view-argument-'.$field};
         $self->render_field(
                        mode   => 'view',
                        action => $update,
                        field  => $field,
                        label  => '',
                    );
        };
    };
    div { { class is 'crud-field view-argument-uploader'};
     show ('../sub_list','uploader','people', $id);
    };
    div { { class is 'crud-field view-argument-uploader'};
        show ('./view_item_controls', $record, $update);
    };

};


1;
