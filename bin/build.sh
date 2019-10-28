#!/usr/bin/env bash

# configure
TIKA='/Applications/tika-server.jar'
DATABASE='./etc/ital.db'

# initialize
#./bin/clean.sh 
./bin/db-create.sh
mkdir -p ./tmp/bibliographics
mkdir -p ./tmp/pdf
mkdir -p ./tmp/txt

# get identifiers
./bin/harvest-identifiers.pl > ./tmp/identifiers.txt

# insert them into the database
echo 'BEGIN TRANSACTION;' > ./tmp/identifiers.sql
cat ./tmp/identifiers.txt | parallel ./bin/identifier2sql.sh >> ./tmp/identifiers.sql
echo 'END TRANSACTION;' >> ./tmp/identifiers.sql
cat ./tmp/identifiers.sql | sqlite3 $DATABASE

# get the bibliographics
cat ./tmp/identifiers.txt | parallel ./bin/harvest-bibliogrpahics.sh "https://ejournals.bc.edu/index.php/ital/oai" {}
cat ./tmp/bibliographics/*.txt > ./tmp/bibliographics.tsv

# clean, normalize, enhance bibliographics here

# insert bibliographics into the database
echo 'BEGIN TRANSACTION;' > ./tmp/bibliogrpahics.sql
find ./tmp/bibliographics -name *.txt | parallel ./bin/bibliographic2sql.sh >> ./tmp/bibliogrpahics.sql
echo 'END TRANSACTION;' >> ./tmp/bibliogrpahics.sql
cat ./tmp/bibliogrpahics.sql | sqlite3 $DATABASE

# harvest pdf
printf ".mode tabs\nselect identifier, url from bibliographics;" | sqlite3 $DATABASE | parallel --colsep '\t' ./bin/harvest-pdf.sh $1 $2

# start tika server
java -jar $TIKA &
PID=$!
sleep 10

# extract plain text from pdf
find ./tmp/pdf -name "*.pdf" | parallel ./bin/file2txt.sh 

# kill server
kill $PID

# calculate statistics and insert them into the database
echo 'BEGIN TRANSACTION;' > ./tmp/statistics.sql
echo "select identifier from bibliographics;" | sqlite3 $DATABASE | parallel ./bin/txt2statistics.sh >> ./tmp/statistics.sql
echo 'END TRANSACTION;' >> ./tmp/statistics.sql
cat ./tmp/statistics.sql | sqlite3 $DATABASE

# calculate keywords and insert them into the database
echo 'DELETE FROM keywords;' > ./tmp/keywords.sql
echo 'BEGIN TRANSACTION;' >> ./tmp/keywords.sql
printf ".mode tabs\nselect bid, identifier from bibliographics;" | sqlite3 $DATABASE | parallel --colsep '\t' ./bin/txt2keywords.sh $1 $2 >> ./tmp/keywords.sql
echo 'END TRANSACTION;' >> ./tmp/keywords.sql
cat ./tmp/keywords.sql | sqlite3 $DATABASE

# calculate named entities and insert them into the database
echo 'DELETE FROM entities;' > ./tmp/entities.sql
echo 'BEGIN TRANSACTION;' >> ./tmp/entities.sql
printf ".mode tabs\nselect bid, identifier from bibliographics;" | sqlite3 $DATABASE | parallel --colsep '\t' ./bin/txt2entities.sh $1 $2 >> ./tmp/entities.sql
echo 'END TRANSACTION;' >> ./tmp/entities.sql
cat ./tmp/entities.sql | sqlite3 $DATABASE

# parse authors and insert them into the database
echo 'DELETE FROM authors;' > ./tmp/authors.sql
echo 'BEGIN TRANSACTION;' >> ./tmp/authors.sql
printf ".mode tabs\nselect bid, author from bibliographics;" | sqlite3 $DATABASE | parallel --colsep '\t' ./bin/author2authors.sh $1 $2 >> ./tmp/authors.sql
echo 'END TRANSACTION;' >> ./tmp/authors.sql
cat ./tmp/authors.sql | sqlite3 $DATABASE




