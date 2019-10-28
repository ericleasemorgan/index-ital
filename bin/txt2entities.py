#!/usr/bin/env python

# txt2ent.py - given a plain text file, output a tab-delimited file of named entitites

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 1, 2018 - first cut, or there abouts


TEMPLATE = "INSERT INTO entities ( 'bid', 'entity', 'type' ) VALUES ( '##BID##', '##ENTITY##', '##TYPE##' );"


# require
from nltk import *
import os
import re
import spacy
import sys

# sanity check
if len( sys.argv ) != 3 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <bid> <file>\n" )
	quit()

# initialize
bid = sys.argv[ 1 ]
file = sys.argv[ 2 ]
nlp  = spacy.load( 'en_core_web_sm', disable=['tagger'] )

# limit ourselves to a few processors only
#os.system( "taskset -pc 0-1 %d > /dev/null" % os.getpid() )

# open the given file and unwrap it
text = open( file, 'r' ).read()
text = re.sub( '\r', '\n', text )
text = re.sub( '\n+', ' ', text )
text = re.sub( '^\W+', '', text )
text = re.sub( '\t', ' ',  text )
text = re.sub( ' +', ' ',  text )

# parse the text into sentences and process each one
for sentence in sent_tokenize( text ) :

	# (re-)initialize and increment
	sentence = nlp( sentence )
	
	# process each entity
	for entity in sentence.ents : 
		
		if ( entity.label_ == 'CARDINAL' ) : continue
		if ( entity.label_ == 'PRODUCT' ) : continue
		if ( entity.label_ == 'PERCENT' ) : continue
		if ( entity.label_ == 'ORDINAL' ) : continue
		
		value = re.sub( "\s+", " ", entity.text )
		value = re.sub( " +", " ", value )
		value = re.sub( "'", "''", value )
		
		sql = re.sub( '##BID##', bid, TEMPLATE )
		sql = re.sub( '##ENTITY##', value, sql )
		sql = re.sub( '##TYPE##', entity.label_, sql )
		print( sql )
		
# done
quit()
