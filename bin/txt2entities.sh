#!/usr/bin/env bash

# txt2entitiets.sh - given a file, execute txt2keywords.py


# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 26, 2018 - first cut


# configure
TXT2ENTITIES='./bin/txt2entities.py'
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
$TXT2ENTITIES $BID $FILE
