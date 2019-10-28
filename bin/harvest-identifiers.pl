#!/usr/bin/env perl

# harvest-identifiers.pl - given a base URL pointing to an (OJS) OAI repository, output rudimentary bibliogrpahic information


# configure
use constant BASEURL => 'https://ejournals.bc.edu/index.php/ital/oai';

# require
use Net::OAI::Harvester;
use strict;

# initialize
my $harvester = Net::OAI::Harvester->new( 'baseURL' => BASEURL );
binmode( STDOUT, ':utf8' );
binmode( STDERR, ':utf8' );

# get all identifiers and then process each one
my $identifiers = $harvester->listIdentifiers( 'metadataPrefix' => 'oai_dc' );
while ( my $identifier = $identifiers->next() ) {

    # parse, debug, and output
    my $identifier = $identifier->identifier();
   	warn "$identifier\n";
   	print "$identifier\n";
   		
}

# done
exit;


