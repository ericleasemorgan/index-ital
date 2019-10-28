#!/usr/bin/env bash

TMP='./tmp/pdf'

# sanity check
if [[ -z $1 || -z $2 ]]; then

	echo "Usage: $0 <identifier> <url>" >&2
	exit
fi

# get input
IDENTIFIER=$1
URL=$2

# compute output, do the work (conditional), and done
OUTPUT="$TMP/$( echo $IDENTIFIER | cut -d '/' -f2 ).pdf"
#if [[ ! -e $OUTPUT ]]; then wget -O $OUTPUT $URL fi
wget -O $OUTPUT $URL
exit