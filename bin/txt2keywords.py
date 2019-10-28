#!/usr/bin/env python

# txt2keywords.sh - given a file, output a tab-delimited list of keywords

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 26, 2018 - first cut
# June 24, 2018 - lemmatized output


# configure
TEMPLATE = "INSERT INTO keywords ( 'bid', 'keyword' ) VALUES ( '##BID##', '##KEYWORD##' );"
RATIO = 0.01

# require
from gensim.summarization import keywords
import sys
import re

# sanity check
if len( sys.argv ) != 3 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <bid> <file>\n" )
	quit()

# initialize
bid  = sys.argv[ 1 ]
file = sys.argv[ 2 ]

# open the given file and unwrap it
text = open( file, 'r' ).read()
text = re.sub( '\r', '\n', text )
text = re.sub( '\n+', ' ', text )
text = re.sub( '^\W+', '', text )
text = re.sub( '\t', ' ',  text )
text = re.sub( ' +', ' ',  text )

# process each keyword; can't get much simpler
for keyword in keywords( text, ratio=RATIO, split=True, lemmatize=True ) : 
	sql = re.sub( '##BID##', bid, TEMPLATE )
	sql = re.sub( '##KEYWORD##', keyword, sql )
	print( sql )
	
# done
quit()
