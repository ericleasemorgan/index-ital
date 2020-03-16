#!/usr/bin/env perl

# search.pl - command-line interface to search a solr instance

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under GNU Public License

# March 15, 2010 - first cut/documentation; based on bunches o' other implementations


# configure
use constant FACETFIELD => ( facet_keywords, facet_authors, facet_entities );
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

# build a list of keyword facets
my @facet_keywords = ();
my $keyword_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_keywords } );
foreach my $facet ( sort { $$keyword_facets{ $b } <=> $$keyword_facets{ $a } } keys %$keyword_facets ) { push @facet_keywords, $facet . ' (' . $$keyword_facets{ $facet } . ')'; }

# build a list of author facets
my @facet_authors = ();
my $author_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_authors } );
foreach my $facet ( sort { $$author_facets{ $b } <=> $$author_facets{ $a } } keys %$author_facets ) { push @facet_authors, $facet . ' (' . $$author_facets{ $facet } . ')'; }

# build a list of entity facets
my @facet_entities = ();
my $entity_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_entities } );
foreach my $facet ( sort { $$entity_facets{ $b } <=> $$entity_facets{ $a } } keys %$entity_facets ) { push @facet_entities, $facet . ' (' . $$entity_facets{ $facet } . ')'; }

# start the output
print "Your search found $total item(s) and " . scalar( @hits ) . " item(s) are displayed.\n\n";
print '  keyword facets: ', join( '; ', @facet_keywords ), "\n\n";
print '   author facets: ', join( '; ', @facet_authors ), "\n\n";
print '   entity facets: ', join( '; ', @facet_entities ), "\n\n";

# loop through each document
for my $doc ( $response->docs ) {

	# re-initialize
	my $txt = TXT;
	my $pdf = PDF;

	# parse
	my $bid        = $doc->value_for(  'bid' );
	my $identifier = $doc->value_for(  'identifier' );
	my $date       = $doc->value_for(  'date' );
	my $source     = $doc->value_for(  'source' );
	my $publisher  = $doc->value_for(  'publisher' );
	my $langauge   = $doc->value_for(  'language' );
	my $title      = $doc->value_for(  'title' );
	my $abstract   = $doc->value_for(  'abstract' );
	my $doi        = $doc->value_for(  'doi' );
	my $words      = $doc->value_for(  'words' );
	my $sentences  = $doc->value_for(  'sentences' );
	my $flesch     = $doc->value_for(  'flesch' );
	my $url        = $doc->value_for(  'url' );
	my @keywords   = $doc->values_for( 'keywords' );
	my @authors    = $doc->values_for( 'authors' );
	my @entities   = $doc->values_for( 'entities' );

	# create file names
	my $file = substr( $identifier, rindex( $identifier, '/' ) + 1, length( $identifier ) );
	$txt    = "$txt/$file.txt";
	$pdf    = "$pdf/$file.pdf";
	
	# output
	print "       author(s): ", join( '; ', @authors ), "\n";
	print "           title: $title\n";
	print "            date: $date\n";
	print "          source: $source\n";
	print "       publisher: $publisher\n";
	print "        langauge: $langauge\n";
	print "        abstract: $abstract\n";
	print "      keyword(s): ", join( '; ', @keywords ), "\n";
	print "     entities(s): ", join( '; ', @entities ), "\n";
	print "             bid: $bid\n";
	print "             DOI: $doi\n";
	print "             OAI: $identifier\n";
	print "      plain text: $txt\n";
	print "  PDF (cononial): $url\n";
	print "    PDF (cached): $pdf\n";
	print "           words: $words\n";
	print "       sentences: $sentences\n";
	print "          flesch: $flesch\n";
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

