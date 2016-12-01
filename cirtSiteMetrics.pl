use Mojolicious::Lite;
use Mojo::JSON qw(decode_json encode_json);
use DBI;

use MIME::Lite;
use Mojo::Parameters;
use Date::Format;
use Data::Dumper;
use POSIX qw/strftime/;

plugin 'ReplyTable';

# Here you can configure any of your server settings right 
# within the app. 
app->config(hypnotoad => {listen => ['http://*:4000']});

# Global handle for db connections
my $dbh = "";

# Helpers are like methods for the instantiated process 
# that is created when someone invoke our API.  I've
# created a few helpers below:

# Create db connection if needed
helper db => sub {
    if($dbh){
        return $dbh;
    }else{
	 $dbh = DBI->connect('DBI:mysql:database=cirt;host=localhost','id','passwd') or die $DBI::errstr;
        return $dbh;
    }
};

# Disconnect db connection
helper db_disconnect => sub {
    my $self = shift;
    $self->db->disconnect;
    $dbh = "";  
};

# Under is a Mojolicious syntax tag for eliminating repetitive coding.
# If you have something that you want run every time an API call 
# is made, regardless of which API call, then put it in the "under"
# section here.  This code will always be executed before any API 
# routes are processed.  Returning a 1 will allow the request 
# to continue, anything else will stop the request.

# Always check auth token!  Here we validate that every API request 
# has a valid token
under sub {
    my $self  = shift;
    my $token   = $self->param('token');
    
    # my $SQL = "select name from test";
    # my $cursor = $self->db->prepare($SQL);
				# $cursor->execute;
    # my @username = $cursor->fetchrow;
    # $cursor->finish;
    
    # if($username[0]){
    #     return 1;
    # }else{
    #     $self->render(text => 'Access denied');
    #     $self->db_disconnect;
    #     return;
    # }

    return 1;
};

# Routes:  Here is where you define your API routes, or paths.
# You can define as many as you like to support all your API 
# functionality. "get" says that this API route will only 
# accept GET requests.  You can use "post" or "any" as well.

# Route to grab a record using an ID that is passed in from a database
# and return as JSON.
# Example URL request:  /data/298


# get '/siteMetrics/' => sub {
#     my $self  = shift;
    
#     my $SQL = "select SiteID, PI, Liaison, SiteInitializationDate, NInformedConsent, NScreened, MostRecentScreeningDate, EnrolledOverScreened, NStartedRunin, NRandomized, BucketProgrammed, BucketByRA, id from SiteMetrics where isThisMostRecent = 1 order by id";
#     # my $SQL = "select SiteID, PI, Liaison, SiteInitializationDate, NInformedConsent, NScreened, MostRecentScreeningDate, EnrolledOverScreened, NStartedRunin, NRandomized, BucketProgrammed, BucketByRA from SiteMetrics where isThisMostRecent = 1 order by id";

#     my $cursor = $self->db->prepare($SQL);
#     $cursor->execute;

#     my $data = $cursor->fetchall_arrayref;
#     $cursor->finish;
#     $self->db_disconnect;

#     my %refhash;
#     $refhash{"0"} = "SiteID";
#     $refhash{"1"} = "PI";
#     $refhash{"2"} = "Liaison";
#     $refhash{"3"} = "SiteInitializationDate";
#     $refhash{"4"} = "NInformedConsent";
#     $refhash{"5"} = "NScreened";
#     $refhash{"6"} = "MostRecentScreeningDate";
#     $refhash{"7"} = "EnrolledOverScreened";
#     $refhash{"8"} = "NStartedRunin";
#     $refhash{"9"} = "NRandomized";
#     $refhash{"10"} = "BucketProgrammed";
#     $refhash{"11"} = "BucketByRA";
#     $refhash{"12"} = "id";

#     # foreach my $key ( keys @$data ) {
#     # 	my $i = 0;
#     # 	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
#     # 	$data->[$key] = \%tmpHash;
#     # }

#     foreach my $key ( keys @$data ) {
# 	my $i = 0;
# 	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
# 	# $tmpHash{'SiteID'} = "<a href=\"https://lannister.dpm.bwh.harvard.edu/api/whatsup/".$tmpHash{'SiteID'}."\" taraget=\"_blank\">".$tmpHash{'SiteID'}."</a>";
# 	$tmpHash{'SiteID'} = "<a href=\"https://lannister.dpm.bwh.harvard.edu/api/whatsup/".$tmpHash{'SiteID'}."\" target=\"_blank\">".$tmpHash{'SiteID'}."</a>";
# 	$tmpHash{'Liaison'} = "<a href=\"https://lannister.dpm.bwh.harvard.edu/api/whatsup/".$tmpHash{'Liaison'}."\" target=\"_blank\">".$tmpHash{'Liaison'}."</a>";
# 	$data->[$key] = \%tmpHash;
#     }

#     return $self->render(json =>  $data );
# };

######################################
get '/FWA/:id' => sub {
    my $self  = shift;
    my $id  = $self->stash('id');

    my $SQL = "select id, SiteID, FWA, FWAexpDT, piLicenseExp, IRBName, IRBLocal, IRBexp from FWA where SiteID = '$id'";
    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = "id";
    $refhash{"1"} = "SiteID";
    $refhash{"2"} = "FWA";
    $refhash{"3"} = "FWAexpDT";
    $refhash{"4"} = "piLicenseExp";
    $refhash{"5"} = "IRBName";
    $refhash{"6"} = "IRBLocal";
    $refhash{"7"} = "IRBexp";

    foreach my $key ( keys @$data ) {
	my $i = 0;
	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
	$data->[$key] = \%tmpHash;
    }

    return $self->render(json =>  $data );
    # return $self->render(json =>  { "data" => $data } );
};

post '/updateFWA' => sub {
    my $self  = shift;

    my $id = $self->param('id');
    my $FWA = $self->param('FWA');
    my $FWAexpDT = $self->param('FWAexpDT');
    my $piLicenseExp = $self->param('piLicenseExp');
    my $IRBexp = $self->param('IRBexp');

    # Make sure we escape the incoming data...
    $FWA = $self->db->quote($FWA);
    $FWAexpDT = $self->db->quote($FWAexpDT);
    $piLicenseExp = $self->db->quote($piLicenseExp);
    $IRBexp = $self->db->quote($IRBexp);

    my $SQL = "update FWA set FWA = $FWA, FWAexpDT = $FWAexpDT, piLicenseExp = $piLicenseExp, IRBexp = $IRBexp where id = $id;";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;
    my $new_id = $cursor->{mysql_insertid};
    $cursor->finish;
    $self->db_disconnect;
    
    # if($new_id){
    if( 1 ){
    	return $self->render(json => {result => "1", message => "OK"});
	# return $self->render(json => {result => "1", message => $SQL });
    }else{
     	return $self->render(json => {result => "0", message => "Insert Failure"});
    }

};


get '/piCoordsEDC/:id' => sub {
    my $self  = shift;
    my $id  = $self->stash('id');

    my $SQL = "select LastName, FirstName, Role, Phone, Email, MainSC from PiCoordsContactEDC where SiteID = '$id' order by Role desc";
    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = "LastName";
    $refhash{"1"} = "FirstName";
    $refhash{"2"} = "Role";
    $refhash{"3"} = "Phone";
    $refhash{"4"} = "Email";
    $refhash{"5"} = "MainSC";

    foreach my $key ( keys @$data ) {
	my $i = 0;
	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
	$data->[$key] = \%tmpHash;
    }

    return $self->render(json =>  $data );
    # return $self->render(json =>  { "data" => $data } );
};


get '/bucketList1/' => sub {
    my $self  = shift;

    my $SQL = "select tt.TotalByRA, t.Liaison, NewSite, Terrific, RandAdequate, ScrnAdequate, AtRisk, Closed
from (  SELECT Liaison, count( * ) as TotalByRA  FROM `SiteMetrics` WHERE `isThisMostRecent` = 1 group by `Liaison` order by Liaison ) as tt
join ( 
    select Liaison,
max( case when BucketByRA = 1 then myCount end ) NewSite,
max( case when BucketByRA = 2 then myCount end ) Terrific,
max( case when BucketByRA = 3 then myCount end ) RandAdequate,
max( case when BucketByRA = 4 then myCount end ) ScrnAdequate,
max( case when BucketByRA = 5 then myCount end ) AtRisk,
max( case when BucketByRA = 6 then myCount end ) Closed
from ( SELECT Liaison, BucketByRA, count( * ) as myCount  FROM `SiteMetrics` WHERE `isThisMostRecent` = 1 group by `Liaison`, `BucketByRA` order by Liaison, BucketByRA ) as ttt
group by Liaison
order by Liaison ) as t
on t.Liaison = tt.Liaison";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    # my $data = $cursor->fetchall_arrayref;
    my $data = $cursor->fetchall_hashref('Liaison');
    $cursor->finish;
    $self->db_disconnect;

    my @tempKey = keys %$data;
    my @tempArr = @{$data}{ @tempKey };
    my $newdata = \@tempArr;

    # return $self->render(json =>  [ "data" => $data ]);
    return $self->render(json => { "data" => $newdata } );
};



post '/updateBucketList1' => sub {
    my $self  = shift;

    my $id = $self->param('id');
    my $bucketByRA = $self->param('bucketByRA');

    ## Make sure we escape the incoming data...
    $bucketByRA = $self->db->quote($bucketByRA);

    #### #my $SQL = "insert into my_table (id, data) values ('$id',$data)";
    #### my $SQL = "insert into test (id, name) values ($id,$data)";
    ### my $SQL = "insert into test (name) values ($data)";
    my $SQL = "update SiteMetrics set BucketByRA = $bucketByRA where id = $id;";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;
    my $new_id = $cursor->{mysql_insertid};
    $cursor->finish;
    $self->db_disconnect;
    
    if($new_id){
    	return $self->render(json => {result => "1", message => "OK"});
	#return $self->render(json => {result => "1", message => $SQL });
    }else{
     	return $self->render(json => {result => "0", message => "Insert Failure"});
    }

};


get '/siteMetrics/' => sub {
    my $self  = shift;
    
    my $SQL = "select SiteID, PI, Liaison, SiteInitializationDate, NInformedConsent, NScreened, MostRecentScreeningDate, EnrolledOverScreened, NStartedRunin, NRandomized, BucketProgrammed, BucketByRA, id, SC from SiteMetrics where isThisMostRecent = 1 order by id";
    # my $SQL = "select SiteID, PI, Liaison, SiteInitializationDate, NInformedConsent, NScreened, MostRecentScreeningDate, EnrolledOverScreened, NStartedRunin, NRandomized, BucketProgrammed, BucketByRA from SiteMetrics where isThisMostRecent = 1 order by id";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = "SiteID";
    $refhash{"1"} = "PI";
    $refhash{"2"} = "Liaison";
    $refhash{"3"} = "SiteInitializationDate";
    $refhash{"4"} = "NInformedConsent";
    $refhash{"5"} = "NScreened";
    $refhash{"6"} = "MostRecentScreeningDate";
    $refhash{"7"} = "EnrolledOverScreened";
    $refhash{"8"} = "NStartedRunin";
    $refhash{"9"} = "NRandomized";
    $refhash{"10"} = "BucketProgrammed";
    $refhash{"11"} = "BucketByRA";
    $refhash{"12"} = "id";
    $refhash{"13"} = "SC";

    # foreach my $key ( keys @$data ) {
    # 	my $i = 0;
    # 	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
    # 	$data->[$key] = \%tmpHash;
    # }

    foreach my $key ( keys @$data ) {
	my $i = 0;
	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
	# $tmpHash{'SiteID'} = "<a href=\"https://lannister.dpm.bwh.harvard.edu/api/whatsup/".$tmpHash{'SiteID'}."\" taraget=\"_blank\">".$tmpHash{'SiteID'}."</a>";
	# $tmpHash{'SiteID'} = "<a href=\"https://lannister.dpm.bwh.harvard.edu/api/whatsup/".$tmpHash{'SiteID'}."\" target=\"_blank\">".$tmpHash{'SiteID'}."</a>";
	# $tmpHash{'SiteID'} = "<a href=\"http://tully.dpm.bwh.harvard.edu/myapp/site/".$tmpHash{'SiteID'}."\" target=\"_blank\">".$tmpHash{'SiteID'}."</a>";
	$tmpHash{'SiteID'} = "<a href=\"/cirt/site/".$tmpHash{'SiteID'}."\" >".$tmpHash{'SiteID'}."</a>";
	$tmpHash{'Liaison'} = "<a href=\"/cirt/liaison/".$tmpHash{'Liaison'}."\" target=\"_blank\">".$tmpHash{'Liaison'}."</a>";
	# $tmpHash{'Liaison'} = "<a href=\"/cirt/liaison/".$tmpHash{'Liaison'}."\" >".$tmpHash{'Liaison'}."</a>";
	$data->[$key] = \%tmpHash;
    }

    return $self->render(json =>  $data );
};


get '/siteFirstPage/' => sub {
    my $self  = shift;
    
#    my $SQL = "select SiteID, PI, Liaison, SiteInitializationDate, NInformedConsent, NScreened, MostRecentScreeningDate, EnrolledOverScreened, NStartedRunin, NRandomized, BucketProgrammed, BucketByRA, id, SC from SiteMetrics where isThisMostRecent = 1 order by id";
    # my $SQL = "select SiteID, PI, Liaison, SiteInitializationDate, NInformedConsent, NScreened, MostRecentScreeningDate, EnrolledOverScreened, NStartedRunin, NRandomized, BucketProgrammed, BucketByRA from SiteMetrics where isThisMostRecent = 1 order by id";
#  my $SQL = ' SELECT SM.SiteID, SUBSTRING_INDEX( SM.PI, " - ", 1) as PI, SUBSTRING_INDEX(SM.PI, " - ", -1) as Clinic,  CO.CoI, SC.SC, SUBSTRING_INDEX(Location, ", ", 1) as City, SUBSTRING_INDEX( Location, ", ", -1) as State, SM.Liaison
# FROM `SiteMetrics` as SM
#    LEFT JOIN (    SELECT SiteID, GROUP_CONCAT( concat( PiCoordsContactEDC.FirstName, " ", PiCoordsContactEDC.LastName)  SEPARATOR ', ') as SC from PiCoordsContactEDC WHERE Role = "SC" group by SiteID order by SiteID ) as SC
#    ON SM.SiteID = SC.SiteID
#    LEFT JOIN ( SELECT SiteID, GROUP_CONCAT( PiCoordsContactEDC.LastName  SEPARATOR ', ') as CoI from PiCoordsContactEDC WHERE Role = "CI" group by SiteID order by SiteID ) as CO
#    ON SM.SiteID = CO.SiteID
# WHERE `isThisMostRecent` = 1
# order by SM.SiteID';

    my $SQL = ' SELECT SM.SiteID, SUBSTRING_INDEX( SM.PI, " - ", 1) as PI, SUBSTRING_INDEX(SM.PI, " - ", -1) as Clinic , CO.CoI, SC.SC, 
SUBSTRING_INDEX(Location, ", ", 1) as City, SUBSTRING_INDEX( Location, ", ", -1) as State, SM.Liaison
from SiteMetrics as SM 

    LEFT JOIN (    SELECT SiteID, GROUP_CONCAT( concat( PiCoordsContactEDC.FirstName, " ", PiCoordsContactEDC.LastName)  SEPARATOR \', \') as SC from PiCoordsContactEDC WHERE Role = "SC" group by SiteID order by SiteID ) as SC
    ON SM.SiteID = SC.SiteID

    LEFT JOIN ( SELECT SiteID, GROUP_CONCAT( PiCoordsContactEDC.LastName  SEPARATOR \', \') as CoI from PiCoordsContactEDC WHERE Role = "CI" group by SiteID order by SiteID ) as CO
    ON SM.SiteID = CO.SiteID

WHERE isThisMostRecent = 1 order by SM.SiteID ';

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = "SiteID";
    $refhash{"1"} = "PI";
    $refhash{"2"} = "Clinic";
    $refhash{"3"} = "CoI";
    $refhash{"4"} = "SC";
    $refhash{"5"} = "City";
    $refhash{"6"} = "State";
    $refhash{"7"} = "Liaison";

    # foreach my $key ( keys @$data ) {
    # 	my $i = 0;
    # 	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
    # 	$data->[$key] = \%tmpHash;
    # }

    foreach my $key ( keys @$data ) {
	my $i = 0;
	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
	$tmpHash{'SiteID'} = "<a href=\"/cirt/site/".$tmpHash{'SiteID'}."\" >".$tmpHash{'SiteID'}."</a>";
	$tmpHash{'Liaison'} = "<a href=\"/cirt/liaison/".$tmpHash{'Liaison'}."\" target=\"_blank\">".$tmpHash{'Liaison'}."</a>";
	$data->[$key] = \%tmpHash;
    }

    return $self->render(json =>  $data );
};


get '/siteAddress/:id' => sub {
    my $self  = shift;
    my $id  = $self->stash('id');

    my $SQL;

    if ( $id =~ /(CA|US)\-[A-Z]{1}\d{3}/ ) { # for site
	$SQL = "select SiteID, Clinic, StreetAddress, City, State, Country, Zip from clinic where SiteID = '$id';";
    }
    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = "SiteID";
    $refhash{"1"} = "Clinic";
    $refhash{"2"} = "StreetAddress";
    $refhash{"3"} = "City";
    $refhash{"4"} = "State";
    $refhash{"5"} = "Country";
    $refhash{"6"} = "Zip";

    foreach my $key ( keys @$data ) {
	my $i = 0;
	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
	$data->[$key] = \%tmpHash;
    }

    return $self->render(json =>  $data );
};


get '/siteMetrics/:id' => sub {
    my $self  = shift;
    my $id  = $self->stash('id');

    my $SQL;

    if ( $id =~ /(CA|US)\-[A-Z]{1}\d{3}/ ) { # for site
	$SQL = "select SiteID, PI, Liaison, SiteInitializationDate, NInformedConsent, NScreened, MostRecentScreeningDate, EnrolledOverScreened, NStartedRunin, NRandomized from SiteMetrics where SiteID = '$id' and isThisMostRecent = 1";
    }
    else { # for ra's
	$SQL = "SELECT SiteID, PI, Liaison, SiteInitializationDate, NInformedConsent, NScreened, MostRecentScreeningDate, EnrolledOverScreened, NStartedRunin, NRandomized  FROM `SiteMetrics` WHERE `Liaison` = '$id' and `isThisMostRecent` = 1 order by SiteID";
    }

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = "SiteID";
    $refhash{"1"} = "PI";
    $refhash{"2"} = "Liaison";
    $refhash{"3"} = "SiteInitializationDate";
    $refhash{"4"} = "NInformedConsent";
    $refhash{"5"} = "NScreened";
    $refhash{"6"} = "MostRecentScreeningDate";
    $refhash{"7"} = "EnrolledOverScreened";
    $refhash{"8"} = "NStartedRunin";
    $refhash{"9"} = "NRandomized";

    foreach my $key ( keys @$data ) {
	my $i = 0;
	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
	$data->[$key] = \%tmpHash;
	$tmpHash{'SiteID'} = "<a href=\"/cirt/site/".$tmpHash{'SiteID'}."\" target=\"_blank\">".$tmpHash{'SiteID'}."</a>";
    }

    return $self->render(json =>  $data );

    # my @data = $cursor->fetchrow;
    # $cursor->finish;
    # $self->db_disconnect;
    # return $self->render(json => [ { SiteID => $data[0], PI => $data[1], Liaison => $data[2], SiteInitializationDate => $data[3], NInformedConsent => $data[4], NScreened => $data[5], MostRecentScreeningDate => $data[6], EnrolledOverScreened => $data[7], NStartedRunin => $data[8], NRandomized => $data[9]} ] );

};


get '/getUpdatedTimeSiteMetrics/' => sub {
    my $self  = shift;

    my $SQL = "SELECT Created FROM SiteMetrics WHERE isThisMostRecent = 1 order by id limit 1";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchrow;
    $cursor->finish;
    $self->db_disconnect;

    return $self->render(json => { time => $data });
};


get '/labIssues/:id' => sub {
    my $self  = shift;
    my $id  = $self->stash('id');

    my $SQL;

    if ( $id =~ /(CA|US)\-[A-Z]{1}\d{3}/ ) { # for site
	$SQL = "select LCASpecimen, isNew, Problem, PatientID, VisitDesignation,CollectionDate,Gender,BirthDate,Initials,EDCGender,EDCBirthDate,EDCInitials,MissingLabs, BwhComments,LabCorpComments, raComments, id from LabIssues where SiteID = '$id' and isThisMostRecent = 1 order by PatientID";
    # my $SQL = "select LCASpecimen, isNew, Problem from LabIssues where SiteID = '$id'";
    } else { # for ra's
	$SQL = "SELECT LCASpecimen, isNew, Problem, PatientID, VisitDesignation,CollectionDate,Gender,BirthDate,Initials,EDCGender,EDCBirthDate,EDCInitials,MissingLabs, BwhComments,LabCorpComments, raComments, id from LabIssues inner join ( SELECT SiteID  FROM `SiteMetrics` WHERE `Liaison` = '$id' and `isThisMostRecent` = 1 ) as t  on t.SiteID = LabIssues.SiteID where LabIssues.isThisMostRecent = 1 order by PatientID";
    }
    
    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = "LCASpecimen";
    $refhash{"1"} = "isNew";
    $refhash{"2"} = "Problem";
    $refhash{"3"} = "PatientID";
    $refhash{"4"} = "VisitDesignation";
    $refhash{"5"} = "CollectionDate";
    $refhash{"6"} = "Gender";
    $refhash{"7"} = "BirthDate";
    $refhash{"8"} = "Initials";
    $refhash{"9"} = "EDCGender";
    $refhash{"10"} = "EDCBirthDate";
    $refhash{"11"} = "EDCInitials";
    $refhash{"12"} = "MissingLabs";
    $refhash{"13"} = "BwhComments";
    $refhash{"14"} = "LapCorpCommnets";
    $refhash{"15"} = "raComments";
    $refhash{"16"} = "id";

    foreach my $key ( keys @$data ) {
	my $i = 0;
	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
	$data->[$key] = \%tmpHash;
    }

    return $self->render(json =>  $data );
};

post '/updateLabDataIssuesComments' => sub {
##http://tully.dpm.bwh.harvard.edu/api/updateLabDataIssuesComments?id=4627&comments=ttttttttttttttttttt
    my $self  = shift;

    my $id = $self->param('id');
    my $comments = $self->param('comments');

    # # Make sure we escape the incoming data...
    $comments = $self->db->quote($comments);

    my $SQL = "update LabIssues set raComments = $comments where id = $id;";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;
    my $new_id = $cursor->{mysql_insertid};
    $cursor->finish;
    $self->db_disconnect;
    
#    if($new_id){
    if( 1 ){
    	return $self->render(json => {result => "1", message => "OK"});
	# return $self->render(json => {result => "1", message => $SQL });
    }else{
     	return $self->render(json => {result => "0", message => "Insert Failure"});
    }

};


get '/getUpdatedTimeLabIssues/' => sub {
    my $self  = shift;

    my $SQL = "SELECT Created FROM LabIssues WHERE isThisMostRecent = 1 order by id desc limit 1";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchrow;
    $cursor->finish;
    $self->db_disconnect;

    # print "***", $data, "\n"

    return $self->render(json => { time => $data });
    # return $self->render(json => { time => "2015-10-10 10:10:10" });
};

get '/medRecs/:id' => sub {
    my $self  = shift;
    my $id  = $self->stash('id');

    my $SQL;
    
    if ( $id =~ /(CA|US)\-[A-Z]{1}\d{3}/ ) {
	$SQL = "select PatientID, CollectionDate, DateReceivedMedRecs, MedRecReviewResult from MedRecs where SiteID = '$id' and isThisMostRecent = 1 order by PatientID";
    } else {
	$SQL = "select PatientID, CollectionDate, DateReceivedMedRecs, MedRecReviewResult from MedRecs inner join ( SELECT SiteID  FROM `SiteMetrics` WHERE `Liaison` = '$id' and `isThisMostRecent` = 1 ) as t  on t.SiteID = MedRecs.SiteID where MedRecs.isThisMostRecent = 1 order by PatientID";
    }

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = "PatientID";
    $refhash{"1"} = "CollectionDate";
    $refhash{"2"} = "DateReceivedMedRecs";
    $refhash{"3"} = "MedRecReviewResult";

    foreach my $key ( keys @$data ) {
	my $i = 0;
	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
	$data->[$key] = \%tmpHash;
    }

    return $self->render(json =>  $data );
};

get '/getUpdatedTimeMedRecs/:id' => sub {
    my $self  = shift;
    my $id  = $self->stash('id');

    my $SQL;
    if ($id =~ /^CA\-*/ or $id =~ /^Lizzie$/) {
	$SQL = "SELECT Created FROM `MedRecs` WHERE isThisMostRecent = 1 and SiteID like \"CA%\" limit 1";
    } else {
	$SQL = "SELECT Created FROM `MedRecs` WHERE isThisMostRecent = 1 and SiteID like \"US%\" limit 1";
    }

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchrow;
    $cursor->finish;
    $self->db_disconnect;

    return $self->render(json => { time => $data });
};

get '/taReport/:id' => sub {
    my $self  = shift;
    my $id  = $self->stash('id');

    my $SQL;
    
    if ( $id =~ /(CA|US)\-[A-Z]{1}\d{3}/ ) {
	$SQL = "select PatientID, VisitOfLastTARun, Problem, DateMostRecentLab, DateLastVisit, DateLastTARun from TAReports where SiteID = '$id' and isThisMostRecent = 1 order by PatientID";
    } 
    else {
	$SQL = "select PatientID, VisitOfLastTARun, Problem, DateMostRecentLab, DateLastVisit, DateLastTARun from TAReports inner join ( SELECT SiteID  FROM `SiteMetrics` WHERE `Liaison` = '$id' and `isThisMostRecent` = 1 ) as t  on t.SiteID = TAReports.SiteID where TAReports.isThisMostRecent = 1 order by PatientID";
    }

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = "PatientID";
    $refhash{"1"} = "VisitOfLastTARun";
    $refhash{"2"} = "Problem";
    $refhash{"3"} = "DateMostRecentLab";
    $refhash{"4"} = "DateLastVisit";
    $refhash{"5"} = "DateLastTARun";

    foreach my $key ( keys @$data ) {
	my $i = 0;
	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
	$data->[$key] = \%tmpHash;
    }

    return $self->render(json =>  $data );
};

get '/getUpdatedTimeTAReport/' => sub {
    my $self  = shift;

    my $SQL = "SELECT Created FROM TAReports WHERE isThisMostRecent = 1 order by id limit 1";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchrow;
    $cursor->finish;
    $self->db_disconnect;

    return $self->render(json => { time => $data });
};


get '/missingLab/:id' => sub {
    my $self  = shift;
    my $id  = $self->stash('id');

    my $SQL;

    if ( $id =~ /(CA|US)\-[A-Z]{1}\d{3}/ ) {
	$SQL = "select PatientID, VisitDesignation, VisitDate, BloodCollectionDate, NextVisitDate, BwhComments, raComments, id from MissingLabs where SiteID = '$id' and isThisMostRecent = 1 order by PatientID";
    }
    else {
	$SQL = "select PatientID, VisitDesignation, VisitDate, BloodCollectionDate, NextVisitDate, BwhComments, raComments, id from MissingLabs inner join ( SELECT SiteID  FROM `SiteMetrics` WHERE `Liaison` = '$id' and `isThisMostRecent` = 1 ) as t  on t.SiteID = MissingLabs.SiteID where MissingLabs.isThisMostRecent = 1 order by PatientID";
    }

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = "PatientID";
    $refhash{"1"} = "VisitDesignation";
    $refhash{"2"} = "VisitDate";
    $refhash{"3"} = "BloodCollectionDate";
    $refhash{"4"} = "NextVisitDate";
    $refhash{"5"} = "BwhComments";
    $refhash{"6"} = "raComments";
    $refhash{"7"} = "id";

    foreach my $key ( keys @$data ) {
	my $i = 0;
	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
	$data->[$key] = \%tmpHash;
    }

    return $self->render(json =>  $data );
};

post '/updateMissingLabRAComments' => sub {
    my $self  = shift;

    my $id = $self->param('id');
    my $comments = $self->param('comments');

    # # Make sure we escape the incoming data...
    $comments = $self->db->quote($comments);

    # # # # my $SQL = "insert into test (id, name) values ($id,$data)";
    # # # my $SQL = "insert into test (name) values ($data)";
    my $SQL = "update MissingLabs set raComments = $comments where id = $id;";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;
    my $new_id = $cursor->{mysql_insertid};
    $cursor->finish;
    $self->db_disconnect;
    
#    if($new_id){
    if( 1 ){
    	return $self->render(json => {result => "1", message => "OK"});
	# return $self->render(json => {result => "1", message => $SQL });
    }else{
     	return $self->render(json => {result => "0", message => "Insert Failure"});
    }

};

post '/sendEmailWithComments' => sub {
    my $self  = shift;

    my $issue = $self->param('issue');
    my $pid = $self->param('pid');
    my $visit = $self->param('visit');
    my $BwhComments = $self->param('BwhComments');
    my $raComments = $self->param('raComments');
    my $sender = $self->param('by');

    my $title = "[" .  $issue . "] " . $pid . " " . $visit . " from " . $sender;
    my $body = "BWH Comments : " . $BwhComments . "\n". "RA Comments : " . $raComments;

    my $msg = MIME::Lite->new(
	From => 'hpaik@partners.org',
	To => 'hpaik@partners.org,MRIEUWERDEN@PARTNERS.ORG, fhisoler@PARTNERS.ORG, ypark11@partners.org, AVTHOMSON@PARTNERS.ORG',
	# To => 'hpaik@partners.org',
	Subject => $title,
	Data => $body
	);

    $msg->send;
    
#    if($new_id){
    if( 1 ){
    	return $self->render(json => {result => "1", message => "OK"});
	# return $self->render(json => {result => "1", message => $SQL });
    }else{
     	return $self->render(json => {result => "0", message => "Insert Failure"});
    }

};

get '/edcIncomplete/:id' => sub {
    my $self  = shift;
    my $id  = $self->stash('id');

    my $SQL;

    if ( $id =~ /(CA|US)\-[A-Z]{1}\d{3}/ ) {
	$SQL = "select PatientID, VisitDesignation, VisitDate, CentralLabCollectedDate, LabDate, Problem from EDCincomplete where SiteID = '$id' and isThisMostRecent = 1 order by PatientID";
    }
    else {
	$SQL = "select PatientID, VisitDesignation, VisitDate, CentralLabCollectedDate, LabDate, Problem from EDCincomplete inner join ( SELECT SiteID  FROM `SiteMetrics` WHERE `Liaison` = '$id' and `isThisMostRecent` = 1 ) as t  on t.SiteID = EDCincomplete.SiteID where EDCincomplete.isThisMostRecent = 1 order by PatientID";
    }
    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = "PatientID";
    $refhash{"1"} = "VisitDesignation";
    $refhash{"2"} = "VisitDate";
    $refhash{"3"} = "CentralLabCollectedDate";
    $refhash{"4"} = "LabDate";
    $refhash{"5"} = "Problem";

    foreach my $key ( keys @$data ) {
	my $i = 0;
	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
	$data->[$key] = \%tmpHash;
    }

    return $self->render(json =>  $data );
};

get '/tempStop/:id' => sub {
    my $self  = shift;
    my $id  = $self->stash('id');

    my $SQL;

    if ( $id =~ /(CA|US)\-[A-Z]{1}\d{3}/ ) {
	$SQL = "select PatientID, StopDate, datediff( now(), StopDate ) as DaysOff, Reason, Comments, MostRecentVisitDate, id, FollowUpDate, ReVisitDT from TempStops where SiteID = '$id' and isCurrent = 1 order by PatientID";
    }
    else {
	$SQL = "select PatientID, StopDate, datediff( now(), StopDate ) as DaysOff, Reason, Comments, MostRecentVisitDate, id, FollowUpDate, ReVisitDT from TempStops inner join ( SELECT SiteID  FROM `SiteMetrics` WHERE `Liaison` = '$id' and `isThisMostRecent` = 1 ) as t  on t.SiteID = TempStops.SiteID where TempStops.isCurrent = 1 order by PatientID";
    }
    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = "PatientID";
    $refhash{"1"} = "StopDate";
    $refhash{"2"} = "DaysOff";
    $refhash{"3"} = "Reason";
    $refhash{"4"} = "Comments";
    $refhash{"5"} = "MostRecentVisitDate";
    $refhash{"6"} = "id";
    $refhash{"7"} = "FollowUpDate";
    $refhash{"8"} = "ReVisitDT";

    foreach my $key ( keys @$data ) {
	my $i = 0;
	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
	$data->[$key] = \%tmpHash;
    }

    return $self->render(json =>  $data );
};

get '/getUpdatedTimeTempStop/' => sub {
    my $self  = shift;

    my $SQL = "SELECT Created FROM `TempStops` WHERE isCurrent = 1 order by Created desc limit 1";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchrow;
    $cursor->finish;
    $self->db_disconnect;

    return $self->render(json => { time => $data });
};

get '/recvPermStop/:id' => sub {
    my $self  = shift;
    my $id  = $self->stash('id');

    my $SQL;

    if ( $id =~ /(CA|US)\-[A-Z]{1}\d{3}/ ) {
	$SQL = "select PatientID, StopDate, datediff( now(), StopDate ) as DaysOff, Reason, Comments, MostRecentVisitDate, FollowUpDate, id, ReVisitDT from RecoverablePermStops where SiteID = '$id' and isCurrent = 1 order by PatientID";
    }
    else {
	$SQL = "select PatientID, StopDate, datediff( now(), StopDate ) as DaysOff, Reason, Comments, MostRecentVisitDate, FollowUpDate, id, ReVisitDT from RecoverablePermStops inner join ( SELECT SiteID  FROM `SiteMetrics` WHERE `Liaison` = '$id' and `isThisMostRecent` = 1 ) as t  on t.SiteID = RecoverablePermStops.SiteID and RecoverablePermStops.isCurrent = 1 order by PatientID";
    }
    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = "PatientID";
    $refhash{"1"} = "StopDate";
    $refhash{"2"} = "DaysOff";
    $refhash{"3"} = "Reason";
    $refhash{"4"} = "Comments";
    $refhash{"5"} = "MostRecentVisitDate";
    $refhash{"6"} = "FollowUpDate";
    $refhash{"7"} = "id";
    $refhash{"8"} = "ReVisitDT";

    foreach my $key ( keys @$data ) {
	my $i = 0;
	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
	$data->[$key] = \%tmpHash;
    }

    return $self->render(json =>  $data );
};


get '/getUpdatedTimeRecPermStop/' => sub {
    my $self  = shift;

    my $SQL = "SELECT Created FROM `RecoverablePermStops` WHERE isCurrent = 1 order by Created desc limit 1";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchrow;
    $cursor->finish;
    $self->db_disconnect;

    return $self->render(json => { time => $data });
};

get '/getV2s/:id' => sub {
    my $self  = shift;
    my $id = $self->stash( 'id' );

    my $SQL;

    if ( $id =~ /(CA|US)\-[A-Z]{1}\d{3}/ ) {
	$SQL = "SELECT PatientID, V1Date, V2Date, V2Deadline, Status from V2 where SiteID = '$id' AND isThisMostRecent = 1 ORDER BY PatientID";
    } else {
	$SQL = "SELECT PatientID, V1Date, V2Date, V2Deadline, Status from V2 inner join ( SELECT SiteID from `SiteMetrics` WHERE `Liaison` = '$id' and isThisMostRecent = 1 ) as t on t.SiteID = V2.SiteID where V2.isThisMostRecent = 1 order by PatientID";
    }

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;                                                                                                                        
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = 'PatientID';
    $refhash{"1"} = 'V1Date';
    $refhash{"2"} = 'V2Date';
    $refhash{"3"} = 'V2Deadline';
    $refhash{"4"} = 'Status';

    foreach my $key ( keys @$data ) {
        my $i = 0;
	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
        $data->[$key] = \%tmpHash;
    }
    
    return $self->render( json => $data );                                                                                                           
};


get '/getUpdatedTimeV2/' => sub {
    my $self  = shift;
    my $SQL = "SELECT Created FROM V2 WHERE isThisMostRecent = 1 order by id desc limit 1";
    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchrow;
    $cursor->finish;
    $self->db_disconnect;

    return $self->render(json => { time => $data });
};

get '/getV4s/:id' => sub {
    my $self  = shift;
    my $id = $self->stash( 'id' );

    my $SQL;

    if ( $id =~ /(CA|US)\-[A-Z]{1}\d{3}/ ) {
	$SQL = "SELECT PatientID, V3Date, CentralLabDate, NextVisitDate from V4 where SiteID = '$id' AND isThisMostRecent = 1 ORDER BY PatientID";
    } else {
	$SQL = "SELECT PatientID, V3Date, CentralLabDate, NextVisitDate from V4 inner join ( SELECT SiteID from `SiteMetrics` WHERE `Liaison` = '$id' and isThisMostRecent = 1 ) as t on t.SiteID = V4.SiteID where V4.isThisMostRecent = 1 order by PatientID";
    }

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;                                                                                                                        
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = 'PatientID';
    $refhash{"1"} = 'V3Date';
    $refhash{"2"} = 'CentralLabDate';
    $refhash{"3"} = 'NextVisitDate';

    foreach my $key ( keys @$data ) {
        my $i = 0;
	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
        $data->[$key] = \%tmpHash;
    }
    
    return $self->render( json => $data );                                                                                                           
};

get '/getUpdatedTimeV4/' => sub {
    my $self  = shift;
    my $SQL = "SELECT Created FROM V4 WHERE isThisMostRecent = 1 order by id desc limit 1";
    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchrow;
    $cursor->finish;
    $self->db_disconnect;

    return $self->render(json => { time => $data });
};


post '/updateRecPermStopComments' => sub {
    my $self  = shift;

    my $id = $self->param('id');
    my $comments = $self->param('comments');
    my $followupDate = $self->param('followupDate');
    my $revisitDate = $self->param('revisitDate');
    # my $json_data = $self->param('json');
#    my $date = $self->date;

    # my $hash = decode_json($json_data);
   
    # my $id = $hash->{'id'};
    # my $comments = $hash->{'comments'};


    # # Make sure we escape the incoming data...
    $comments = $self->db->quote($comments);
    $followupDate = $self->db->quote($followupDate);
    $revisitDate = $self->db->quote($revisitDate);

    # # # # #my $SQL = "insert into my_table (id, data) values ('$id',$data)";
    # # # # my $SQL = "insert into test (id, name) values ($id,$data)";
    # # # my $SQL = "insert into test (name) values ($data)";
    my $SQL = "update RecoverablePermStops set Comments = CONCAT(COALESCE(`Comments`, ''), $comments), FollowUpDate = $followupDate, ReVisitDT = $revisitDate where id = $id;";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;
    my $new_id = $cursor->{mysql_insertid};
    $cursor->finish;
    $self->db_disconnect;
    
#    if($new_id){
    if( 1 ){
    	return $self->render(json => {result => "1", message => "OK"});
	# return $self->render(json => {result => "1", message => $SQL });
    }else{
     	return $self->render(json => {result => "0", message => "Insert Failure"});
    }

};

post '/updateTempStopComments' => sub {
    my $self  = shift;

    my $id = $self->param('id');
    my $comments = $self->param('comments');
    my $followupDate = $self->param('followupDate');
    my $revisitDate = $self->param('revisitDate');
    # my $json_data = $self->param('json');
    # my $hash = decode_json($json_data);
    # my $id = $hash->{'id'};
    # my $comments = $hash->{'comments'};

    # Make sure we escape the incoming data...
    $comments = $self->db->quote($comments);
    $followupDate = $self->db->quote($followupDate);
    $revisitDate = $self->db->quote($revisitDate);

    # # # # #my $SQL = "insert into my_table (id, data) values ('$id',$data)";
    # # # # my $SQL = "insert into test (id, name) values ($id,$data)";
    # # # my $SQL = "insert into test (name) values ($data)";
    ## my $SQL = "update TempStops set Comments = CONCAT(COALESCE(`Comments`, ''), $comments) where id = $id;";
    my $SQL = "update TempStops set Comments = CONCAT(COALESCE(`Comments`, ''), $comments), FollowUpDate = $followupDate, ReVisitDT = $revisitDate where id = $id;";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;
    my $new_id = $cursor->{mysql_insertid};
    $cursor->finish;
    $self->db_disconnect;
    
    # if($new_id){
    if( 1 ){
    	return $self->render(json => {result => "1", message => "OK"});
	# return $self->render(json => {result => "1", message => $SQL });
    }else{
     	return $self->render(json => {result => "0", message => "Insert Failure"});
    }

};

post '/createLog' => sub {
    my $self  = shift;

    my $bwhStaff = $self->param('bwhStaff');
    my $siteid = $self->param('siteid');
    my $message = $self->param('message');
    my $hashtag = $self->param('hashtag');

    # Make sure we escape the incoming data...
    $bwhStaff = $self->db->quote($bwhStaff);
    $siteid = $self->db->quote($siteid);
    $message = $self->db->quote($message);
    $hashtag = $self->db->quote($hashtag);

    my $SQL = "insert into messages (bwhStaff, siteid, message, hashtag) values ($bwhStaff,  $siteid, $message, $hashtag )";
    # # # # my $SQL = "insert into test (id, name) values ($id,$data)";
    # # # my $SQL = "insert into test (name) values ($data)";
    ## my $SQL = "update TempStops set Comments = CONCAT(COALESCE(`Comments`, ''), $comments) where id = $id;";
    ###my $SQL = "update TempStops set Comments = CONCAT(COALESCE(`Comments`, ''), $comments), FollowUpDate = $followupDate, ReVisitDT = $revisitDate where id = $id;";
    
    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;
    my $new_id = $cursor->{mysql_insertid};
    $cursor->finish;
    $self->db_disconnect;
    
    if($new_id){
    # if( 1 ){
    	return $self->render(json => {result => "1", message => "OK"});
	# return $self->render(json => {result => "1", message => $SQL });
    }else{
     	return $self->render(json => {result => "0", message => "Insert Failure"});
    }

};


post '/updateRecPermStopComments' => sub {
    my $self  = shift;

    my $id = $self->param('id');
    my $comments = $self->param('comments');
    my $followupDate = $self->param('followupDate');
    my $revisitDate = $self->param('revisitDate');
    # my $json_data = $self->param('json');
#    my $date = $self->date;

    # my $hash = decode_json($json_data);
   
    # my $id = $hash->{'id'};
    # my $comments = $hash->{'comments'};


    # # Make sure we escape the incoming data...
    $comments = $self->db->quote($comments);
    $followupDate = $self->db->quote($followupDate);
    $revisitDate = $self->db->quote($revisitDate);

    # # # # #my $SQL = "insert into my_table (id, data) values ('$id',$data)";
    # # # # my $SQL = "insert into test (id, name) values ($id,$data)";
    # # # my $SQL = "insert into test (name) values ($data)";
    my $SQL = "update RecoverablePermStops set Comments = CONCAT(COALESCE(`Comments`, ''), $comments), FollowUpDate = $followupDate, ReVisitDT = $revisitDate where id = $id;";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;
    my $new_id = $cursor->{mysql_insertid};
    $cursor->finish;
    $self->db_disconnect;
    
#    if($new_id){
    if( 1 ){
    	return $self->render(json => {result => "1", message => "OK"});
	# return $self->render(json => {result => "1", message => $SQL });
    }else{
     	return $self->render(json => {result => "0", message => "Insert Failure"});
    }

};

post '/updateTempStopComments' => sub {
    my $self  = shift;

    my $id = $self->param('id');
    my $comments = $self->param('comments');
    my $followupDate = $self->param('followupDate');
    my $revisitDate = $self->param('revisitDate');
    # my $json_data = $self->param('json');
    # my $hash = decode_json($json_data);
    # my $id = $hash->{'id'};
    # my $comments = $hash->{'comments'};

    # Make sure we escape the incoming data...
    $comments = $self->db->quote($comments);
    $followupDate = $self->db->quote($followupDate);
    $revisitDate = $self->db->quote($revisitDate);

    # # # # #my $SQL = "insert into my_table (id, data) values ('$id',$data)";
    # # # # my $SQL = "insert into test (id, name) values ($id,$data)";
    # # # my $SQL = "insert into test (name) values ($data)";
    ## my $SQL = "update TempStops set Comments = CONCAT(COALESCE(`Comments`, ''), $comments) where id = $id;";
    my $SQL = "update TempStops set Comments = CONCAT(COALESCE(`Comments`, ''), $comments), FollowUpDate = $followupDate, ReVisitDT = $revisitDate where id = $id;";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;
    my $new_id = $cursor->{mysql_insertid};
    $cursor->finish;
    $self->db_disconnect;
    
    # if($new_id){
    if( 1 ){
    	return $self->render(json => {result => "1", message => "OK"});
	# return $self->render(json => {result => "1", message => $SQL });
    }else{
     	return $self->render(json => {result => "0", message => "Insert Failure"});
    }

};

####################################


get '/tweets/' => sub {
    my $self  = shift;

    my $siteid = $self->param( 'siteid' );
    my $keyword = $self->param( 'keyword' );
    
    # $siteid = $self->db->quote( $siteid );

    my $SQL;

    if ( $siteid ) {

	$siteid = $self->db->quote( $siteid );

	if ( $keyword ) {
#	$keyword = $self->db->quote( $keyword );
	    $SQL = "select bwhStaff, message, Created, siteid from messages where siteid = $siteid and hashtag like '%$keyword%' order by Created DESC";
	} else {
	$SQL = "select bwhStaff, message, Created, siteid from messages where siteid = $siteid order by Created DESC";
	}
    } else {
	if ( $keyword ) {
#	$keyword = $self->db->quote( $keyword );
	    $SQL = "select bwhStaff, message, Created, siteid from messages where hashtag like '%$keyword%' order by Created DESC LIMIT 1000";
	} else {
	$SQL = "select bwhStaff, message, Created, siteid from messages order by Created DESC LIMIT 1000";
	}
    }

    # return $self->render( txt => $siteid );

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = "bwhStaff";
    $refhash{"1"} = "message";
    $refhash{"2"} = "time";
    $refhash{"3"} = "siteid";

    # foreach my $key ( keys @$data ) {
    # 	my $i = 0;
    # 	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
    # 	$data->[$key] = \%tmpHash;
    # }

    # foreach my $key ( keys @$data ) {
    # 	print $data->[$key]->[1],"\n";
    # }

    foreach my $key ( keys @$data ) {
    	my $i = 0;
    	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
    	$tmpHash{'message'} =~ s/#(\w{2,25})/<a href="javascript:updateTwitterSource('$1')">#$1<\/a>/g ;
    	$tmpHash{'bwhStaff'} =~ s/#(\w{2,15})/<a href="javascript:updateTwitterSource('$1')">#$1<\/a>/g ;
    	$data->[$key] = \%tmpHash;
    }

    return $self->render(json =>  $data );
};

get '/raTweets/' => sub {
    my $self  = shift;

    my $siteid = $self->param( 'siteid' );
    my $keyword = $self->param( 'keyword' );
    
    # $siteid = $self->db->quote( $siteid );

    my $SQL;

    if ( $siteid ) {

	$siteid = $self->db->quote( $siteid );

	if ( $keyword ) {
#	$keyword = $self->db->quote( $keyword );
	    $SQL = "select bwhStaff, message, Created, siteid from messages where siteid = $siteid and hashtag like '%$keyword%' order by Created DESC";
	} else {
	$SQL = "select bwhStaff, message, Created, siteid from messages where siteid = $siteid order by Created DESC";
	}
    } else {
	if ( $keyword ) {
	    #$SQL = "select bwhStaff, message, Created, siteid from messages where hashtag like '%$keyword%' order by Created DESC LIMIT 1000";
	    $SQL = "select a.bwhStaff, a.message, a.Created, a.siteid, b.PI
from ( select bwhStaff, message, Created, siteid from messages where hashtag like '%$keyword%' order by Created DESC LIMIT 1000 ) as a
left join ( select * from SiteMetrics where isThisMostRecent = 1) as b
on a.siteid = b.SiteID";
	} else {
	    $SQL = "select a.bwhStaff, a.message, a.Created, a.siteid, b.PI
from ( select bwhStaff, message, Created, siteid from messages order by Created DESC LIMIT 2000 ) as a
left join ( select * from SiteMetrics where isThisMostRecent = 1) as b
on a.siteid = b.SiteID";
	}    }

    # return $self->render( txt => $siteid );

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = "bwhStaff";
    $refhash{"1"} = "message";
    $refhash{"2"} = "time";
    $refhash{"3"} = "siteid";
    $refhash{"4"} = "PI";

    # foreach my $key ( keys @$data ) {
    # 	my $i = 0;
    # 	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
    # 	$data->[$key] = \%tmpHash;
    # }

    # foreach my $key ( keys @$data ) {
    # 	print $data->[$key]->[1],"\n";
    # }

    foreach my $key ( keys @$data ) {
    	my $i = 0;
    	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
    	$tmpHash{'message'} =~ s/#(\w{2,15})/<a href="javascript:updateTwitterSource('$1')">#$1<\/a>/g ;
    	$tmpHash{'bwhStaff'} =~ s/#(\w{2,15})/<a href="javascript:updateTwitterSource('$1')">#$1<\/a>/g ;
    	$data->[$key] = \%tmpHash;
    }

    return $self->render(json =>  $data );
};

post '/sendEmail/' => sub {
    my $self = shift;

    my $title = $self->param('title');
    my $body = $self->param('body');
    my $to = $self->param('to');

    my $msg = MIME::Lite->new(
	From     => 'hpaik@partners.org',
	To       => $to,
	Subject => $title,
	Data => $body
	);

    $msg->send;

    return $self->render(json => {result => "1", message => "OK"});

};


get '/getIndexEvents/' => sub {
    my $self  = shift;
    
#    my $SQL = "select SiteID, PI, Liaison, SiteInitializationDate, NInformedConsent, NScreened, MostRecentScreeningDate, EnrolledOverScreened, NStartedRunin, NRandomized, BucketProgrammed, BucketByRA, id, SC from SiteMetrics where isThisMostRecent = 1 order by id";
    # my $SQL = "select SiteID, PI, Liaison, SiteInitializationDate, NInformedConsent, NScreened, MostRecentScreeningDate, EnrolledOverScreened, NStartedRunin, NRandomized, BucketProgrammed, BucketByRA from SiteMetrics where isThisMostRecent = 1 order by id";
#  my $SQL = ' SELECT SM.SiteID, SUBSTRING_INDEX( SM.PI, " - ", 1) as PI, SUBSTRING_INDEX(SM.PI, " - ", -1) as Clinic,  CO.CoI, SC.SC, SUBSTRING_INDEX(Location, ", ", 1) as City, SUBSTRING_INDEX( Location, ", ", -1) as State, SM.Liaison
# FROM `SiteMetrics` as SM
#    LEFT JOIN (    SELECT SiteID, GROUP_CONCAT( concat( PiCoordsContactEDC.FirstName, " ", PiCoordsContactEDC.LastName)  SEPARATOR ', ') as SC from PiCoordsContactEDC WHERE Role = "SC" group by SiteID order by SiteID ) as SC
#    ON SM.SiteID = SC.SiteID
#    LEFT JOIN ( SELECT SiteID, GROUP_CONCAT( PiCoordsContactEDC.LastName  SEPARATOR ', ') as CoI from PiCoordsContactEDC WHERE Role = "CI" group by SiteID order by SiteID ) as CO
#    ON SM.SiteID = CO.SiteID
# WHERE `isThisMostRecent` = 1
# order by SM.SiteID';

    # my $SQL = ' SELECT PatientID, ICFDate, ReceivedDate, IndexEvent, MI, CAD, MI_CAD, WaitingForMoreInfo, ChildBearing, AllRecords, Withdrawn, DCCcomments, LiaisonComments, Reviewer, ReviewedDate, EDC_MI, EDC_CAD, IndexEventDate, EnteredBy, Box, Notif, NotifDate from indexEvents order by PatientID;';
    
    #my $SQL = 'select i.PatientID, b.CONSDT as ICFDate, i.ReceivedDate, i.IndexEvent, i.MI, i.CAD, i.MI_CAD, i.WaitingForMoreInfo, i.ChildBearing, i.AllRecords, i.Withdrawn, i.DCCcomments, i.LiaisonComments, i.Reviewer, i.ReviewedDate, b.MI as EDC_MI, b.CAD as EDC_CAD, if( b.MIDT < b.CAGDT, b.CAGDT, b.MIDT  ) as IndexEventDate, i.EnteredBy, i.Box, i.Notif, i.NotifDate from indexEvents i inner join baseline b on i.PatientID = b.PATID order by b.PATID;';
    my $SQL = "select i.PatientID, b.CONSDT as ICFDate, i.ReceivedDate, i.IndexEvent, i.MI, i.CAD, i.MI_CAD, i.WaitingForMoreInfo, i.ChildBearing, i.AllRecords, if( b.STATUS = 4 OR b.STATUS = 5, 'yes', '' ) as Withdrawn, i.DCCcomments, i.LiaisonComments, i.Reviewer, i.ReviewedDate, b.MI as EDC_MI, b.CAD as EDC_CAD, if( b.MIDT < b.CAGDT, b.CAGDT, b.MIDT  ) as IndexEventDate, i.EnteredBy, i.Box, i.Notif, i.NotifDate from indexEvents i inner join ( select baseline.PATID, w.STATUS, MI, CAD, MIDT, CAGDT, CONSDT from baseline left join (select withdrawal.STATUS, withdrawal.PATID from withdrawal where STATUS > 3) as w on baseline.PATID = w.PATID ) as b on i.PatientID = b.PATID order by b.CONSDT DESC;";


    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = "PatientID";
    $refhash{"1"} = "ICFDate";
    $refhash{"2"} = "ReceivedDate";
    $refhash{"3"} = "IndexEvent";
    $refhash{"4"} = "MI";
    $refhash{"5"} = "CAD";
    $refhash{"6"} = "MI_CAD";
    $refhash{"7"} = "WaitingForMoreInfo";
    $refhash{"8"} = "ChildBearing";
    $refhash{"9"} = "AllRecords";
    $refhash{"10"} = "Withdrawn";
    $refhash{"11"} = "DCCcomments";
    $refhash{"12"} = "LiaisonComments";
    $refhash{"13"} = "Reviewer";
    $refhash{"14"} = "ReviewedDate";
    $refhash{"15"} = "EDC_MI";
    $refhash{"16"} = "EDC_CAD";
    $refhash{"17"} = "IndexEventDate";
    $refhash{"18"} = "EnteredBy";
    $refhash{"19"} = "Box";
    $refhash{"20"} = "Notif";
    $refhash{"21"} = "NotifDate";

    foreach my $key ( keys @$data ) {
    	my $i = 0;
    	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
 
	##$tmpHash{'PatientID'} = "<a href=\"/cirt/iEventCover/".$tmpHash{'PatientID'}."\" target=\"_blank\">".$tmpHash{'PatientID'}."</a>";
	$tmpHash{'PatientID'} = "<a href=\"/cirt/iEventCover/".$tmpHash{'PatientID'}."\">".$tmpHash{'PatientID'}."</a>";
   	$data->[$key] = \%tmpHash;
    }

    # foreach my $key ( keys @$data ) {
    # 	my $i = 0;
    # 	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
    # 	$tmpHash{'SiteID'} = "<a href=\"/cirt/site/".$tmpHash{'SiteID'}."\" >".$tmpHash{'SiteID'}."</a>";
    # 	$tmpHash{'Liaison'} = "<a href=\"/cirt/liaison/".$tmpHash{'Liaison'}."\" target=\"_blank\">".$tmpHash{'Liaison'}."</a>";
    # 	$data->[$key] = \%tmpHash;
    # }

    return $self->render(json =>  $data );
    # return $self->render(json => {result => "1", message => "OK"});
    # return $self->render(json => {result => "1", message => "$SQL"});
};

get '/getIndexEventsCSV.csv/' => sub {
    my $self  = shift;
    
#    my $SQL = "select SiteID, PI, Liaison, SiteInitializationDate, NInformedConsent, NScreened, MostRecentScreeningDate, EnrolledOverScreened, NStartedRunin, NRandomized, BucketProgrammed, BucketByRA, id, SC from SiteMetrics where isThisMostRecent = 1 order by id";
    # my $SQL = "select SiteID, PI, Liaison, SiteInitializationDate, NInformedConsent, NScreened, MostRecentScreeningDate, EnrolledOverScreened, NStartedRunin, NRandomized, BucketProgrammed, BucketByRA from SiteMetrics where isThisMostRecent = 1 order by id";
#  my $SQL = ' SELECT SM.SiteID, SUBSTRING_INDEX( SM.PI, " - ", 1) as PI, SUBSTRING_INDEX(SM.PI, " - ", -1) as Clinic,  CO.CoI, SC.SC, SUBSTRING_INDEX(Location, ", ", 1) as City, SUBSTRING_INDEX( Location, ", ", -1) as State, SM.Liaison
# FROM `SiteMetrics` as SM
#    LEFT JOIN (    SELECT SiteID, GROUP_CONCAT( concat( PiCoordsContactEDC.FirstName, " ", PiCoordsContactEDC.LastName)  SEPARATOR ', ') as SC from PiCoordsContactEDC WHERE Role = "SC" group by SiteID order by SiteID ) as SC
#    ON SM.SiteID = SC.SiteID
#    LEFT JOIN ( SELECT SiteID, GROUP_CONCAT( PiCoordsContactEDC.LastName  SEPARATOR ', ') as CoI from PiCoordsContactEDC WHERE Role = "CI" group by SiteID order by SiteID ) as CO
#    ON SM.SiteID = CO.SiteID
# WHERE `isThisMostRecent` = 1
# order by SM.SiteID';

    # my $SQL = ' SELECT PatientID, ICFDate, ReceivedDate, IndexEvent, MI, CAD, MI_CAD, WaitingForMoreInfo, ChildBearing, AllRecords, Withdrawn, DCCcomments, LiaisonComments, Reviewer, ReviewedDate, EDC_MI, EDC_CAD, IndexEventDate, EnteredBy, Box, Notif, NotifDate from indexEvents order by PatientID;';
    
    #my $SQL = 'select i.PatientID, b.CONSDT as ICFDate, i.ReceivedDate, i.IndexEvent, i.MI, i.CAD, i.MI_CAD, i.WaitingForMoreInfo, i.ChildBearing, i.AllRecords, i.Withdrawn, i.DCCcomments, i.LiaisonComments, i.Reviewer, i.ReviewedDate, b.MI as EDC_MI, b.CAD as EDC_CAD, if( b.MIDT < b.CAGDT, b.CAGDT, b.MIDT  ) as IndexEventDate, i.EnteredBy, i.Box, i.Notif, i.NotifDate from indexEvents i inner join baseline b on i.PatientID = b.PATID order by b.PATID;';

    #my $SQL = "select i.PatientID, b.CONSDT as ICFDate, i.ReceivedDate, i.IndexEvent, i.MI, i.CAD, i.MI_CAD, i.WaitingForMoreInfo, i.ChildBearing, i.AllRecords, if( b.STATUS = 4, 'yes', '' ) as Withdrawn, i.DCCcomments, i.LiaisonComments, i.Reviewer, i.ReviewedDate, b.MI as EDC_MI, b.CAD as EDC_CAD, if( b.MIDT < b.CAGDT, b.CAGDT, b.MIDT  ) as IndexEventDate, i.EnteredBy, i.Box, i.Notif, i.NotifDate from indexEvents i inner join ( select baseline.PATID, w.STATUS, MI, CAD, MIDT, CAGDT, CONSDT from baseline left join (select withdrawal.STATUS, withdrawal.PATID from withdrawal where STATUS > 3) as w on baseline.PATID = w.PATID ) as b on i.PatientID = b.PATID order by b.PATID;";

    my $SQL = "select i.ReceivedDate, i.PatientID, b.CONSDT as ICFDate,  i.IndexEvent, i.MI, i.CAD, i.MI_CAD, i.WaitingForMoreInfo, i.ChildBearing, i.AllRecords, if( b.STATUS = 4 OR b.STATUS = 5, 'yes', '' ) as Withdrawn, i.DCCcomments, i.LiaisonComments, i.Reviewer, i.ReviewedDate, b.MI as EDC_MI, b.CAD as EDC_CAD, if( b.MIDT < b.CAGDT, b.CAGDT, b.MIDT  ) as IndexEventDate, i.EnteredBy, i.Box, i.Notif, i.NotifDate from indexEvents i inner join ( select baseline.PATID, w.STATUS, MI, CAD, MIDT, CAGDT, CONSDT from baseline left join (select withdrawal.STATUS, withdrawal.PATID from withdrawal where STATUS > 3) as w on baseline.PATID = w.PATID ) as b on i.PatientID = b.PATID order by b.PATID;";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;


    require Text::CSV;

    my $csv = Text::CSV->new({binary => 1});
    my $string = '';

    my @temp = ( "ReceivedDate", "PatientID", "ICFDate", "IndexEvent", "MI", "CAD", "MI_CAD", "WaitingForMoreInfo", "ChildBearing", "AllRecords", "Withdrawn", "DCCcomments", "LiaisonComments", "Reviewer", "ReviewedDate", "EDC_MI", "EDC_CAD", "IndexEventDate", "EnteredBy", "Box", "Notif", "NotifDate");
    $csv->combine( @temp );
    $string .= $csv->string. "\n";

    for my $row (@$data) {
	$csv->combine(@$row) || die $csv->error_diag;
	$string .= $csv->string . "\n";
    }

    return $self->render( text => $string, format => 'csv' );

    # return $self->render(text =>  $data );
    # return $self->render(json => {result => "1", message => "OK"});
    # return $self->render(json => {result => "1", message => "$SQL"});
};


post '/updateIndexEvent' => sub {
    my $self  = shift;

    my $params = $self->req->params;
    my $hash = $params->to_hash;
    # print scalar keys (%$hash), "\n";
    # print values ($hash), "\n";
    my @arr;
    
    foreach my $par ( keys %$hash ) {
	next if ( $par eq "patid");
        ### print $par . " = \'" . $hash->{$par}, "\'\n";

	# if ( $par eq "NotifDate" && $hash->{"NotifDate"} eq "" ) {
	#     $hash->{"NotifDate"} = undef;
	#     $tmp = $par. " = " . $hash->{"NotifDate"};
	# } else {
	my $tmp = $par . " = \"" . $hash->{$par} . "\"";
    ## }
	push (@arr, $tmp);
    }

    # print join( ", ", @arr ),"\n";

    my $SQL = "UPDATE indexEvents SET " . join( ", ", @arr ) . " WHERE PatientID = \"" . $hash->{"patid"} . "\";";

    $SQL =~ s/\"\"/NULL/g;

    # print $SQL, "\n";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;
    my $new_id = $cursor->{mysql_insertid};
    $cursor->finish;
    $self->db_disconnect;
    
    # if($new_id){
    if( 1 ){
    	return $self->render(json => {result => "1", message => "OK"});
    	# return $self->render(json => {result => "1", message => $SQL });
    }else{
     	return $self->render(json => {result => "0", message => "Insert Failure"});
    }

};


get '/getSAEs/' => sub {
    my $self  = shift;
    
    # my $SQL = "select * from SAE_Combined;";
    ## show full tables; #this will show SAE_Combined is actually a view (a join of sae_EDC and sae_DCC
    my $SQL = "select * from SAE_Combined;";
    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    ### BINGO!!
    ##my $dataqq = { data => $cursor->fetchall_arrayref };
    ## print "***", $dataqq, "\n";
    # my $data = { data => $cursor->fetchall_hashref('PATID') };
    my @tmp = values $cursor->fetchall_hashref('ID');
    my $data = { data => \@tmp }; # this messes up the order. in client, the data table orders by REPORTEDDT desc

    ## print Dumper( $data );

    $cursor->finish;
    $self->db_disconnect;

    #$self->reply->table("json",  $data );
    return $self->render( json => $data );
};



get '/createSAEforEDC/' => sub {
    my $self = shift;

    my $params = $self->req->params;
    my $hash = $params->to_hash;

    my $SQL = "select count( * )from AE_EDC where PATID = \"" . $hash->{'PATID'} 
              . "\" and  RECNO =  " . $hash->{'RECNO'}. " ; ";

    ## run query
    ## if something is returned, pass, else insert to AEDCC table

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchrow;

    # print "$data\n";
    
    if ( $data == 1 ) {

    } else {
	my @arr;

	foreach my $par ( keys %$hash ) {
	    ##print $par, "\n";
	    my $tmp = $par . " = \"" . $hash->{$par} . "\"";
	    ##print $tmp, "\n";
	    push (@arr, $tmp);
	}

	$SQL = "insert into AE_EDC set " . join( ", ", @arr ) . " ;";

	print $SQL, "\n";
    
	$cursor = $self->db->prepare($SQL);
	$cursor->execute;
	$cursor->finish;
    }

    return $self->render(json => {result => "1", message => "OK"});
};

# post '/createSAE' => sub {
# # get '/createSAE/' => sub {
#     my $self  = shift;

#     my $params = $self->req->params;
#     my $hash = $params->to_hash;
#     # print scalar keys (%$hash), "\n";
#     # print keys ($hash), "\n";
#     # print values ($hash), "\n";

#     ##http://www.perlmonks.org/?node_id=616415

# # %hash = ( 
# #     name  => 'Rhesa',
# #     fruit => 'Mango',
# #     dog   => 'Spot',
# #     cat   => 'Stofje',
# #     );
# # %pets = (
# #     dog   => 'Spot',
# #     cat   => 'Stofje',
# #     );

# #     %pets = map { $_ => $hash{$_} }
# #     qw( dog cat );

# ## @pets{@$_} = @hash{@$_} for [qw(dog cat)];

#     ## Actually, I need 2 hashes or arrays here. One for sae_DCC, one for sae_EDC
#     ## for sae_EDC: PATID, RECNO, EVENT, STARTDT, ENDPOINT, RELATED, UNEXPECTED
#     ##my %sae_EDC = map { $_ => %$hash{$_} } qw (PATID RECNO EVENT);
#     ##my @sae_EDC{@$_} = @$hash{@$_} for [qw(PATID RECNO EVENT)]; 
    
#     my @EDC = qw (PATID RECNO EVENT STARTDT ENDPOINT RELATED UNEXPECTED);
#     my %sae_EDC;
#     @sae_EDC{ @EDC } = @$hash { @EDC };

#     # print keys ( %sae_EDC ), "\n";
#     # print values ( %sae_EDC ), "\n";

#     my @arr;

#     foreach my $par ( keys %sae_EDC ) {
#     	## print $par, "\n";
#     	my $tmp = $par . " = \"" . $hash->{$par} . "\"";
#     	push (@arr, $tmp);
#     }

#     ## print join( ", ", @arr ),"\n";

#     # REPORTEDDT needed for sorting
#     ## PROBLEM
#     my $SQL = "INSERT INTO sae_EDC SET " . join( ", ", @arr ) . ", REPORTEDDT = \"". time2str( "%Y-%m-%d %H:%M:%S", time ) ."\" ; "; 

#     #print $SQL, "\n";

#     ## for sae_DCC: PATID, RECNO, Randomized, Notes, 1stReqDT, 1stReqBy (1st only in creating a new sae)
#     my @DCC = qw (PATID RECNO Notes Randomized 1stReqDT 1stReqBy);
#     my %sae_DCC;
#     @sae_DCC{ @DCC } = @$hash { @DCC };

#     # print keys ( %sae_DCC ), "\n";
#     # print values ( %sae_DCC ), "\n";

#     @arr = ();
#     foreach my $par ( keys %sae_DCC ) {
# 	my $tmp = $par . " = \"" . $hash->{$par} . "\"";
#     	push (@arr, $tmp);
#     }

#     my $SQL2 = " INSERT INTO sae_DCC SET " . join( ", ", @arr ) . " ;";

#     #print $SQL2, "\n";

#     $SQL =~ s/\"undefined\"/NULL/g;
#     $SQL2 =~ s/\"undefined\"/NULL/g;

#     $SQL =~ s/\"\"/NULL/g;
#     $SQL2 =~ s/\"\"/NULL/g;

#     my $cursor = $self->db->prepare($SQL);
#     $cursor->execute;
#     # my $new_id = $cursor->{mysql_insertid};
#     $cursor->finish;

#     $cursor = $self->db->prepare($SQL2);
#     $cursor->execute;
#     # my $new_id = $cursor->{mysql_insertid};
#     $cursor->finish;

#     $self->db_disconnect;
    
#     # if($new_id){
#     if( 1 ){
#     	return $self->render(json => {result => "1", message => "OK"});
#     	# return $self->render(json => {result => "1", message => $SQL });
#     }else{
#      	return $self->render(json => {result => "0", message => "Insert Failure"});
#     }

# };


get '/updateSAEAE/' => sub {
#post '/updateSAEAE/' => sub {
# get '/updateSAE/' => sub {
    my $self  = shift;

    my $params = $self->req->params;
    my $hash = $params->to_hash;
    # print scalar keys (%$hash), "\n";
    # print keys ($hash), "\n";
    # print values ($hash), "\n";

    my @arr;
    foreach my $par ( keys %$hash ) {
	my $tmp = $par . " = \"" . $hash->{$par} . "\"";
    	push (@arr, $tmp);
    }

    my $SQL = " UPDATE AEDCC SET " . join( ", ", @arr ) . " WHERE PatID = \"" . $hash->{'PATID'}. "\" AND aeNo = ".  $hash->{'aeNo'}. " ;";

    $SQL =~ s/\"\"/NULL/g;
    $SQL =~ s/\"undefined\"/NULL/g;

    print $SQL, "\n";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;
    # my $new_id = $cursor->{mysql_insertid};
    $cursor->finish;
    $self->db_disconnect;
    
    # if($new_id){
    if( 1 ){
    	return $self->render(json => {result => "1", message => "OK"});
    	# return $self->render(json => {result => "1", message => $SQL });
    }else{
     	return $self->render(json => {result => "0", message => "Insert Failure"});
    }

};

post '/validatePID/' => sub {
    my $self  = shift;

    my $params = $self->req->params;
    my $hash = $params->to_hash;

    my $SQL = " select count( * ) from baseline where PATID = \"".  $hash->{'PATID'}. "\" ; ";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchrow;

    $cursor->finish;
    $self->db_disconnect;

    my $res = "";
    if ( $data == 1 ) {
	# $res = "This id exists";
    } else {
	$res = "This id does not exist";
    }

    return $self->render( text => $res );
};

post '/validateRECNO/' => sub {
    my $self  = shift;

    my $params = $self->req->params;
    my $hash = $params->to_hash;

    my $SQL = " select count( * ) from sae_EDC where PATID = \"".  $hash->{'PATID'}. "\" and  RECNO = " . $hash->{'RECNO'} . " ; ";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchrow;

    $cursor->finish;
    $self->db_disconnect;

    my $res;
    if ( $data == 1 ) {
	$res = "This AE number already exists";
    } else {
	$res = "";
    }

    return $self->render( text => $res );
};



# post '/createSAE' => sub {
get '/createIEvent/' => sub {
    my $self  = shift;

    my $params = $self->req->params;
    my $hash = $params->to_hash;

    ##http://www.perlmonks.org/?node_id=616415

    my @EDC = qw (PATID CONSDT MI MIDT CAD CAGDT GENDER AGE);
    my %iEvent_EDC;
    @iEvent_EDC{ @EDC } = @$hash { @EDC };

    # print keys ( %sae_EDC ), "\n";
    # print values ( %sae_EDC ), "\n";

    my @arr;

    foreach my $par ( keys %iEvent_EDC ) {
    	## print $par, "\n";
    	my $tmp = $par . " = \"" . $hash->{$par} . "\"";
    	push (@arr, $tmp);
    }

    ## print join( ", ", @arr ),"\n";

    my $SQL = "INSERT INTO baseline SET " . join( ", ", @arr ) . " ; ";

    # print $SQL, "\n";

    ## for indexEvents: PATID, ReceivedDate

    my $SQL2 = " INSERT INTO indexEvents SET PatientID = \"". $hash->{'PATID'}."\", ReceivedDate = \"". $hash->{'ReceivedDate'}."\", stamp_created = NULL ;";

    # print $SQL2, "\n";

    # $SQL =~ s/\"undefined\"/NULL/g;
    # $SQL2 =~ s/\"undefined\"/NULL/g;

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;
    $cursor->finish;

    $cursor = $self->db->prepare($SQL2);
    $cursor->execute;
    $cursor->finish;

    $self->db_disconnect;
    
    if( 1 ){
    	return $self->render(json => {result => "1", message => "OK"});
    }
    else{
     	return $self->render(json => {result => "0", message => "Insert Failure"});
    }

};


get '/getSAEAEs/' => sub {
     my $self  = shift;
    
# my $SQL = "
# select AEDCCID, body2.PatID, body2.Status, body2.Source, body2.Event, body2.aeNo, body2.REPORTEDDT, Notes, body2.STARTDT, 
# eventReqNo, eventReqDT, eventRecDT, eventNotes, addyReqNo, addyReqDT, addyRecDT, addyNotes,
# body2.mmRequested, DTEventSent2MM, DTaddySent2MM, Filed, ScanID, BoxNo
#  from
# (
# select AEDCCID, body.PatID , body.SiteID, body.aeNo, body.REPORTEDDT, body.EVENT, body.Status, body.Source, body.STARTDT, body.mmRequested, DTEventSent2MM, DTaddySent2MM, Filed, ScanID, BoxNo, Notes, eventReqNo, eventReqDT, eventRecDT, eventNotes from
# (
#  select AEDCC.PatID , SiteID, aeNo, REPORTEDDT, EVENT, Status, Source, STARTDT, mmRequested, DTEventSent2MM, DTaddySent2MM, Filed, ScanID, BoxNo, Notes, AEDCC.id as AEDCCID from AEDCC
# left join 
# ( select PATID, RECNO, EVENT, REPORTEDDT, STARTDT from AE_EDC
# union select PATID, RECNO, EVENT, REPORTEDDT, STARTDT from AEFromSDDR ) as EDC
# on ( AEDCC.PatID = EDC.PATID and AEDCC.aeNo = EDC.RECNO ) 
# ) as body
# left join ( select PatID, aeNo, ReqNo as eventReqNo, ReqDT as eventReqDT, RecDT as eventRecDT, Notes as eventNotes  from AEMedRecRequests where isCurrent = 1 and ReqKind = 'Event' ) as medrec
# on ( body.PatID = medrec.PatID and body.aeNo = medrec.aeNo )
#     ) as body2
# left join ( select PatID, aeNo, ReqNo as addyReqNo, ReqDT as addyReqDT, RecDT as addyRecDT, Notes as addyNotes  from AEMedRecRequests where isCurrent = 1 and ReqKind = 'Additl' ) as medrec2
# on ( body2.PatID = medrec2.PatID and body2.aeNo = medrec2.aeNo ) 
# # order by body2.REPORTEDDT desc
# ";

my $SQL = "
select AEDCCID, body2.PatID, body2.Status, body2.Source, body2.Event, body2.aeNo, body2.REPORTEDDT, Notes, body2.STARTDT,                                                                                         
eventReqNo, eventReqDT, eventRecDT, eventNotes, addyReqNo, addyReqDT, addyRecDT, addyNotes,                                                                                                                       
body2.mmRequested, DTEventSent2MM, DTaddySent2MM, Filed, ScanID, BoxNo                                                                                                                                            
 from                                                                                                                                                                                                             
(                                                                                                                                                                                                                 
select AEDCCID, body.PatID , body.SiteID, body.aeNo, body.REPORTEDDT, body.EVENT, body.Status, body.Source, body.STARTDT, body.mmRequested, DTEventSent2MM, DTaddySent2MM, Filed, ScanID, BoxNo, Notes, eventReqNo, eventReqDT, eventRecDT, eventNotes from                                                                                                                                                                          (                                                                                                                                                                                                                  select AEDCC.PatID , SiteID, aeNo, REPORTEDDT, EVENT, Status, Source, STARTDT, mmRequested, DTEventSent2MM, DTaddySent2MM, Filed, ScanID, BoxNo, Notes, AEDCC.id as AEDCCID from AEDCC                            left join                                                                                                                                                                                                          
( select PATID, RECNO, EVENT, REPORTEDDT, STARTDT from AE_EDC                                                                                                                                                      
union select PATID, RECNO, EVENT, REPORTEDDT, STARTDT from AEFromSDDR ) as EDC                                                                                                                                     
on ( AEDCC.PatID = EDC.PATID and AEDCC.aeNo = EDC.RECNO )                                                                                                                                                          
) as body                                                                                                                                                                                                          
left join ( select PatID, aeNo, ReqNo as eventReqNo, ReqDT as eventReqDT, RecDT as eventRecDT, Notes as eventNotes  from AEMedRecRequests where ReqKind = 'Event' group by PatID, aeNo having max( id ) ) as medrec                    
on ( body.PatID = medrec.PatID and body.aeNo = medrec.aeNo )                                                                                                                                                       
    ) as body2                                                                                                                                                                                                     
left join ( select PatID, aeNo, ReqNo as addyReqNo, ReqDT as addyReqDT, RecDT as addyRecDT, Notes as addyNotes  from AEMedRecRequests where ReqKind = 'Additl' group by PatID, aeNo having max( id ) ) as medrec2                      
on ( body2.PatID = medrec2.PatID and body2.aeNo = medrec2.aeNo )  

";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    ### BINGO!!
    my $dataqq = { data => $cursor->fetchall_arrayref };
    #print "***", $dataqq, "\n";
    #print Dumper( $dataqq );
    
    #my @tmp = values $cursor->fetchall_hashref('AEDCCID');
    #my $data = { data => \@tmp }; # this messes up the order. in client, the data table orders by REPORTEDDT desc

     $cursor->finish;
     $self->db_disconnect;
     return $self->render( json => $dataqq );
};

##post '/GenericInsert/' => sub {
get '/GenericInsert/' => sub {
##http://tully.dpm.bwh.harvard.edu/api/GenericInsert?TABLE=AE_EDC&PATID=US-U100-9999&RECNO=2&REPORTEDDT=2016-07-15&EVENT=test_test

    my $self  = shift;

    my $params = $self->req->params;
    my $hash = $params->to_hash;

    my $table = $hash->{'TABLE'};

    ##print "$table\n";
    ##print Dumper( $hash );
    delete $hash->{'TABLE'};
    ##print Dumper( $hash );

    my @arr;
    foreach my $par ( keys %$hash ) {
    	##print $par, "\n";
    	my $tmp = $par . " = \"" . $hash->{$par} . "\"";
        ##print $tmp, "\n";
    	push (@arr, $tmp);
    }

    my $SQL = "INSERT INTO ". $table. " SET " . join( ", ", @arr ) . " ; ";
    print $SQL, "\n";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;
    $cursor->finish;

    ###return $self->render( json => {result =>"1", message => $SQL } );
    return $self->render(json => {result => "1", message => "OK"});
};


##post '/GenericInsert/' => sub {
get '/InsertNonAE/' => sub {
##http://tully.dpm.bwh.harvard.edu/api/InsertNonAE?PATID=US-U100-0099&REPORTEDDT=2016-09-09&EVENT=test&STARTDT=2016-01-01&Source=nonAEts&Notes=lkjdlj&WrittenBy=Henry

    my $self  = shift;

    my $params = $self->req->params;
    my $hash = $params->to_hash;

    ## get RECNO from AEFromSDDR table; increase by 1; use it for inserting
    my $SQL = "select RECNO from AEFromSDDR order by RECNO desc limit 1;";

    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;    
    my $data = $cursor->fetchrow;

    my $recno = $data + 1;
    print $recno, "\n";

    ### insert AEFromSDDR
    $SQL = "insert into AEFromSDDR ( PATID, RECNO, REPORTEDDT, EVENT, STARTDT ) values ( \""
           . $hash->{'PATID'} . "\" , " . $recno . " , \"" . $hash->{'REPORTEDDT'} 
           . "\" , \"" . $hash->{'EVENT'} . "\" , \"" . $hash->{'STARTDT'} . "\" ) ; ";

    print $SQL, "\n";
    $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    ### insert AEDCC
    $SQL = "insert into AEDCC ( PATID, SiteID, aeNO, Status, Source, Notes, Created ) values ( \""
           . $hash->{'PATID'} . "\" , \"" . substr($hash->{'PATID'}, 0,7) . "\", "  .   $recno 
           . " , \"Incomplete-pending\" , \"" . $hash->{'Source'} 
           . "\",\"". $hash->{'Notes'} ."\", NULL ) ; ";

    print $SQL, "\n";
    $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    ### insert AEMedRecRequests
    $SQL = "insert into AEMedRecRequests ( PATID, SiteID, aeNo, ReqKind, ReqNo, ReqDT, WrittenBy, isCurrent, updated, created ) values ( \"" 
           . $hash->{'PATID'} . "\" , \"" . substr($hash->{'PATID'}, 0,7) . "\", "  .   $recno 
           . " , \"event\" , \"1st\",\"". strftime('%Y-%m-%d', localtime ) ."\", \"" 
           . $hash->{'WrittenBy'} . "\", 1, NULL, NULL ) ; ";

    print $SQL, "\n";
    $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    $cursor->finish;

    ###return $self->render( json => {result =>"1", message => $SQL } );
    return $self->render(json => {result => "1", message => "OK"});
};




get '/getAErequestHistory/' => sub {
     my $self  = shift;
    
     my $PATID = $self->param('PATID');
     my $aeNo = $self->param('aeNo');

     my $SQL = "select ReqKind, ReqNo, ReqDT, WrittenBy, RecDT, Notes from AEMedRecRequests where PATID = \"" . $PATID . "\" and aeNo = " . $aeNo . " order by id; ";
     my $cursor = $self->db->prepare($SQL);
     $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    my %refhash;
    $refhash{"0"} = "ReqKind";
    $refhash{"1"} = "ReqNo";
    $refhash{"2"} = "ReqDT";
    $refhash{"3"} = "WrittenBy";
    $refhash{"4"} = "RecDT";
    $refhash{"5"} = "Notes";

    foreach my $key ( keys @$data ) {
	my $i = 0;
	my %tmpHash = map { $refhash{$i++} => $_ } @{$data->[$key]};
	$data->[$key] = \%tmpHash;
    }

    return $self->render(json =>  $data );
};


get '/updateRecvdDT/' => sub {
##http://tully.dpm.bwh.harvard.edu/api/updateRecvdDT?PATID=US-U119-0003&aeNo=1&ReceivedDT=2016-01-01

     my $self  = shift;
     my $PATID = $self->param('PATID');
     my $aeNo = $self->param('aeNo');
     my $RecvdDT = $self->param('ReceivedDT');

    ## print $aeNo, "+++++++++++++++++\n";

     my $SQL = "update AEMedRecRequests set RecDT = \"" . $RecvdDT . "\", isCurrent = 0 where PATID = \"" . $PATID . "\" and aeNo = " . $aeNo . " and isCurrent = 1; ";
    print $SQL, "\n";

    my $cursor = $self->db->prepare($SQL);
    $cursor = $self->db->prepare($SQL);
    $cursor->execute;

   $SQL = "update AEDCC set Status = 'Complete' where PATID = \"" . $PATID . "\" and aeNo = " . $aeNo . " ;";
    print $SQL, "\n";

    $cursor = $self->db->prepare($SQL);
    $cursor->execute;
    $cursor->finish;
    $self->db_disconnect;

    return $self->render(json => {result => "1", message => "OK"});
};

get '/makeNewRequest/' => sub {
##http://tully.dpm.bwh.harvard.edu/api/updateRecvdDT?PATID=US-U119-0003&aeNo=1&ReceivedDT=2016-01-01

     my $self  = shift;
     my $PATID = $self->param('PATID');
     my $aeNo = $self->param('aeNo');
     my $ReqKind = $self->param('ReqKind');
     my $ReqNo = $self->param('ReqNo');
     my $ReqDT = $self->param('ReqDT');
     my $WrittenBy = $self->param('WrittenBy');
     my $Notes = $self->param('Notes');

     ## make isCurrent = 0 for the previous requests for this pt.
     my $SQL = "update AEMedRecRequests set isCurrent = 0 where PatID = \"" . $PATID . "\" AND aeNo = ". $aeNo ." AND ReqKind = \"". $ReqKind."\" ;";

   print $SQL, "\n";

    my $cursor = $self->db->prepare($SQL);
    $cursor = $self->db->prepare($SQL);
    $cursor->execute;

     ## insert AEMedRecRe
     $SQL = "insert into AEMedRecRequests set PatID = \"" . $PATID . "\", SiteID = \"" . 
               substr( $PATID, 0, 7 ) . "\", aeNo = " . $aeNo . ", isCurrent= 1, ReqKind = \"" 
               . $ReqKind . "\", ReqNo = \"". $ReqNo ."\", ReqDT = \"". $ReqDT ."\", WrittenBy = \""
               . $WrittenBy ."\" ; ";

   print $SQL, "\n";

    $cursor = $self->db->prepare($SQL);
    $cursor = $self->db->prepare($SQL);
    $cursor->execute;

   $SQL = "update AEDCC set Status = 'Incomplete-pending' where PATID = \"" . $PATID . "\" and aeNo = " . $aeNo . " ;";

   print $SQL, "\n";

    $cursor = $self->db->prepare($SQL);
    $cursor->execute;
    $cursor->finish;
    $self->db_disconnect;

    return $self->render(json => {result => "1", message => "OK"});
};


get '/getSAEAE.csv/' => sub {
    my $self  = shift;

my $SQL = "
select AEDCCID, body2.PatID, body2.Status, body2.Source, body2.Event, body2.aeNo, body2.REPORTEDDT, Notes, body2.STARTDT, 
eventReqNo, eventReqDT, eventRecDT, eventNotes, addyReqNo, addyReqDT, addyRecDT, addyNotes,
body2.mmRequested, DTEventSent2MM, DTaddySent2MM, Filed, ScanID, BoxNo
 from
(
select AEDCCID, body.PatID , body.SiteID, body.aeNo, body.REPORTEDDT, body.EVENT, body.Status, body.Source, body.STARTDT, body.mmRequested, DTEventSent2MM, DTaddySent2MM, Filed, ScanID, BoxNo, Notes, eventReqNo, eventReqDT, eventRecDT, eventNotes from
(
 select AEDCC.PatID , SiteID, aeNo, REPORTEDDT, EVENT, Status, Source, STARTDT, mmRequested, DTEventSent2MM, DTaddySent2MM, Filed, ScanID, BoxNo, Notes, AEDCC.id as AEDCCID from AEDCC
left join 
( select PATID, RECNO, EVENT, REPORTEDDT, STARTDT from AE_EDC
union select PATID, RECNO, EVENT, REPORTEDDT, STARTDT from AEFromSDDR ) as EDC
on ( AEDCC.PatID = EDC.PATID and AEDCC.aeNo = EDC.RECNO ) 
) as body
left join ( select PatID, aeNo, ReqNo as eventReqNo, ReqDT as eventReqDT, RecDT as eventRecDT, Notes as eventNotes  from AEMedRecRequests where isCurrent = 1 and ReqKind = 'Event' ) as medrec
on ( body.PatID = medrec.PatID and body.aeNo = medrec.aeNo )
    ) as body2
left join ( select PatID, aeNo, ReqNo as addyReqNo, ReqDT as addyReqDT, RecDT as addyRecDT, Notes as addyNotes  from AEMedRecRequests where isCurrent = 1 and ReqKind = 'Additl' ) as medrec2
on ( body2.PatID = medrec2.PatID and body2.aeNo = medrec2.aeNo ) 
# order by body2.REPORTEDDT desc
";
    
    my $cursor = $self->db->prepare($SQL);
    $cursor->execute;

    my $data = $cursor->fetchall_arrayref;
    $cursor->finish;
    $self->db_disconnect;

    require Text::CSV;

    my $csv = Text::CSV->new({binary => 1});
    my $string = '';

    my @temp = ( "AEDCCID", "PatientID", "Status", "Source", "Event", "aeNo", "ReportedDT", "Notes", "StartDT", "EventReqNo", "EventReqDT", "EventRecvdDT", "EventNotes", "AdditlReqNo", "AdditlReqDT", "AdditlRecvdDT", "AdditnlNotes", "MedMonRequested", "DTeventSent2MM", "ATadditnlSent2MM", "Filed", "ScanID", "BoxNo");
    $csv->combine( @temp );
    $string .= $csv->string. "\n";

    for my $row (@$data) {
	$csv->combine(@$row) || die $csv->error_diag;
	$string .= $csv->string . "\n";
    }

    return $self->render( text => $string, format => 'csv' );
};


# Start the app
app->start;

