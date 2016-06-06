# alpine-postgresql

A PostgreSQL 9.5 image based on Alpine 3.4

## Environment Variables

`DB_NAME` -- database name (default is _demo_)
`DB_USER` -- database user name (default is `$DB_NAME`)
`DB_PASSWORD` -- database password (default is `$DB_USER`)

## Database Storage
 
The path `/var/lib/postgresql` in the container is used for as backing store for the database. If you want the database to persist longer than the container, be sure to map a volume from the host into the container on this path.

## Database Access

PostgreSQL listens on TCP port 5432. If you want access the database from the host, be sure to publish this port.

The host-based access control configuration for the database is set to use _trust_ authentication for connections from the host and from within the container.


