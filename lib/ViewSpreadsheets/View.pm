use warnings;
use strict;

package ViewSpreadsheets::View;
use Jifty::View::Declare -base;
use base qw/ Jifty::View::Declare::CRUD /;

my @fields = qw( ref1 plabel refplabel pdesc pp rate price );

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
    ($dom) ? h2 { $dom->name } :  show '/user/dom';
    my $version = Jifty->web->session->get('Version');
    if (!$version) {
        show '/user/version';
        return;
    };
    if ($dom) {
        strong { 'Version : '}; outs ( $version->start_date || 'Test');
        br {};
        strong { 'Télécharger : ' }; hyperlink(label =>  $version->filename, url => '/files/'. $version->filename);
        br {};
        br {};
        my $search = new_action(class => 'SearchSpreadsheet', moniker => 'search');
        form {
            render_param($search,'contains');
            $search->button(
                label   => _('Search'),
                onclick => {
                    submit  => $search,
                    refresh => 'filecontent',
                    args    => { page => 1 }
                }
            );

        };
        br {};
        render_region(name => 'filecontent', path => '/user/filecontent');
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

template '/user/version' => sub {
    h3 { 'Versions disponibles' };
    my $dom = Jifty->web->session->get('Dom');
    my $col = ViewSpreadsheets::Model::VersionCollection->new();
    $col->limit(column => 'sdomain', value => $dom->id) ;
    $col->limit(column => 'start_date', value => undef, operator => 'not') ;
    while (my $v = $col->next ) {
         hyperlink ( label => $v->start_date, url => '/user/version/'.$v->id );
         br {};
    };
};

=head2 Admin page

=cut

template '/user/admin' => page {
    title is 'Admin page';
    my $dom = Jifty->web->session->get('Dom');
    ($dom) ? h2 { $dom->name } :  show '/user/dom';
    show '/user/version';
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
    return if (!$dom);
    my $version = Jifty->web->session->get('Version');
    Jifty->web->session->set('Version' => undef)
        if ($version && $version->start_date);
    show '/user/admin/filedesc';
    br {};
    render_region(name => 'filecontent', path => '/user/filecontent');
    br {};
    render_region(name => 'new_version', path => '/user/admin/add_version');
};

template '/user/filecontent' => sub {
    my $version = Jifty->web->session->get('Version');

    return if !$version;

    my $page = get('page') || 1;
    my $sort = get('Sort') || '';
    my $session_sort = Jifty->web->session->get('Sort') || '';
    my($sort_by,$order); 
    
    if ( $session_sort =~ m/(.*?)-(ASC|DESC)$/) {
        $sort_by=$1;$order=$2; };
    
    if ($sort) {
        $sort_by = $sort;
        if (!$order) {
            $order = 'ASC';
            Jifty->web->session->set('Sort'=>$sort.'-ASC');
        } 
        elsif ( $order eq 'ASC') {
            $order = 'DESC';
            Jifty->web->session->set('Sort'=>$sort.'-DESC');
        }
        elsif ( $order eq 'DESC') {
            $order = '';
            $sort_by = '';
            Jifty->web->session->set('Sort'=>undef);
        };
    };

    my $search = ( Jifty->web->response->result('search') ? Jifty->web->response->result('search')->content('search') : undef );
    my $FileContent = $search || ViewSpreadsheets::Model::SpreadsheetCollection->new();
    $FileContent->limit(column => 'version', value => $version->id);
    $FileContent->order_by(column => $sort_by, order=> $order) if ($sort_by && $order);

    $FileContent->set_page_info(
        current_page => $page,
        per_page => 5,
    );

    if ($FileContent->pager->last_page > 1) {
        div { attr { class => 'nav_content'};
        hyperlink ( label => '<', onclick => { args => {page => $FileContent->pager->previous_page, Sort => ''} } )
            if ($FileContent->pager->previous_page);
            outs '::';
        for my $p ( 1 .. $FileContent->pager->last_page) {
        ($p == $page) ? strong { $p } :
            hyperlink ( label => $p, onclick => { args => {page => $p, Sort => ''} } );
            outs '::';
        };
        hyperlink ( label => '>', onclick => { args => {page => $FileContent->pager->next_page, Sort => ''} } )
            if ($FileContent->pager->next_page);
        };
    };


#    strong {$sort};outs '___'; strong {Jifty->web->session->get('Sort');};
#    br{};
#    outs $FileContent->build_select_query;
    table { attr { class => 'content' };
        row {
            foreach my $cell (@fields) {
                th {
                if ( $sort_by && $cell eq $sort_by ) {
                    strong {hyperlink ( label =>$cell, onclick => { args => {Sort=>$cell}});};
                    my $img = ($order eq 'ASC')?'up':'down';
                    img { attr { src => '/img/bullet_arrow_'.$img.'.png' }; };
                }
                else {
                    hyperlink ( label =>$cell, onclick => { args => {Sort=>$cell}});
                };
                    };
            };
        };
    my $i=0;
    while ( my $line = $FileContent->next ) {
        $i++;
        row {
            foreach my $cell (@fields) {
                cell { attr { class => 'l'.$i%2}; outs $line->$cell};
            };
        };
    };
    };


};

private template '/user/admin/filedesc' => sub {
    my $dom = Jifty->web->session->get('Dom');
    my $fileDesc = $dom->filedesc;
    h3 { 'Structure du fichier' };
    outs 'Type : '; strong {$fileDesc->name };
    br {};
    outs 'Position des champs';
    table { attr { class => 'filedesc' };
     row {
        foreach my $label ( @fields ) {
            th { $label };
        };
     };
     row {
        foreach my $label ( @fields ) {
            my $pos = 'pos_'.$label;
            cell { $fileDesc->$pos };
        };
     };
    };
};

template '/user/admin/add_version' => sub {
    my $version = Jifty->web->session->get('Version');
    my $dom = Jifty->web->session->get('Dom');
    my $action = new_action(class => 'NewVersion');
    form {
        render_param($action,'domain', render_as => 'hidden', default_value =>$dom->id);
        if (!$version) {
            render_param($action,'file');
            form_submit(label => _('Save'));
        }
        else {
            strong {'Ajoutez une date de début pour valider ce fichier'};
            render_param($action,'update_id', render_as => 'hidden', default_value =>$version->id);
            render_param($action,'start_date');
            render_param($action,'end_date');
            form_submit(label => 'Valider');
        };
    };

    return if (!$version);

    my $delete = new_action(class => 'DeleteVersion', record => $version);
    form {
        render_action($delete);
        form_submit(label => _('Delete'));
    };
};

1;
