#!/usr/bin/env bash

# initialize
./bin/clean.sh 
./bin/db-create.sh
mkdir -p ./tmp/bibliographics

# get identifiers
./bin/harvest-identifiers.pl > ./tmp/identifiers.txt

# insert them into the database
echo 'BEGIN TRANSACTION;' > ./tmp/identifiers.sql
cat ./tmp/identifiers.txt | parallel ./bin/identifier2sql.sh >> ./tmp/identifiers.sql
echo 'END TRANSACTION;' >> ./tmp/identifiers.sql
cat ./tmp/identifiers.sql | sqlite3 ./etc/ital.db

# get the bibliographics
cat ./tmp/identifiers.txt | parallel ./bin/harvest-bibliogrpahics.sh "https://ejournals.bc.edu/index.php/ital/oai" {}
cat ./tmp/bibliographics/*.txt > ./tmp/bibliographics.tsv

# clean, normalize, enhance bibliographics here

# insert bibliographics into the database
echo 'BEGIN TRANSACTION;' > ./tmp/bibliogrpahics.sql
find ./tmp/bibliographics -name *.txt | parallel ./bin/bibliographic2sql.sh >> ./tmp/bibliogrpahics.sql
echo 'END TRANSACTION;' >> ./tmp/bibliogrpahics.sql
cat ./tmp/bibliogrpahics.sql | sqlite3 ./etc/ital.db
