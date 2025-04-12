#!/bin/bash
set -e

psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "CREATE EXTENSION \"uuid-ossp\""
psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "CREATE EXTENSION \"postgis\""

MIGRATIONS="/docker-entrypoint-initdb.d/migrations"
for file in $MIGRATIONS/*.up.sql; do
    [ -f "$file" ] || continue
    psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -f "${file}" > /dev/null
done

SEEDERS="/docker-entrypoint-initdb.d/seeders"
for file in $SEEDERS/*.up.sql; do
    [ -f "$file" ] || continue
    psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -f "${file}" > /dev/null
done