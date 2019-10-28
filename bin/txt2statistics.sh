#!/usr/bin/env bash

TMP='./tmp/txt'
TXT2STATISTICS='./bin/txt2statistics.py'

# sanity check
if [[ -z $1 ]]; then

	echo "Usage: $0 <identifier>" >&2
	exit
fi

# get input
IDENTIFIER=$1

# compute output, do the work (conditional), and done
FILE="$TMP/$( echo $IDENTIFIER | cut -d '/' -f2 ).txt"
$TXT2STATISTICS $IDENTIFIER $FILE

exit