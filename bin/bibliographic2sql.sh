#!/usr/bin/env bash

# bibliographic2sql.sh - given a file, output an SQL statement

# configure
TEMPLATE="UPDATE bibliographics SET author='##AUTHOR##', title='##TITLE##', date='##DATE##', source='##SOURCE##', publisher='##PUBLISHER##', language='##LANGUAGE##', doi='##DOI##', url='##URL##', abstract='##ABSTRACT##' WHERE identifier IS '##IDENTIFIER##';"

# make sane
if [[ -z $1 ]]; then
	echo "Usage: $0 <file>" >&2
	exit
fi

# get input
FILE=$1

# initialize
IFS=$'\t'

# read the file
cat $FILE | while read IDENTIFIER AUTHOR TITLE DATE SOURCE PUBLISHER LANGUAGE DOI URL ABSTRACT; do

	# escape
	IDENTIFIER=$( echo $IDENTIFIER | sed 's=/=\\/=g' )

	AUTHOR=$( echo $AUTHOR | sed "s/'/''/g" )
	AUTHOR=$( echo $AUTHOR | sed 's=/=\\/=g' )

	TITLE=$( echo $TITLE | sed "s/'/''/g" )
	TITLE=$( echo $TITLE | sed 's=/=\\/=g' )

	DATE=$( echo $DATE | sed "s/'/''/g" )
	DATE=$( echo $DATE | sed 's=/=\\/=g' )

	SOURCE=$( echo $SOURCE | sed "s/'/''/g" )
	SOURCE=$( echo $SOURCE | sed 's=/=\\/=g' )

	PUBLISHER=$( echo $PUBLISHER | sed "s/'/''/g" )
	PUBLISHER=$( echo $PUBLISHER | sed 's=/=\\/=g' )

	LANGUAGE=$( echo $LANGUAGE | sed "s/'/''/g" )
	LANGUAGE=$( echo $LANGUAGE | sed 's=/=\\/=g' )

	DOI=$( echo $DOI | sed "s/'/''/g" )
	DOI=$( echo $DOI | sed 's=/=\\/=g' )

	URL=$( echo $URL | sed "s/'/''/g" )
	URL=$( echo $URL | sed 's=/=\\/=g' )

	ABSTRACT=$( echo $ABSTRACT | sed "s/'/''/g" )
	ABSTRACT=$( echo $ABSTRACT | sed 's=/=\\/=g' )

	# do the substitutions
	SQL=$( echo $TEMPLATE | sed "s/##IDENTIFIER##/$IDENTIFIER/" )
	SQL=$( echo $SQL      | sed "s/##AUTHOR##/$AUTHOR/" )
	SQL=$( echo $SQL      | sed "s/##TITLE##/$TITLE/" )
	SQL=$( echo $SQL      | sed "s/##DATE##/$DATE/" )
	SQL=$( echo $SQL      | sed "s/##SOURCE##/$SOURCE/" )
	SQL=$( echo $SQL      | sed "s/##PUBLISHER##/$PUBLISHER/" )
	SQL=$( echo $SQL      | sed "s/##LANGUAGE##/$LANGUAGE/" )
	SQL=$( echo $SQL      | sed "s/##DOI##/$DOI/" )
	SQL=$( echo $SQL      | sed "s/##URL##/$URL/" )
	SQL=$( echo $SQL      | sed "s/##ABSTRACT##/$ABSTRACT/" )

	# output
	echo $SQL

# fini
done
exit


