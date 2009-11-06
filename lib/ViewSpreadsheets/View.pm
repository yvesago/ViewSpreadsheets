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

    alias Jifty::View::Declare::CRUD under '/admin/' . $bare_model,
            { object_type => $bare_model };

    template '/admin/'.$bare_model. '-list' => sub {
        form {
            render_region(
                name => $bare_model . '-list',
                path => '/admin/' . $bare_model . '/list'
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
             hyperlink(label => "Admin",url => '/admin');
};

template '/admin/crud' => page {
        render_region( name => 'crud' );
};

template '/admin' => page {
    title is 'admin page';
    render_region(name => 'new_version', path => '/admin/add_version');
};

template '/admin/add_version' => sub {
    my $action = new_action(class => 'NewVersion');
    form {
        render_action($action);
        form_submit(label => _('Update'));
    };
};

1;
