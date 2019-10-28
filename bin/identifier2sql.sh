#!/usr/bin/env bash

# identifiers2sql.sh

# configure
TEMPLATE="INSERT INTO bibliographics ( 'identifier' ) VALUES ( '##IDENTIFIER##' );"

# make sane
if [[ -z $1 ]]; then
	echo "Usage: $0 <identifier>" >&2
	exit
fi

# get input
IDENTIFIER=$1

# make sane, do the work, and done
IDENTIFIER=$( echo $IDENTIFIER | sed 's=/=\\/=g' )
SQL=$( echo $TEMPLATE | sed "s/##IDENTIFIER##/$IDENTIFIER/" )
echo $SQL
exit
