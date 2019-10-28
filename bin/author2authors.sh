#!/usr/bin/env bash

# author2authors.sh 

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License


# sanity check
if [[ -z "$1" || -z $2 ]]; then
	echo "Usage: $0 <bid> <author>" >&2
	exit
fi

# get input
BID=$1
AUTHOR=$2

# delimit input; dumb
AUTHOR="$AUTHOR;"

# split the author statement 
echo $AUTHOR | while read -d ';' -a AUTHORS; do

	# process each item
	echo ${AUTHORS[@]} | while read VALUE; do
		
		# escape and output
		VALUE=$( echo $VALUE | sed "s/'/''/g" )
		echo "INSERT INTO authors ( 'bid', 'author' ) VALUES ( '$BID', '$VALUE' );"
		
	done

# fini
done
exit