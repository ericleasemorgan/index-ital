#!/usr/bin/env perl

# search.pl - command-line interface to search a solr instance

# Eric Lease Morgan <emorgan@nd.edu>
# April 30, 2019 - first cut; based on earlier work
# May    2, 2019 - added classification and files (urls)
# July 8, 2019 - added author, title, and date


# configure
use constant FACETFIELD => ( );
use constant SOLR       => 'http://localhost:8983/solr/ital';
use constant TXT        => './tmp/txt';
use constant PDF        => './tmp/pdf';

# require
use strict;
use WebService::Solr;

# get input; sanity check
my $query = $ARGV[ 0 ];
if ( ! $query ) { die "Usage: $0 <query>\n" }

# initialize
my $solr   = WebService::Solr->new( SOLR );

# build the search options
my %search_options               = ();
$search_options{ 'facet.field' } = [ FACETFIELD ];
$search_options{ 'facet' }       = 'true';

# search
my $response = $solr->search( "$query", \%search_options );

# get the total number of hits
my $total = $response->content->{ 'response' }->{ 'numFound' };

# get number of hits returned
my @hits = $response->docs;

# start the output
print "Your search found $total item(s) and " . scalar( @hits ) . " item(s) are displayed.\n\n";

# loop through each document
for my $doc ( $response->docs ) {

	# re-initialize
	my $txt = TXT;
	my $pdf = PDF;

	# parse
	my $bid        = $doc->value_for(  'bid' );
	my $identifier = $doc->value_for(  'identifier' );
	my $title      = $doc->value_for(  'title' );
	my $abstract   = $doc->value_for(  'abstract' );
	my $doi        = $doc->value_for(  'doi' );
	my $words      = $doc->value_for(  'words' );
	my $sentences  = $doc->value_for(  'sentences' );
	my $flesch     = $doc->value_for(  'flesch' );
	my @keywords   = $doc->values_for( 'keywords' );
	my @authors    = $doc->values_for( 'authors' );

	# create file names
	my $file = substr( $identifier, rindex( $identifier, '/' ) + 1, length( $identifier ) );
	$txt    = "$txt/$file.txt";
	$pdf    = "$pdf/$file.pdf";
	
	# output
	print "   author(s): ", join( '; ', @authors ), "\n";
	print "       title: $title\n";
	print "    abstract: $abstract\n";
	print "  keyword(s): ", join( '; ', @keywords ), "\n";
	print "          id: $bid\n";
	print "         DOI: $doi\n";
	print "         OAI: $identifier\n";
	print "  plain text: $txt\n";
	print "         PDF: $pdf\n";
	print "       words: $words\n";
	print "   sentences: $sentences\n";
	print "      flesch: $flesch\n";
	print "\n";

}

# done
exit;




# convert an array reference into a hash
sub get_facets {

	my $array_ref = shift;
	
	my %facets;
	my $i = 0;
	foreach ( @$array_ref ) {
	
		my $k = $array_ref->[ $i ]; $i++;
		my $v = $array_ref->[ $i ]; $i++;
		next if ( ! $v );
		$facets{ $k } = $v;
	 
	}
	
	return \%facets;
	
}

