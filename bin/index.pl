#!/usr/bin/env perl

# index.pl - make the content searchable

# Eric Lease Morgan <emorgan@nd.edu>
# May 17, 2019 - first investigations

# configure
use constant DATABASE => './etc/ital.db';
use constant DRIVER   => 'SQLite';
use constant SOLR     => 'http://localhost:8983/solr/ital';
use constant QUERY    => 'SELECT * FROM bibliographics ORDER BY bid;';
use constant TXT      => './tmp/txt';
use constant PDF      => './tmp/pdf';

# require
use DBI;
use strict;
use WebService::Solr;

# initialize
my $solr      = WebService::Solr->new( SOLR );
my $driver    = DRIVER; 
my $database  = DATABASE;
my $txt       = TXT;
my $pdf       = PDF;
my $dbh       = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;
binmode( STDOUT, ':utf8' );

# find bibliographics
my $handle = $dbh->prepare( QUERY );
$handle->execute() or die $DBI::errstr;

# process each bibliographic item
while( my $bibliographics = $handle->fetchrow_hashref ) {
	
	# parse the easy stuff
	my $bid        = $$bibliographics{ 'bid' };
	my $identifier = $$bibliographics{ 'identifier' };
	my $title      = $$bibliographics{ 'title' };
	my $abstract   = $$bibliographics{ 'abstract' };
	my $doi        = $$bibliographics{ 'doi' };
	my $words      = $$bibliographics{ 'words' };
	my $sentences  = $$bibliographics{ 'sentences' };
	my $flesch     = $$bibliographics{ 'flesch' };

	if ( $words     < 1 )     { $words = 1 }
	if ( $sentences < 1 ) { $sentences = 1 }
	if ( $flesch    < 1 )    { $flesch = 1 }
	
	# create file name
	my $file = substr( $identifier, rindex( $identifier, '/' ) + 1, length( $identifier ) );
	$file    = "$txt/$file.txt";

	# get keywords
	my @keywords       = ();
	my $subhandle = $dbh->prepare( qq(SELECT keyword FROM keywords WHERE bid='$bid' ORDER BY keyword;) );
	$subhandle->execute() or die $DBI::errstr;
	while( my @keyword = $subhandle->fetchrow_array ) { push @keywords, $keyword[ 0 ] }
	
	# get authors
	my @authors       = ();
	my $subhandle = $dbh->prepare( qq(SELECT author FROM authors WHERE bid='$bid' ORDER BY author;) );
	$subhandle->execute() or die $DBI::errstr;
	while( my @author = $subhandle->fetchrow_array ) { push @authors, $author[ 0 ] }
	
	# debug; dump
	warn "         bid: $bid\n";
	warn "  identifier: $identifier\n";
	warn "        file: $file\n";
	warn "       title: $title\n";
	warn "    abstract: $abstract\n";
	warn "         DOI: $doi\n";
	warn "       words: $words\n";
	warn "   sentences: $sentences\n";
	warn "      flesch: $flesch\n";
	warn "  keyword(s): ", join( '; ', @keywords ), "\n";
	warn "   author(s): ", join( '; ', @authors ), "\n";
	warn "\n";
	
	my $fulltext = &slurp( $file );
	$fulltext    =~ s/\r//g;
	$fulltext    =~ s/\n/ /g;
	$fulltext    =~ s/ +/ /g;
	$fulltext    =~ s/[^\x09\x0A\x0D\x20-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]//go;
	
	# create data
	my $solr_bid        = WebService::Solr::Field->new( 'bid'        => $bid );
	my $solr_identifier = WebService::Solr::Field->new( 'identifier' => $identifier );
	my $solr_fulltext   = WebService::Solr::Field->new( 'fulltext'   => $fulltext );
	my $solr_title      = WebService::Solr::Field->new( 'title'      => $title );
	my $solr_abstract   = WebService::Solr::Field->new( 'abstract'   => $abstract );
	my $solr_doi        = WebService::Solr::Field->new( 'doi'        => $doi );
	my $solr_words      = WebService::Solr::Field->new( 'words'      => $words );
	my $solr_sentences  = WebService::Solr::Field->new( 'sentences'  => $sentences );
	my $solr_flesch     = WebService::Solr::Field->new( 'flesch'     => $flesch );

	# fill a solr document with simple fields
	my $doc = WebService::Solr::Document->new;
	$doc->add_fields( $solr_bid, $solr_identifier, $solr_fulltext, $solr_title, $solr_abstract, $solr_doi, $solr_words, $solr_sentences, $solr_flesch );

	# add complex fields
	foreach ( @keywords ) { $doc->add_fields( ( WebService::Solr::Field->new( 'keywords' => $_ ) ) ) }
	foreach ( @authors )  { $doc->add_fields( ( WebService::Solr::Field->new( 'authors' => $_ ) ) ) }

	# save/index
	$solr->add( $doc );

}

# done
exit;


sub slurp {

	my $f = shift;
	open ( F, $f ) or die "Can't open $f: $!\n";
	my $r = do { local $/; <F> };
	close F;
	return $r;

}