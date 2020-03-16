#!/usr/bin/perl

# search.cgi - CGI interface to search a solr instance

# Eric Lease Morgan <emorgan@nd.edu>
# April 30, 2019 - first cut; based on Project English
# May    2, 2019 - added classification and files (urls)
# May    9, 2019 - added tsv output


# configure
use constant FACETFIELD => ( 'facet_keywords', 'facet_authors', 'facet_entities' );
use constant SOLR       => 'http://localhost:8983/solr/ital';
use constant ROWS       => 1000;
use constant TXT        => './tmp/txt';
use constant PDF        => './tmp/pdf';
use constant ROOT       => 'http://dh.crc.nd.edu/sandbox/ital';

# require
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use HTML::Entities;
use strict;
use WebService::Solr;
use URI::Encode qw( uri_encode uri_decode );

# initialize
my $cgi      = CGI->new;
my $query    = $cgi->param( 'query' );
my $html     = &template;
my $solr     = WebService::Solr->new( SOLR );

# sanitize query
my $sanitized = HTML::Entities::encode( $query );

# display the home page
if ( ! $query ) {

	$html =~ s/##QUERY##//;
	$html =~ s/##RESULTS##//;

}

# search
else {

	# re-initialize
	my $items = '';
	my @gids  = ();
	
	# build the search options
	my %search_options                   = ();
	$search_options{ 'facet.field' }     = [ FACETFIELD ];
	$search_options{ 'facet' }           = 'true';
	$search_options{ 'rows' }            = ROWS;

	# search
	my $response = $solr->search( $query, \%search_options );

	# build a list of keyword facets
	my @facet_keywords = ();
	my $keyword_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_keywords } );
	foreach my $facet ( sort { $$keyword_facets{ $b } <=> $$keyword_facets{ $a } } keys %$keyword_facets ) {
	
		my $encoded = uri_encode( $facet );
		my $link = qq(<a href='/sandbox/ital/search.cgi?query=$sanitized AND keywords:"$encoded"'>$facet</a>);
		push @facet_keywords, $link . ' (' . $$keyword_facets{ $facet } . ')';
		
	}

	# build a list of author facets
	my @facet_authors = ();
	my $author_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_authors } );
	foreach my $facet ( sort { $$author_facets{ $b } <=> $$author_facets{ $a } } keys %$author_facets ) {
	
		my $encoded = uri_encode( $facet );
		my $link = qq(<a href='/sandbox/ital/search.cgi?query=$sanitized AND authors:"$encoded"'>$facet</a>);
		push @facet_authors, $link . ' (' . $$author_facets{ $facet } . ')';
		
	}

	# build a list of entity facets
	my @facet_entities = ();
	my $entity_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_entities } );
	foreach my $facet ( sort { $$entity_facets{ $b } <=> $$entity_facets{ $a } } keys %$entity_facets ) {
	
		my $encoded = uri_encode( $facet );
		my $link = qq(<a href='/sandbox/ital/search.cgi?query=$sanitized AND entities:"$encoded"'>$facet</a>);
		push @facet_entities, $link . ' (' . $$entity_facets{ $facet } . ')';
		
	}

	# get the total number of hits
	my $total = $response->content->{ 'response' }->{ 'numFound' };

	# get number of hits
	my @hits = $response->docs;

	# loop through each document
	for my $doc ( $response->docs ) {
	
		# re-initialize
		my $root = ROOT;
		my $txt  = TXT;
		my $pdf  = PDF;

		# parse
		my $bid       = $doc->value_for( 'bid' );
		my $title     = $doc->value_for( 'title' );
		my $date      = $doc->value_for( 'date' );
		my $source    = $doc->value_for( 'source' );
		my $publisher = $doc->value_for( 'publisher' );
		my $abstract   = $doc->value_for(  'abstract' );
		my $doi        = $doc->value_for(  'doi' );
		my $words      = $doc->value_for(  'words' );
		my $sentences  = $doc->value_for(  'sentences' );
		my $flesch     = $doc->value_for(  'flesch' );
		my $url        = $doc->value_for(  'url' );
		my $identifier = $doc->value_for(  'identifier' );

		# create file names
		my $file = substr( $identifier, rindex( $identifier, '/' ) + 1, length( $identifier ) );
		$txt    = "$root/$txt/$file.txt";
		$pdf    = "$root/$pdf/$file.pdf";

		my @keywords = ();
		foreach my $keyword ( $doc->values_for( 'keywords' ) ) {
		
			my $keyword = qq(<a href='/sandbox/ital/search.cgi?query=keywords:"$keyword"'>$keyword</a>);
			push( @keywords, $keyword );

		}
		@keywords = sort( @keywords );
		
		my @authors = ();
		foreach my $author ( $doc->values_for( 'authors' ) ) {
		
			my $author = qq(<a href='/sandbox/ital/search.cgi?query=authors:"$author"'>$author</a>);
			push( @authors, $author );

		}
		@keywords = sort( @keywords );
		
		# create a item
		my $item = &item( $bid, $title, $date, $source, $publisher, $abstract, $doi, $words, $sentences, $flesch, $url, $identifier, scalar( @keywords ), scalar( @authors ) );
		$item =~ s/##BID##/$bid/ge;
		$item =~ s/##TITLE##/$title/g;
		$item =~ s/##DATE##/$date/g;
		$item =~ s/##SOURCE##/$source/g;
		$item =~ s/##PUBLISHER##/$publisher/g;
		$item =~ s/##ABSTRACT##/$abstract/g;
		$item =~ s/##DOI##/$doi/g;
		$item =~ s/##WORDS##/$words/g;
		$item =~ s/##SENTENCES##/$sentences/g;
		$item =~ s/##FLESCH##/$flesch/g;
		$item =~ s/##URL##/$url/g;
		$item =~ s/##PDF##/$pdf/g;
		$item =~ s/##TXT##/$txt/g;
		$item =~ s/##IDENTIFIER##/$identifier/g;
		$item =~ s/##KEYWORDS##/join( '; ', @keywords )/eg;
		$item =~ s/##AUTHORS##/join( '; ', @authors )/eg;

		# update the list of items
		$items .= $item;
					
	}	

	# build the html
	$html =  &results_template;
	$html =~ s/##RESULTS##/&results/e;
	$html =~ s/##QUERY##/$sanitized/e;
	$html =~ s/##TOTAL##/$total/e;
	$html =~ s/##HITS##/scalar( @hits )/e;
	$html =~ s/##ITEMS##/$items/e;
	$html =~ s/##FACETSKEYWORDS##/join( '; ', @facet_keywords )/e;
	$html =~ s/##FACETSAUTHORS##/join( '; ', @facet_authors )/e;
	$html =~ s/##FACETSENTITIES##/join( '; ', @facet_entities )/e;

}

# done
print $cgi->header( -type => 'text/html', -charset => 'utf-8');
print $html;
exit;


# specific item template
sub item {

	my $bid        = shift;
	my $title      = shift;
	my $date       = shift;
	my $source     = shift;
	my $publisher  = shift;
	my $abstract   = shift;
	my $doi        = shift;
	my $words      = shift;
	my $sentences  = shift;
	my $flesch     = shift;
	my $url        = shift;
	my $identifier = shift;
	my $keywords   = shift;
	my $authors    = shift;
	my $item      = "<li class='item'><a href='##URL##'>##TITLE##</a><ul>";
	if ( $authors ) { $item .= "<li style='list-style-type:circle'><strong>authors</strong>: ##AUTHORS##</li>" }
	$item .= "<li style='list-style-type:circle'><strong>date</strong>: ##DATE##</li>";
	$item .= "<li style='list-style-type:circle'><strong>source</strong>: ##SOURCE##</li>";
	$item .= "<li style='list-style-type:circle'><strong>abstract</strong>: ##ABSTRACT##</li>";
	if ( $keywords ) { $item .= "<li style='list-style-type:circle'><strong>keyword(s)</strong>: ##KEYWORDS##</li>" }
	$item .= "<li style='list-style-type:circle'><strong><strong>identifiers</strong>: </strong>:##DOI## (DOI); ##IDENTIFIER## (OAI); ##BID## (local id)</li>";
	$item .= "<li style='list-style-type:circle'><strong>statistics</strong>: ##WORDS## (words); ##SENTENCES## (sentences); ##FLESCH## (readability)</li>";
	$item .= "<li style='list-style-type:circle'><strong>full texts</strong>: <a href='##URL##'>PDF (cononical)<a/>; <a href='##PDF##'>PDF (cached)</a>; <a href='##TXT##'>plain text</a></li>";
	$item .= "</ul></li>";
	
	return $item;

}


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


# search results template
sub results {

	return <<EOF
	<p>Your search found ##TOTAL## item(s) and ##HITS## item(s) are displayed.</p>
			
	<h3>Items</h3><ol>##ITEMS##</ol>
EOF

}


# root template
sub template {

	return <<EOF
<html>
<head>
	<title>Information Techology and Libraries Index - Home</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="stylesheet" href="/sandbox/ital/etc/style.css">
	<style>
		.item { margin-bottom: 1em }
	</style>
</head>
<body>
<div class="header">
	<h1>Information Techology and Libraries Index</h1>
</div>

<div class="col-3 col-m-3 menu">
  <ul>
		<li><a href="/sandbox/ital/search.cgi">Home</a></li>
 </ul>
</div>

<div class="col-9 col-m-9">

	<p>This is selected fulltext index to the content of a journal named Information Technology and Libraries. Enter a query.</p>
	<p>
	<form method='GET' action='/sandbox/ital/search.cgi'>
	Query: <input type='text' name='query' value='##QUERY##' size='50' autofocus="autofocus"/>
	<input type='submit' value='Search' />
	</form>

	##RESULTS##

	<div class="footer">
		<p style='text-align: right'>
		Eric Lease Morgan<br />
		March 15, 2020
		</p>
	</div>

</div>

</body>
</html>
EOF

}


# results template
sub results_template {

	return <<EOF
<html>
<head>
	<title>Information Techology and Libraries Index - Search results</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="stylesheet" href="/sandbox/ital/etc/style.css">
	<style>
		.item { margin-bottom: 1em }
	</style>
</head>
<body>
<div class="header">
	<h1>Information Techology and Libraries Index - Search results</h1>
</div>

<div class="col-3 col-m-3 menu">
  <ul>
		<li><a href="/sandbox/ital/search.cgi">Home</a></li>
		<li><a href="/sandbox/ital/bids2urls.cgi">Get URLs</a></li>
 </ul>
</div>

	<div class="col-6 col-m-6">
		<p>
		<form method='GET' action='/sandbox/ital/search.cgi'>
		Query: <input type='text' name='query' value='##QUERY##' size='50' autofocus="autofocus"/>
		<input type='submit' value='Search' />
		</form>

		##RESULTS##
		
	</div>
	
	<div class="col-3 col-m-3">
	<h3>Author facets</h3><p>##FACETSAUTHORS##</p>
	<h3>Keyword facets</h3><p>##FACETSKEYWORDS##</p>
	<h3>Entity facets</h3><p>##FACETSENTITIES##</p>
	</div>

</body>
</html>
EOF

}
