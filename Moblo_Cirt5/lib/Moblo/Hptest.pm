package Moblo::Hptest;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub first {
    my $self = shift;

    $self->redirect_to('admin/hptest');
    # $self->render( text => "ttt");
}

sub user_exists {
    my ($self, $username, $password) = @_;

    print "user_exists : $username / $password\n";

    # # Determine if a user with 'username' exists
    # my $user = $self->db->resultset('User')
    #     ->search({ username => $username })->first;

    # # Validate password against hash, return user object
    # return $user if (
    #     defined $user &&
    #     $self->bcrypt_validate( $password, $user->pw_hash )
    # );

    my $sth = eval { $self->app->lannisterDBH->prepare( "SELECT NickName, name from test where name = \"$username\" " ) } || return undef;
    $sth->execute;

    # my $conn = $self->app->lannisterDBH;
    # my $query = "SELECT NickName, name from test where name = \"$username\" ";
    # my $data = $conn->selectall_arrayref( $query );

    # print Dumper( $data );

    my @tmp = $sth->fetchrow;
    $sth->finish;

    print "++++ $tmp[0]\n";

 if ( $tmp[0] ) {
 	print "Found\n";
 }  else {
 	print "not Found\n";	
 }


    my $server = "ldap.partners.org";
    my $ldap = Net::LDAP->new( $server ) or die $@;

    # my $result = $ldap->bind('hp911@partners.org', password => 'mypassword');
    my $result = $ldap->bind($username. "\@partners.org", password => $password);

    print "*** : ", $result->code, "\n";
    #return $username if ( $result->code == 0  && $tmp[0] );
    return $tmp[0] if ( $result->code == 0  && $tmp[0] );
}

sub on_user_login {
    my $self = shift;

    # Grab the request parameters
    my $username = $self->param('username');
    my $password = $self->param('password');

    if (my $user = $self->user_exists($username, $password)) {

        $self->session(logged_in => 1);
        # $self->session(username => $username);
        $self->session(username => $user);
        # $self->session(user_id => $user->id);

        $self->redirect_to('restricted_area');
    } else {
        # $self->render(text => 'Wrong username/password', status => 403);

	$self->render(
	    inline => "<h2>Wrong username/password. Try again?</h2> <%= link_to 'Go to login page' => 'login_form' %>",
	    status => 403
	    );

    }
}

1;
