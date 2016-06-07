WHOAMI="[$(basename $0)]"
S6_SERVICES=/var/run/s6/services
POSTGRES_SERVICE=$S6_SERVICES/postgres


# If you want to change this, you'll also need to make the corresponding
# change in etc/fix-attrs.d/10-postgresql-data
DB_BASE=/var/lib/postgresql

if [ ! -d "$DB_BASE" ]; then
  echo "$WHOAMI $DB_BASE: not a directory" >&2
  exit 1
fi

if [ -z "$DB_NAME" ]; then
  DB_NAME=demo
fi

DB_PATH="$DB_BASE/$DB_NAME"

if [ -z "$DB_LOG" ]; then
  DB_LOG=/var/log/postgresql
fi

DB_ONETIME_COMPLETE=$DB_PATH/.onetime
DB_SETUP_SH=/etc/postgresql/setup.sh
DB_SETUP_SQL=/etc/postgresql/setup.sql
