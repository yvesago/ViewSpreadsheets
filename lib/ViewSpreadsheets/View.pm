use warnings;
use strict;

package ViewSpreadsheets::View;
use Jifty::View::Declare -base;
use base qw/ Jifty::View::Declare::CRUD /;

foreach my $model ( Jifty->class_loader->models ) {
    my $bare_model;
    if ( $model =~ /^.*::(.*?)$/ ) {
        $bare_model = $1;
    };

    alias Jifty::View::Declare::CRUD under '/user/admin/' . $bare_model,
            { object_type => $bare_model };

    template '/user/admin/'.$bare_model. '-list' => sub {
        form {
            render_region(
                name => $bare_model . '-list',
                path => '/user/admin/' . $bare_model . '/list'
            );
        };
    };

};

=head2 template menu

render main menu as yui menubar

=cut

private template 'menu' => sub {
        Jifty->web->navigation->render_as_yui_menubar;
     p { ' ' };
};


template '/' => page {
    title is Jifty->config->framework('ApplicationName');
    hyperlink(label => "User",url => '/user');
    br {};
    hyperlink(label => "Admin",url => '/user/admin');
};

template '/user' => page {
    title is 'user page';
    my $dom = Jifty->web->session->get('Dom');
    if ($dom) {
        h2 { $dom->name };
        outs 'current_version';
        br {};
        outs 'search';
        br {};
        outs 'file';
    }
    else {
        show '/user/dom';
    };
};

template '/user/dom' => sub {
    h2 { 'Choose domain' };
    my $col = ViewSpreadsheets::Model::DomainCollection->new();
    $col->unlimit;
    while (my $d = $col->next ) {
         hyperlink ( label => $d->name, url => '/user/dom/'.$d->id );
         br {};
    };
};

=head2 Admin page

=cut

template '/user/admin' => page {
    title is 'Admin page';
    my $dom = Jifty->web->session->get('Dom');
    ($dom) ? h2 { $dom->name } :  show '/user/dom';

    br {};
    hyperlink(label => "Upload",url => '/user/admin/upload');
};

template '/user/admin/crud' => page {
        render_region( name => 'crud' );
};

template '/user/admin/upload' => page {
    title is 'Upload admin page';
    my $dom = Jifty->web->session->get('Dom');
    ($dom) ? h2 { $dom->name } :  show '/user/dom';
    show '/user/admin/filedesc';
    br {};
    render_region(name => 'new_version', path => '/user/admin/add_version');
};

private template '/user/admin/filedesc' => sub {
    my $dom = Jifty->web->session->get('Dom');
    my $fileDesc = $dom->filedesc;
    h3 { 'Structure du fichier' };
    outs 'nom : '; strong {$fileDesc->name };
    br {};
    outs 'Position des champs';
    table { attr { class => 'filedesc' };
     row {
        foreach my $label ( Jifty->app_class('Model','FileDesc')->readable_attributes ) {
            next if $label eq 'id' || $label eq 'name';
            th { $label };
        };
     };
     row {
        foreach my $label ( Jifty->app_class('Model','FileDesc')->readable_attributes ) {
            next if $label eq 'id' || $label eq 'name';
            cell { $fileDesc->$label };
        };
     };
    };
};

template '/user/admin/add_version' => sub {
    my $action = new_action(class => 'NewVersion');
    form {
        render_param($action,'upload');
        form_submit(label => _('Update'));
    };
};

1;
