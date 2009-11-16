use warnings;
use strict;

package ViewSpreadsheets::ViewCrudExtend;
use Jifty::View::Declare -base;
use base qw/ Jifty::View::Declare::CRUD /;

=head1 NAME - CrudExtend

=head1 SYNOPSIS

mount ViewCrudExtend in main View for your model
  Jifty::View::Declare::CRUD->mount_view('User','ViewSpreadsheets::ViewCrudExtend','/user/admin');

mount a custom view for your model
  Jifty::View::Declare::CRUD->mount_view('User','ViewSpreadsheets::ViewUserCrud','/user/admin/User/');

in the custom view overide the 'view' template to add

 show ('../sub_list','OneToManyClass','column_jointure', $id);

=head2 sub_view

show an inline compact view for an id

=cut

template 'sub_view' => sub {
    my $self   = shift;
    my $id = get('id');
    my $mask = get('mask');
    my $model_name = get('model_name');
    my $item_class = Jifty->app_class('Model',$model_name);
    my $record = $item_class->load( get('id') );

    my $update = $record->as_update_action(
        moniker => "update-" . Jifty->web->serial,
    );
    my $delete = $record->as_delete_action(
        moniker => 'delete-' . Jifty->web->serial,
    );

    if ( $record->current_user_can('update') ) {
        hyperlink(
            label   => _("E"),
            class   => "editlink",
            onclick => {
                replace_with => $self->fragment_for('sub_update'),
                args         => { id => $id, model_name => $model_name, mask => $mask }
            },
        );
    };

   # outs ' ';
   # div {
   #     { class is 'crud read item inline' };
        my @fields = $self->display_columns($update);
        foreach my $field (@fields) {
            next if $field =~ /(created|updated)_(on|by)$/ ;
            next if $field eq $mask || $field eq 'id';
           #outs_raw $record->render_action($field);
            eval { $record->$field->name };
            if ($@) { outs $record->$field; }
                else { outs $record->$field->name };
            #render_param( $update => $field,  render_mode => 'read'  );
           # outs_raw ( $update->form_field( $field, render_mode => 'read', class => 'inline' )->render_value  );
           #my $render = $update->form_field( $field );
           # outs_raw ( $render->canonicalize_value(Jifty->web->escape("@{[$render->current_value]}")  ) );
          # $self->canonicalize_value(Jifty->web->escape("@{[$self->current_value]}")) if defined $self->current_value;
           
            outs ' ';
        };
    #    show ('./view_item_controls', $record, $update); 
   # };
};

=head2 sub_list

show a compact list for 1 to many model

usage :

  show('/sub_list', 'UserFonction','people', $id);

=cut

private template 'sub_list' => sub {
    my $self = shift;
    my $model_name = shift;
    my $column = shift;
    my $id = shift;
#TODO try load_by_cols;
    my $collection = Jifty->app_class('Model',$model_name.'Collection')->new;#$model_class->_current_collection();
    $collection->limit(column => $column, value => $id);
    div { { class is 'sublist form_field inline'}
    span { { class is 'label text argument-name'} 
    outs $model_name; };
    span { { class is 'sublist-'.$model_name }
    #div { { class is 'sublist inline sublist-'.$model_name }
        while ( my $item = $collection->next) { 
            render_region(
                name     => $model_name.'-itemsub-' . $item->id,
                #path     => '/'.$model_name.'/sub_view',
                path     => '/user/admin/sub_view',
                defaults => { id => $item->id, object_type => $model_name, model_name => $model_name, mask => $column }
            );
        };
    };
    my $add_region = Jifty::Web::PageRegion->new(
        name => 'add-'.$model_name.'-'.$id,
        path => '/__jifty/empty'
    );

    hyperlink(
        onclick => [
            {   region       => $add_region->qualified_name,
                #replace_with => $self->fragment_for('search'),
                replace_with => '/user/admin/add_sub_item',
                toggle       => 1,
                args         => { model_name => $model_name, id => $id,  mask => $column }
            },
        ],
        label => '+',
        class => 'add_sub_item'
    ) if $self->record_class->new->current_user_can('create');

    outs( $add_region->render );

    #outs '||';
    };

};

=head2 add_sub_item

update a sub_view in sub_list region

=cut

template 'add_sub_item' => sub {
    my $self = shift;
    my $model_name = get('model_name');
    my $id = get('id');
    my $mask = get('mask');
    return if (!$model_name || ! $id);

    my $model_class = Jifty->app_class('Model',$model_name);
    my $action = $model_class->as_create_action;
   foreach my $field ($self->create_columns($action)) {
                ($field eq $mask) ?  render_param($action, $field, render_as => 'hidden', default_value => $id ) :
                    render_param($action, $field) ;
   }
        outs(
            Jifty->web->form->submit(
                label   => _('Add'),
                onclick => [
                    { submit       => $action },
                    { refresh_self => 1 },
                    {   element => Jifty->web->current_region->parent->get_element( 'span.sublist-'.$model_name),
                        append => $self->fragment_for('sub_view'),
                        args   => {
                            model_name => $model_name,
                            mask => $mask,
                            id => { result_of => $action, name => 'id' },
                        },
                    },
                ]
            )
        );

#   show ('./new_item_controls', $action); 
};

=head2 sub_update

an update view with some cached fields

=cut

template 'sub_update' => sub {
    my $self = shift;
    my $object_type = get('model_name');
    my $id = get('id');
    my $mask = get('mask');

    my $record_class =  Jifty->app_class('Model',$object_type); #->record_class;
    my $record = $record_class->new();
    $record->load($id);
    my $update = $record->as_update_action(
        moniker => "update-" . Jifty->web->serial,
    );

    div {
        { class is "crud update item inline " . $object_type }

        show('./edit_subitem', $update, $mask );
        show('./edit_subitem_controls', $record, $update, $mask);

        hr {};
    }
};

private template 'edit_subitem' => sub {
    my $self = shift;
    my $action = shift;
    my $mask = shift;
   foreach my $field ($self->edit_columns($action)) {
	   next if $field =~ /(created|updated)_(on|by)$/ ;
            div { { class is 'update-argument-'.$field}
                ($field eq $mask) ?  render_param($action, $field, render_as => 'hidden' ) :
                    render_param($action, $field) ;
        }
   }
};



private template edit_subitem_controls => sub {
    my $self = shift;
    my $record = shift;
    my $update = shift;
    my $mask = shift;

    my $object_type = $self->object_type;
    my $id = $record->id;

    my $delete = $record->as_delete_action(
        moniker => 'delete-' . Jifty->web->serial,
    );
        div {
            { class is 'crud editlink' };
            hyperlink(
                label   => _("Save"),
                onclick => [
                    { submit => $update },
                    {   replace_with => $self->fragment_for('sub_view'),
                        args => { object_type => $object_type, id => $id, mask => $mask }
                    }
                ]
            );
            hyperlink(
                label   => _("Cancel"),
                onclick => {
                    replace_with => $self->fragment_for('sub_view'),
                    args         => { object_type => $object_type, id => $id }
                },
                as_button => 1,
                class     => 'cancel'
            );
            if ( $record->current_user_can('delete') ) {
                $delete->button(
                    label   => _('Delete'),
                    onclick => {
                        submit  => $delete,
                        confirm => _('Really delete?'),
                        refresh => Jifty->web->current_region->parent,
                    },
                    class => 'delete'
                );
            }
        };

};

1;
