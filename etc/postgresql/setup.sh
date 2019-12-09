#!/usr/bin/with-contenv sh

source /etc/postgresql/common.sh

#PGDATA=$DB_PATH
#export PGDATA

# set defaults for DB_USER and DB_PASSWORD
if [ -z "$DB_USER" ]; then
  DB_USER=$DB_NAME
fi
if [ -z "$DB_PASSWORD" ]; then
  DB_PASSWORD=$DB_USER
fi

# wait for postgres service to be ready
rc=1
retries=120
while [ $rc -ne 0 -a $retries -gt 0 ]; do
  sleep 1
  s6-svwait $POSTGRES_SERVICE 2>/dev/null
  rc=$?
  retries=$(expr $retries - 1)
done

if [ $rc -ne 0 ]; then
  echo "$WHOAMI database not ready" >&2
  exit 1
fi

# do substitutions for DB_NAME, DB_USER, and DB_PASSWORD in setup.sql
sqlfile=$(mktemp -t psqlXXXXXX)
sed -E -e "s/@DB_NAME@/$DB_NAME/g; s/@DB_USER@/$DB_USER/g; s/@DB_PASSWORD@/$DB_PASSWORD/g" < $DB_SETUP_SQL >$sqlfile

# run setup.sql
rc=2
retries=30
echo "$WHOAMI running $DB_SETUP_SQL"
while [ $rc -eq 2 -a $retries -gt 0 ]; do
  psql -U postgres -f "$sqlfile" 
  rc=$?
  retries=$(expr $retries - 1)
  if [ $rc -eq 2 -a $retries -gt 0 ]; then
    sleep 2
    echo "$WHOAMI retrying $DB_SETUP_SQL"
  fi 
done

if [ $rc -eq 0 ]; then
  echo "$WHOAMI successfully completed $DB_SETUP_SQL"
else
  echo "$WHOAMI failed to complete $DB_SETUP_SQL"
fi

rm $sqlfile
