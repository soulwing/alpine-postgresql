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
retries=10
while [ $rc -ne 0 -a $retries -gt 0 ]; do
  sleep 1
  s6-svwait $POSTGRES_SERVICE 2>/dev/null
  rc=$?
  retries=$(expr $retries - 1)
done

# do substitutions for DB_NAME, DB_USER, and DB_PASSWORD in setup.sql
sqlfile=$(mktemp -t psqlXXXXXX)
sed -E -e "s/@DB_NAME@/$DB_NAME/g; s/@DB_USER@/$DB_USER/g; s/@DB_PASSWORD@/$DB_PASSWORD/g" < $DB_SETUP_SQL >$sqlfile

# run setup.sql
echo "$WHOAMI running $DB_SETUP_SQL"
psql -U postgres -f "$sqlfile"
echo "$WHOAMI finished $DB_SETUP_SQL"
rm $sqlfile
