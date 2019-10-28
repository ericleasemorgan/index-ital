#!/usr/bin/env bash

# db-create.sh

# configure
SCHEMA='./etc/schema.sql'
DATABASE='./etc/ital.db'

# make sane, do the work, and done
rm -rf $DATABASE
cat $SCHEMA | sqlite3 $DATABASE
exit
