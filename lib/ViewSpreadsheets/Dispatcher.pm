use strict;
use warnings;

package ViewSpreadsheets::Dispatcher;
use Jifty::Dispatcher -base;
use Jifty::JSON;

before '/admin*' => run  {

    unless(Jifty->web->current_user->id) {
         Jifty->web->tangent(url => '/caslogin');
          };

   unless(Jifty->web->current_user->group eq 'admin' || Jifty->web->current_user->group eq 'reader' ) {
         my $system_user = ViewSpreadsheets::CurrentUser->superuser;
         my $user = ViewSpreadsheets::Model::User->new(current_user => $system_user);
            $user->load(Jifty->web->current_user->id);
            $user->set_user_role('guest');
            # this guest users can be deleted later with an external script
            Jifty->web->tangent(url => '/caslogout');
          };

    my $top = Jifty->web->navigation;
    my $sub_nav = $top->child( _('Tables') => url => '/admin/crud' );
    foreach my $model ( Jifty->class_loader->models ) {
       my $bare_model;
        if ( $model =~ /^.*::(.*?)$/ ) {
            $bare_model = $1;
        };
        $sub_nav->child( $model => url =>  '/admin/crud?J:V-region-crud=/admin/'.$bare_model . '-list');
    };
    $top->child( _('Logout') => url => '/caslogout' );

};

1;
