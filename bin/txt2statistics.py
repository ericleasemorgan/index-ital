#!/usr/bin/env python

# txt2keywords.py - given a file name, output metadata as a TSV file

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# July       6, 2019 - first working version
# July       7, 2019 - combined with txt2bib.py
# September  1, 2019 - added cache and txt fields
# September 11, 2019 - looked for previously created bibliographic data


TEMPLATE = "UPDATE bibliographics SET words='##WORDS##', sentences='##SENTENCES##', flesch='##FLESCH##' WHERE identifier='##IDENTIFIER##';"

# require
from textatistic import Textatistic
import sys
import re

# sanity check
if len( sys.argv ) != 3 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <identifier> <file>\n" )
	exit()

# get input
identifier = sys.argv[ 1 ]
file = sys.argv[ 2 ]

# open the given file and unwrap it
with open( file ) as handle : text = handle.read()
text = re.sub( '\r', '\n', text )
text = re.sub( '\n+', ' ', text )
text = re.sub( '^\W+', '', text )
text = re.sub( '\t', ' ',  text )
text = re.sub( ' +', ' ',  text )

# get all document statistics and summary
statistics = Textatistic( text )
words     = str( statistics.word_count )
sentences = str( statistics.sent_count )
flesch    = str( int( statistics.flesch_score ) )

# do the substitutions
sql = re.sub( '##WORDS##', words, TEMPLATE )
sql = re.sub( '##SENTENCES##', sentences, sql )
sql = re.sub( '##FLESCH##', flesch, sql )
sql = re.sub( '##IDENTIFIER##', identifier, sql )

# output and done
print( sql )
exit()

