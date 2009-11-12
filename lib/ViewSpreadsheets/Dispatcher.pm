use strict;
use warnings;

package ViewSpreadsheets::Dispatcher;
use Jifty::Dispatcher -base;
use Jifty::JSON;

before '/user*' => run {

    unless(Jifty->web->current_user->id) {
         Jifty->web->tangent(url => '/caslogin');
          };

   unless(  Jifty->web->current_user->group eq 'admin' ||
            Jifty->web->current_user->group eq 'reader' ||
            Jifty->web->current_user->group eq 'user'
            ) {
         my $system_user = ViewSpreadsheets::CurrentUser->superuser;
         my $user = ViewSpreadsheets::Model::User->new(current_user => $system_user);
            $user->load(Jifty->web->current_user->id);
            $user->set_user_role('guest');
            # this guest users can be deleted later with an external script
            Jifty->web->tangent(url => '/caslogout');
          };
    my $top = Jifty->web->navigation;
    my $sub_nav = $top->child( 'Lots' => url => '/user', sort_order => 10 );
    my $col = ViewSpreadsheets::Model::DomainCollection->new();
       $col->unlimit;
    while (my $d = $col->next ) {
        $sub_nav->child( $d->name => url =>  '/user/dom/'.$d->id);
    };
    if (Jifty->web->current_user->group eq 'admin') {
        my $admin_nav = $top->child( 'Admin' => url => '/user/admin/upload', sort_order => 20 );
        $admin_nav->child( 'Upload' => url =>  '/user/admin/upload');
        $admin_nav->child( 'Offre' => url =>  '/user/admin/offer');
        my $sub_admin = $admin_nav->child('<b>Tables</b>' => url =>  undef);
        foreach my $model ( Jifty->class_loader->models ) {
           my $bare_model;
            if ( $model =~ /^.*::(.*?)$/ ) {
                $bare_model = $1;
            };
            next if $bare_model eq 'Spreadsheet';
            $sub_admin->child( $bare_model => url =>  '/user/admin/crud?J:V-region-crud=/user/admin/'.$bare_model . '-list');
        };
    };
};

before qr '/user/dom/(\d+)' => run {
    my $dom_id = $1;
    my $dom = ViewSpreadsheets::Model::Domain->new();
    Jifty->web->session->set(Version => undef);
    $dom->load($dom_id);
    if ( $dom->id ) {
        Jifty->web->session->set(Dom => $dom);
        # set current version
        Jifty->web->session->set(Version => $dom->current_version);
    };
    tangent '/user';
};

before qr '/user/version/(\d+)' => run {
    my $ver_id = $1;
    my $version = ViewSpreadsheets::Model::Version->new();
    $version->load($ver_id);
    Jifty->web->session->set(Version => $version) if $version->id;
    tangent '/user';
};

before '/user/admin*' => run  {
   unless(Jifty->web->current_user->group eq 'admin' || Jifty->web->current_user->group eq 'reader' ) {
            Jifty->web->tangent(url => '/accessdenied');
          };

    my $dom = Jifty->web->session->get('Dom');

    unless ( $dom ) {
      tangent '/user';
    };

};

1;
