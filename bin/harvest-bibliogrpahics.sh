#!/usr/bin/env bash

HARVESTBIBLIOGRAPHICS='./bin/harvest-bibliogrpahics.pl'
TMP='./tmp/bibliographics'

# sanity check
if [[ -z $1 || -z $2 ]]; then

	echo "Usage: $0 <base url> <identifier>" >&2
	exit
fi

# get input
BASEURL=$1
IDENTIFIER=$2

# compute output, do the work (conditional), and done
OUTPUT="$TMP/$( echo $IDENTIFIER | cut -d '/' -f2 ).tsv"
if [[ ! -e $OUTPUT ]]; then $HARVESTBIBLIOGRAPHICS "$BASEURL" "$IDENTIFIER" > $OUTPUT; fi
exit