#!/usr/bin/perl

# bid2urls.cgi - given one more more identifiers, generate a list of urls pointing to pdf documents

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 16, 2020 - first cut, but based on (many) previous implementations


# configure
use constant QUERY    => 'SELECT url FROM bibliographics WHERE ##CLAUSE## ORDER BY bid;';
use constant DATABASE => './etc/ital.db';
use constant DRIVER   => 'SQLite';

# require
use CGI;
use CGI::Carp qw( fatalsToBrowser );
use DBI;
use strict;

# initialize
my $cgi  = CGI->new;
my $bids = $cgi->param( 'bids' );

# no input; display home page
if ( ! $bids ) {

	print $cgi->header;
	print &form;
	
}

# process input
else {

	# get input and sanitize it
	my @bids =  ();
	$bids    =~ s/[[:punct:]]/ /g;
	$bids    =~ s/ +/ /g;
	@bids    =  split( ' ', $bids );
	
	# VALIDATE INPUT HERE; we don't need to leave an opportunity for sql injection!

	# create the sql where clause and then build the whole sql query
	my @queries =  ();
	for my $bid ( @bids ) { push( @queries, "bid='$bid'" ) }
	my $sql     =  QUERY;
	$sql        =~ s/##CLAUSE##/join( ' OR ', @queries )/e;

	# execute the query
	my $driver    = DRIVER; 
	my $database  = DATABASE;
	my $dbh       = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;
	my $handle    = $dbh->prepare( $sql );
	$handle->execute() or die $DBI::errstr;

	# process each item in the found set
	my @urls = ();
	while( my @url = $handle->fetchrow_array ) { push @urls, $url[ 0 ] }

	# dump the result and done
	print $cgi->header( -type => 'text/plain', -charset => 'utf-8');
	print join( "\n", @urls ), "\n";
	
}


# done
exit;


sub form {

	return <<EOF
<html>
<head>
	<title>Information Techology and Libraries Index - Get URLs</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="stylesheet" href="/sandbox/ital/etc/style.css">
	<style>
		.item { margin-bottom: 1em }
	</style>
</head>
<div class="header">
	<h1>Information Techology and Libraries Index - Get URLs</h1>
</div>

	<div class="col-3 col-m-3 menu">
	  <ul>
		<li><a href="/sandbox/ital/search.cgi">Home</a></li>
		<li><a href="/sandbox/ital/bids2urls.cgi">Get URLs</a></li>
	 </ul>
	</div>

<div class="col-9 col-m-9">

	<p>Given a set of one or more identifiers, this program will return a list of URLs pointing to plain text versions of the items.</p>
	<form method='POST' action='/sandbox/ital/bids2urls.cgi'>
	<input type='text' name='bids' size='50' value='174 601 241 144 280 96'/>
	<input type='submit' value='Get URLs' />
	</form>

	<div class="footer">
		<p style='text-align: right'>
		Eric Lease Morgan<br />
		March 16, 2020
		</p>
	</div>

</div>

</body>
</html>
EOF
	
}


