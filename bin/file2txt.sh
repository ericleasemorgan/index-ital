#!/usr/bin/env bash

# file2txt.sh - given a file, output plain text; a front-end to file2txt.py

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# February 2, 2019 - first documentation; written a while ago; "Happy birthday, Mary!"


# configure
FILE2TXT='./bin/file2txt.py'
TMP='./tmp/txt'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <file>" >&2
	exit
fi

# get input
FILE=$1

# initialize
BASENAME=$( basename "$FILE" )
BASENAME="${BASENAME%.*}"
OUTPUT="$TMP/$BASENAME.txt"

echo "  FILE: $FILE" >&2
echo "OUTPUT: $OUTPUT" >&2

# conditionally, do the work and done
if [[ ! -e $OUTPUT ]]; then $FILE2TXT "$FILE" > "$OUTPUT"; fi
exit
