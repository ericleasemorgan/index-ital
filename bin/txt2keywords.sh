#!/usr/bin/env bash

# txt2keywords.sh - given a file, execute txt2keywords.py
# usage: find carrels/word2vec/txt -name '*.txt' -exec ./bin/txt2keywords.sh {} \;

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 26, 2018 - first cut


# configure
TXT2KEYWORDS='./bin/txt2keywords.py'
TMP='./tmp/txt'

# sanity check
if [[ -z "$1" || -z $2 ]]; then
	echo "Usage: $0 <bid> <identifier>" >&2
	exit
fi

# get input
BID=$1
IDENTIFIER=$2

# compute output
FILE="$TMP/$( echo $IDENTIFIER | cut -d '/' -f2 ).txt"


$TXT2KEYWORDS $BID $FILE