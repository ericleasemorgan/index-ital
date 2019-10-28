#!/usr/bin/env bash

SQL='./tmp/insert-identifiers.sql'
echo "BEGIN TRANSACTION" > $SQL
cat ./etc/identifiers.txt | parallel ./bin/identifiers2sql.sh >> $SQL
echo "END TRANSACTION" >> $SQL
cat $SQL | sqlite3 