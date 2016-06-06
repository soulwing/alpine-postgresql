#!/usr/bin/with-contenv sh
WHOAMI="[$(basename $0)]"
S6_SERVICES=/var/run/s6/services
POSTGRES_SERVICE=$S6_SERVICES/postgres

if [ -z "$DB_NAME" ]; then
  echo "$WHOAMI: ERROR: DB_NAME environment variable is not set" >&2
  exit 1
fi
if [ -z "$DB_USER" ]; then
  DB_USER=$DB_NAME
fi
if [ -z "$DB_PASSWORD" ]; then
  DB_PASSWORD=$DB_USER
fi

PGDATA=/var/lib/postgresql/$DB_NAME
export PGDATA
rc=1
retries=10
while [ $rc -ne 0 -a $retries -gt 0 ]; do
  sleep 1
  s6-svwait $POSTGRES_SERVICE 2>/dev/null
  rc=$?
  retries=$(expr $retries - 1)
done

SQL=$(mktemp -t psqlXXXXXX)
cat >$SQL <<EOF
CREATE ROLE $DB_USER WITH LOGIN ENCRYPTED PASSWORD '$DB_PASSWORD';
CREATE DATABASE $DB_NAME WITH OWNER $DB_USER;
EOF
if psql -U postgres -f "$SQL"; then
  echo "$WHOAMI created role '$DB_USER' as owner of database '$DB_NAME'"
fi
rm $SQL
