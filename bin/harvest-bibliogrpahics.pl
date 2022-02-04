#!/usr/bin/env perl

# harvest.pl - given a base URL pointing to an (OJS) OAI repository, output rudimentary bibliogrpahic information


# configure
use constant BASEURL => 'https://ejournals.bc.edu/index.php/ital/oai';
use constant IDENTIFIER => 'oai:ejournals.bc.edu:article/8652';

# require
use Net::OAI::Harvester;
use strict;

# get input
my $baseurl    = $ARGV[ 0 ];
my $identifier = $ARGV[ 1 ];

# sanity check
if ( ! $baseurl || ! $identifier ) {

	die "Usage: $0 <base url> <identifier>\n";
	exit;

}

# initialize
my $harvester = Net::OAI::Harvester->new( 'baseURL' => $baseurl );
binmode( STDOUT, ':utf8' );
binmode( STDERR, ':utf8' );

# get all records and then process each one
my $record = $harvester->getRecord( 'identifier' => $identifier, 'metadataPrefix' => 'oai_dc' );

# parse
my $header = $record->header();
my $metadata = $record->metadata();

# parse some more
my $identifier = $header->identifier();
my $author     = join( '; ', $metadata->creator() );
my $title      = $metadata->title();
my $date       = $metadata->date();
my $source     = ( $metadata->source() )[ 0 ];
my $publisher  = $metadata->publisher();
my $language   = $metadata->language();
my $doi        = ( $metadata->identifier() )[ 1 ];
my $url        = $metadata->relation();
my $abstract   = $metadata->description();

# tidy
$abstract =~ s/&nbsp;/ /g;
$abstract =~ s/\r/ /g;
$abstract =~ s/\n/ /g;
$abstract =~ s/ +/ /g;
$title =~ s/ +/ /g;
$url   =~ s/view/download/g;

# debug
warn "  identifier: $identifier\n";
warn "   author(s): $author\n";
warn "       title: $title\n";
warn "        date: $date\n";
warn "      source: $source\n";
warn "   publisher: $publisher\n";
warn "    language: $language\n";
warn "         doi: $doi\n";
warn "         URL: $url\n";
warn "    abstract: $abstract\n";
warn "\n";

# output and done
print "$identifier\t$author\t$title\t$date\t$source\t$publisher\t$language\t$doi\t$url\t$abstract\n";
exit;


