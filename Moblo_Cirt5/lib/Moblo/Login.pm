package Moblo::Login;
use Mojo::Base 'Mojolicious::Controller';
use Net::LDAP;
use Data::Dumper;

sub is_logged_in {
    my $self = shift;

    # print "is_logged_in : logged_in : ", $self->session('logged_in'), "\n";
    # print "is_logged_in : username : ", $self->session('username'), "\n";

    return 1 if $self->session('logged_in');

    $self->render(
        inline => "<h2>Forbidden</h2><p>You're not logged in. <%= link_to 'Go to login page.' => 'login_form' %>",
        status => 403
    );
}

sub user_exists {
    my ($self, $username, $password) = @_;

    # print "user_exists : $username / $password\n";

    my $server = "ldap.partners.org";
    my $ldap = Net::LDAP->new( $server ) or die $@;

    # my $result = $ldap->bind('hp911@partners.org', password => 'mypassword');
    my $result = $ldap->bind($username. "\@partners.org", password => $password);

    # my $sth = eval { $self->app->lannisterDBH->prepare( "SELECT NickName, name from test where name = \"$username\" " ) } || return undef;
    # $sth->execute;

    my $conn = $self->app->lannisterDBH;
    my $query = "SELECT NickName, name from cirtUsers where name = \"$username\" ";
    my $data = $conn->selectall_arrayref( $query );
    # print Dumper( $data );
    # print "%%%". $data->[0]->[0];

    $username = $data->[0]->[0];

    # ($username, my $name) = $sth->fetchrow;
    # $sth->finish;
    # print "**** $username\n";

    #  print "*** : ", $result->code, "\n";
    #return $tmp[0] if ( $result->code == 0  && $tmp[0] );
    return $username if ( $result->code == 0  && $username );
}

sub on_user_login {
    my $self = shift;

    # Grab the request parameters
    my $username = $self->param('username');
    my $password = $self->param('password');

    if (my $user = $self->user_exists($username, $password)) {

        $self->session(logged_in => 1);
        $self->session(username => $user);

        $self->redirect_to('restricted_area');
    } else {
	$self->render(
	    inline => "<h2>Wrong username/password. Try again?</h2> <%= link_to 'Go to login page' => 'login_form' %>",
	    status => 403
	    );

    }
}

1;
