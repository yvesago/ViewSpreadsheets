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
    my $sub_nav = $top->child( _('User') => url => '/user' );
    my $col = ViewSpreadsheets::Model::DomainCollection->new();
       $col->unlimit;
    while (my $d = $col->next ) {
        $sub_nav->child( $d->name => url =>  '/user/dom/'.$d->id);
    };
    my $admin_nav = $top->child( 'Admin' => url => '/user/admin' );
        $admin_nav->child('Upload' => url => '/user/admin/upload' );
};

before qr '/user/dom/(\d+)' => run {
    my $dom_id = $1;
    my $dom = ViewSpreadsheets::Model::Domain->new();
    $dom->load($dom_id);
    Jifty->web->session->set(Version => undef);
    Jifty->web->session->set(Dom => $dom) if $dom->id;
    dispatch '/user';
};

before qr '/user/version/(\d+)' => run {
    my $ver_id = $1;
    my $version = ViewSpreadsheets::Model::Version->new();
    $version->load($ver_id);
    Jifty->web->session->set(Version => $version) if $version->id;
    dispatch '/user';
};

before '/user/admin*' => run  {

   unless(Jifty->web->current_user->group eq 'admin' || Jifty->web->current_user->group eq 'reader' ) {
            Jifty->web->tangent(url => '/accessdenied');
          };

    my $top = Jifty->web->navigation;
    my $sub_nav = $top->child( _('Tables') => url => '/user/admin/crud' );
    foreach my $model ( Jifty->class_loader->models ) {
       my $bare_model;
        if ( $model =~ /^.*::(.*?)$/ ) {
            $bare_model = $1;
        };
        $sub_nav->child( $model => url =>  '/user/admin/crud?J:V-region-crud=/user/admin/'.$bare_model . '-list');
    };
    $top->child( _('Logout') => url => '/caslogout' );

};

1;
