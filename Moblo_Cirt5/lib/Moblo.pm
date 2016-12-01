package Moblo;
use Mojo::Base 'Mojolicious';
use Moblo::Schema;
use DBI;
#use DBIx::Connector;

use Mojo::Home;

has lannisterDBH => sub {
    my $self = shift;

    # my $data_source = "dbi:mysql:database=cirt;host=lannister.dpm.bwh.harvard.edu";
    # my $user = "";
    # my $password = "";

    my $data_source = 'dbi:SQLite:dbname='. $self->home->rel_file('helloCIRT.sqlite');

    my $con = DBI->connect( $data_source, "", "" ) or die "Could not connect";
        
 # my $dbh = DBI->connect(
 # 	$data_source,
 # 	$user,
 # 	$password,
 # 	{RaiseError => 1}
 # 	);

 #    return $dbh;

    # my $con = DBIx::Connector->connect(
    # 	$data_source,
    # 	$user,
    # 	$password,
    # 	{AutoCommit => 1, RaiseError => 1}
    # 	);

    return $con;
};


sub startup {
    my $self = shift;

    # Allows to set the signing key as an array,
    # where the first key will be used for all new sessions
    # and the other keys are still used for validation, but not for new sessions.
    $self->secrets(['This secret is used for new sessionsLeYTmFPhw3q',
            'This secret is used _only_ for validation QrPTZhWJmqCjyGZmguK']);

    # The cookie name
    $self->app->sessions->cookie_name('cirt');

    # Expiration reduced to 8 hours
    $self->app->sessions->default_expiration('28800');

    # Plugins

    # Router
    my $r = $self->routes;

    # GET / -> Main::index()
    $r->get('/')->to(template => 'main/index');

    # Login routes
    $r->get('/login')->name('login_form')->to(template => 'login/login_form');
    $r->post('/login')->name('do_login')->to('Login#on_user_login');



    my $authorized = $r->under('/cirt')->to('Login#is_logged_in');
    $authorized->get('/')->name('restricted_area')->to(template => 'cirt/overview');


    $authorized->get('/site/:id')->name('site')->to(template => 'cirt/show_site');

    $authorized->get('/liaison/:raName')->name('liaison')->to(template => 'cirt/show_liaison');

    ### iEvents
    $authorized->get('/indexEvent')->name('indexEvent')->to(template => 'cirt/indexEvents');

    #$authorized->get('/iEventCover/:patid')->name('iEventCover')->to(template => 'cirt/iEventCover');

    $authorized->get('/iEventCover/:patid')->to(controller => 'foo', action => 'welcome');
    ##$authorized->post('/iEventCover/:patid')->name('submit_physician')->to(controller => 'foo', action => 'postIEventCover'); # working but problem... stash value of patid becomes 'submit_physician'. SOLVED... removed name part!!! see below.
    ##$authorized->post('/iEventCover')->name('submit_physician')->to(controller => 'foo', action => 'postIEventCover'); ## not working
    $authorized->post('/iEventCover/:patid')->to(controller => 'foo', action => 'postIEventCover')->name('submit_physician');

    $authorized->get('/waitingOnICF')->name('waitingOnICF')->to(controller => 'foo', action => 'receivedBeforeEDC');
    $authorized->post('/waitingOnICF')->name('waitingOnICFinsert')->to(controller => 'foo', action => 'waitingOnICFinsert');

    ### SAE
    #$authorized->get('/SAE')->name('SAE')->to(template => 'cirt/SAE');    
    $authorized->get('/SAE')->name('SAE')->to(template => 'cirt/SAEAE');    

    $self->helper( getUserName => sub { my $self = shift;
     					return $self->session('username');
		   } );

    # Logout route
    $r->route('/logout')->name('do_logout')->to(cb => sub {
            my $self = shift;

            # Expire the session (deleted upon next request)
            $self->session(expires => 1);

            # Go back to home
            $self->redirect_to('/');
        });


}

1;
