# alpine-postgresql

A PostgreSQL 9.5 image based on Alpine 3.4

## Database Cluster Initialization

The PostgreSQL `initdb` executable is used to initialize the database cluster. The script `etc/cont-init.d/10-initdb` runs `initdb` if it appears that the database cluster has not been initialized. 

The location of the database cluster on the container's filesystem is specified by `DB_PATH` in `etc/postgresql/common.sh` which is formed from `DB_BASE` with the `DB_NAME` environment variable appended onto it.  If you want the database cluster to persist longer than the container, you should mount a volume from the host onto the path specified for `DB_BASE`. The default value for `DB_BASE` in the image is `/var/lib/postgresql`.

After initializing the database cluster, `10-initdb` runs `/etc/postgresql/setup.sh` in the background. This script waits for the database service to be started and runs a database setup SQL script as described in the next section.

The scripts `etc/cont-init.d/20-db-connections` and `etc/cont-init.d/21-hba-conf` modify the database cluster's configuration

### `etc/cont-init.d/20-db-connections`

This initialization script sets the `max_connections` database parameter to the value specified by the `DB_MAX_CONNECTIONS` environment variable, if specified.

If the `DB_MAX_PREPARED_TRANSACTIONS` environment variable is specified, the `max_prepared_transactions` database parameter is set to the corresponding value. In this case, any value specified for `DB_MAX_CONNECTIONS` is overridden by the value specified by `DB_MAX_PREPARED_TRANSACTIONS` and is used to set the `max_connections` database parameter.

###`etc/cont-init.d/21-hba-conf`

This initialization scripts configures the database cluster's host-based access control to allow connections to the database server.

The environment variable `DB_HBA_TRUST_NETS` specifies a space-delimited list of IP networks that should by allowed with the `trust` authentication mechanism. By default, the network `172.17.0.0/16` is added, which allows and trusts connections from the container's host. If you don't want this default behavior, set `DB_HBA_TRUST_NETS` to `none`.

The environment variable `DB_HBA_MD5_NETS` specifies a space-delimited list of IP networks that should be allowed with the `md5` authentication mechanism. By default no networks of this type are added by default.

### Additional Cluster Configuration

You can extend the image to add additional cluster setup scripts. Just add them to `etc/cont-init.d`, prepending a number to the name to control the order of execution. See the existing scripts to see how to check that the one-time setup of the cluster has not already been performed.

## Database Instance Setup

After the PostgreSQL cluster server process (`postgres`) is running, a database setup script in `/etc/postgresql/setup.sql` is executed on the database script. The default script creates a user (role) in the database server and makes it the owner of a newly created database.

You can set these environment variables to control the name of database instance, user (role), and password.

* `DB_NAME` -- database name (default is _demo_)
* `DB_USER` -- database user name (default is `$DB_NAME`)
* `DB_PASSWORD` -- database password (default is `$DB_USER`)

Alternatively, you can extend the image to replace the `/etc/postgresql/setup.sql` with your own setup script. You can use the following placeholders in your custom setup script.

* `@DB_NAME@` -- value of the `DB_NAME` environment variable (default is _demo_)
* `@DB_USER@` -- value of the `DB_USER` environment variable (default is `$DB_NAME`)
* `@DB_PASSWORD@` -- value of the `DB_PASSWORD` environment variable (default is `$DB_PASSWORD`)
* 

## Database Access

PostgreSQL listens on TCP port 5432. If you want access the database from the host, be sure to publish this port.
