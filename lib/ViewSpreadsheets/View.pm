use warnings;
use strict;

package ViewSpreadsheets::View;
use Jifty::View::Declare -base;
use base qw/ Jifty::View::Declare::CRUD /;

my $lang = Jifty::I18N->get_current_language || 'fr'; Jifty::DateTime->DefaultLocale($lang);
  Jifty::View::Declare::CRUD->mount_view('User','ViewSpreadsheets::ViewCrudExtend','/user/admin');

  Jifty::View::Declare::CRUD->mount_view('User','ViewSpreadsheets::ViewUserCrud','/user/admin/User/');

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
    br {};
    my $msg = ViewSpreadsheets::Model::Message->new();
    $msg->load(1);
    outs_raw ViewSpreadsheets::myprint($msg->publicmsg);
    br{};
    hyperlink(label => "Consulter",url => '/user');
    br {};
};

template '/user' => page {
    my $dom = Jifty->web->session->get('Dom');
    my $version = Jifty->web->session->get('Version');
    if ($dom) {
        title is $dom->name;  
    }
    else {  show '/user/dom'; };
    
    div { attr { class => 'leftcol' };
        if ($version && $version->start_date) {
          if ($dom->current_version && $version->id == $dom->current_version->id) {
              my $reftime = Jifty->web->session->get('RefTime');
              ($reftime) ?
                  strong { ViewSpreadsheets::mydate($reftime)->strftime("%A %d %b %Y %H:%M:%S") }:
                  strong { 'Version courante' };
              br {};
          };
          strong { 'Version : '};
          outs ( $version->start_date->strftime("%a %d %b %Y %H:%M:%S") || 'Test');
          if ( $version->end_date ) {
              br {}; br {};
              strong { attr {class => 'red'}; 'ATTENTION : ' };
              outs 'expire le '. $version->end_date->strftime("%a %d %b %Y %H:%M:%S");
          };
        };
        br{};
        br{};
        show '/user/choose_date' if ($dom || $version);
        if (Jifty->web->current_user->group eq 'admin' || ($dom && $dom->is_uploader)) {
            br {};
            div{ attr { class => 'info-admin'};
                strong { 'admin : ' };
                outs 'visu versions dispo.';
                br {}
                strong { attr {class => 'red'}; 'ATTENTION : ' };
                outs 'ne pas tenir compte des offres';
                show '/user/version_menu';
                br{}; br{};
                br{}; br{};
            };
        };

    };
    div { attr { class => 'rightcol' };
        if ($dom && $dom->msg) {
            outs_raw ViewSpreadsheets::myprint($dom->msg); br{};
        };
        my $offers = $dom->current_offers if ($dom);
        if ($offers && $offers->count) {
        strong { 'Offres promotionnelles'};
            ul {
                while (my $offer = $offers->next) {
                    li {
                    if ($offer->msg) { outs_raw ViewSpreadsheets::myprint($offer->msg); br{};};
                    div { attr {class => 'download' };
                        img { attr { src => '/img/download-offre.png' }; };
                        strong { 'Télécharger : ' }; hyperlink(label =>  $offer->filename, url => '/files/'. $offer->filename);
                    };
                    outs 'Valable du '.$offer->start_date->strftime("%a %d %b %Y %H:%M:%S").' au '.
                        $offer->end_date->strftime("%a %d %b %Y %H:%M:%S");
                    };
                };
            };
        };
        strong {'BPU'};
        if ($version) {
            div { attr {class => 'download' };
                img { attr { src => '/img/download.png' }; };
                strong { 'Télécharger : ' }; hyperlink(label =>  $version->filename, url => '/files/'. $version->filename);
            };
            show '/user/file_search';
            render_region(name => 'filecontent', path => '/user/filecontent');
            show '/user/choose_nblines';
        };
    };
};

private template '/user/choose_date' => sub {
    my $action = new_action('TimeMachine');
    outs 'Changer de version' ;
    if (Jifty->web->session->get('RefTime') ) {
        form {
            render_param($action,'today',default_value => 1);
            form_submit(label => 'Aujourd\'hui');
        };
    }
    else {
        br {}; };
    outs 'à cette date :';
    form {
        render_action($action);
        form_submit(label => 'Valider');
    };
};

template '/user/dom' => sub {
    h2 { 'Choisissez un lot :' };
    my $col = ViewSpreadsheets::Model::DomainCollection->new();
    $col->unlimit;
    while (my $d = $col->next ) {
         hyperlink ( label => $d->name, url => '/user/dom/'.$d->id );
         br {};
    };
};

template '/user/dom_menu' => sub {
    my $self = shift;
    my $from = shift;
    my $top = Jifty->web->{navigation} = Jifty::Web::Menu->new( label => 'Domaines' );
    my $col = ViewSpreadsheets::Model::DomainCollection->new();
    $col->unlimit;

    while ( my $d = $col->next ) {
        $top->child( $d->name => link => Jifty::Web->link(
          label => $d->name, url => '/user/dom/'.$d->id )->as_string);
    };

    Jifty->web->navigation->render_as_context_menu;
    br {};
};


template '/user/version' => sub {
    my $dom = Jifty->web->session->get('Dom');
    return if (!$dom);
    h3 { 'Versions disponibles' };
    my $col = ViewSpreadsheets::Model::VersionCollection->new();
    $col->limit(column => 'sdomain', value => $dom->id) ;
    $col->limit(column => 'start_date', value => '', operator => '!=') ;
    $col->order_by(column => 'start_date', order=> 'DESC');
    while (my $v = $col->next ) {
        my $label = $v->start_date->strftime("%a %d %b %Y %H:%M:%S");
        $label .= ' *' if ( $dom->current_version && $v->id == $dom->current_version->id );
         hyperlink ( label => $label, url => '/user/version/'.$v->id );
         br {};
    };
};

template '/user/version_menu' => sub {
    my $dom = Jifty->web->session->get('Dom');
    return if (!$dom);
    my $top = Jifty->web->{navigation} = Jifty::Web::Menu->new( label => 'Versions' );
    my $col = ViewSpreadsheets::Model::VersionCollection->new();
    $col->limit(column => 'sdomain', value => $dom->id) ;
    $col->limit(column => 'start_date', value => '', operator => '!=') ;
    $col->order_by(column => 'start_date', order=> 'DESC');
    while (my $v = $col->next ) {
        my $date = $v->start_date->strftime("%a %d %b %Y");
        $date .= ' *' if ($dom->current_version && $v->id == $dom->current_version->id);
        $top->child(  $date => link => Jifty::Web->link(
          label => $date, url => '/user/version/'.$v->id )->as_string );
    };
    Jifty->web->navigation->render_as_context_menu;
    br {};
};

=head2 Admin page

=cut

template '/user/admin' => page {
    title is 'Admin page';
    my $dom = Jifty->web->session->get('Dom');
    if ($dom) {
        h2 { show '/user/dom_menu'; outs $dom->name; }; 
        br {};
        show '/user/version';
    }
    else {  show '/user/dom'; };
    br {};
    hyperlink(label => "Upload",url => '/user/admin/upload');
};

template '/user/admin/crud' => page {
        render_region( name => 'crud' );
};

template '/user/admin/offer' => page {
    my $dom = Jifty->web->session->get('Dom');
    title is 'Offre promotionnelle pour '.$dom->name;
    div { attr { class => 'leftcol' };
        show '/user/dom_menu';
        br {};
        br {};
    };
    div { attr { class => 'rightcol' };
        my $action = new_action(class => 'NewOffer');
        form {
            render_param($action,'domain', render_as => 'hidden', default_value =>$dom->id);
            render_param($action,'start_date');
            render_param($action,'end_date');
            render_param($action,'file');
            render_param($action,'msg');
            form_submit(label => _('Save'));
            };
    };
};

template '/user/admin/upload' => page {
    my $dom = Jifty->web->session->get('Dom');
    #return if (!$dom);
    title is 'Upload '.$dom->name;
    my $version = Jifty->web->session->get('Version');
    Jifty->web->session->set('Version' => undef)
        if ($version && $version->start_date);
    Jifty->web->session->set(Search => undef);
    div { attr { class => 'leftcol' };
        show '/user/dom_menu';
        br {};
        br {};
        strong { '2 étapes :' };
        ul {
            li { 'uploader le fichier, vérifier que les données sont cohérentes' };
            li { 'Mettre une date de début, pour valider le fichier' };
        };
        br {};
        strong { 'En cas de problème' };
        ul {
            li { strong { 'Effacer données' }; outs ' pour effacer les données testées. Le fichier n\'est pas effacé mais sera écrasé par un fichier de même nom.'; }
            li { outs 'Créer un nouveau domaine et un nouveau type de fichier dans les tables Domain et FileDesc';};
            li { outs 'Effacer dans la table Version les versions sans date de début : c\'est des tests non effacés' };
        };
    };
    div { attr { class => 'rightcol' };
        render_region(name => 'new_version', path => '/user/admin/add_version');
        br {};
        show '/user/admin/filedesc';
        hr {};
        if ($version) {
            h2 { 'Vérifiez le fichier importé' };
            show '/user/file_search';
            render_region(name => 'filecontent', path => '/user/filecontent');
            show '/user/choose_nblines';
        };
    };
};

private template '/user/file_search' => sub {
        br {};
        my $search = new_action(class => 'SearchSpreadsheet', moniker => 'search');
        form {
            #render_action($search);
            render_param($search,'contains');
            render_param($search,'price_dwim');
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

    my $search = Jifty->web->session->get('Search') || undef;
    if ( Jifty->web->response->result('search') ) {
       $search = Jifty->web->response->result('search')->content('search');
       Jifty->web->session->set(Search => $search);
       };

    my $FileContent = $search || ViewSpreadsheets::Model::SpreadsheetCollection->new();
    $FileContent->limit(column => 'version', value => $version->id);
    $FileContent->order_by(column => $sort_by, order=> $order) if ($sort_by && $order);

    $FileContent->set_page_info(
        current_page => $page,
        per_page => Jifty->web->session->get('NBlines') || 30,
    );

    outs 'Éléments : '; strong{ $FileContent->count }; br {};
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
            my $smodel_action=new_action(class => 'CreateSpreadsheet');
            foreach my $cell ($version->sdomain->show_fields()) {
                th {
                if ( $sort_by && $cell eq $sort_by ) {
                    strong {hyperlink ( label =>$smodel_action->form_field($cell)->label, onclick => { args => {Sort=>$cell}});};
                    my $img = ($order eq 'ASC')?'up':'down';
                    img { attr { src => '/img/bullet_arrow_'.$img.'.png' }; };
                }
                else {
                    hyperlink ( label =>$smodel_action->form_field($cell)->label, onclick => { args => {Sort=>$cell}});
                };
                    };
            };
        };
    my $i=0;
    while ( my $line = $FileContent->next ) {
        $i++;
        row {
            foreach my $cell ($version->sdomain->show_fields()) {
                my $class = ($line->highlight)?'highlight-'.$line->highlight:'l'.$i%2;
                cell { attr { class => $class}; outs $line->$cell};
            };
        };
    };
    };

  br{};
};

private template '/user/choose_nblines' => sub {
    my $action = new_action('ChgNbLines');
    form  {
        render_param($action,'nblines', default_value => Jifty->web->session->get('NBlines') || 30);
         hyperlink ( label => 'Modifier',
            onclick => [
                { submit => $action },
                { refresh => 'filecontent'}
                ] );
    };
};

private template '/user/admin/filedesc' => sub {
    my $dom = Jifty->web->session->get('Dom');
    my $fileDesc = $dom->filedesc;
    strong { 'Structure du fichier' };
    br {}; outs 'Type : '; strong {$fileDesc->name };
    br {};
    outs 'Position des champs';
    table { attr { class => 'filedesc' };
     row {
        foreach my $label ( $dom->show_fields() ) {
            next if $label eq 'line';
            th { $label };
        };
     };
     row {
        foreach my $label ( $dom->show_fields() ) {
            next if $label eq 'line';
            my $pos = 'pos_'.$label;
            cell { $fileDesc->$pos };
        };
     };
    };
    if ( $fileDesc->exclude_line_pos || $fileDesc->exclude_line_color ) {
        outs 'Exlusions des lignes ';
        outs ' de la colone '.$fileDesc->exclude_line_pos.' ' if $fileDesc->exclude_line_pos;
        if ( $fileDesc->exclude_line_color ) {
         span { attr { style => 'background-color: '.$fileDesc->exclude_line_color.';' };
            outs ' de couleur '; }; br {};
            };
    };
    if ( $fileDesc->high1_render ne 'no') {
        span { attr { class => 'highlight-'.$fileDesc->high1_render };
            outs ' highligh '; };
            outs ' des lignes ';
            outs ' de la colone '.$fileDesc->high1_pos if $fileDesc->high1_pos;
         if ($fileDesc->high1_color) {
         span { attr { style => 'background-color: '.$fileDesc->high1_color.';' };
            outs ' de couleur '; }
         };
    };
    if ( $fileDesc->high2_render ne 'no') {
        span { attr { class => 'highlight-'.$fileDesc->high2_render };
            outs ' highligh '; };
            outs ' des lignes ';
            outs ' de la colone '.$fileDesc->high2_pos if $fileDesc->high2_pos;
         if ($fileDesc->high2_color) {
         span { attr { style => 'background-color: '.$fileDesc->high2_color.';' };
            outs ' de couleur '; }
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
            #render_param($action,'end_date');
            form_submit(label => 'Valider');
        };
    };

    return if (!$version);

    my $delete = new_action(class => 'DeleteVersion', record => $version);
    form {
        render_action($delete);
        form_submit(label => 'Effacer données');
    };
};

1;
