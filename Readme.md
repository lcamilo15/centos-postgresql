```
   env_file: .env
```

List of environment variables used by containers:

- POSTGRES_DB : This optional environment variable can be used to define a different name for the default database that is created when the image is first started. If it is not specified, then the value of POSTGRES_USER will be used.
- POSTGRES_USER : This optional environment variable is used in conjunction with POSTGRES_PASSWORD to set a user and its password. This variable will create the specified user with superuser power and a database with the same name. If it is not specified, then the default user of postgres will be used.
- POSTGRES_PASSWORD : This environment variable is reallyecommended for you to use the PostgreSQL image. This environment variable sets the superuser password for PostgreSQL. The default superuser is defined by the POSTGRES_USER environment variable. In the above example, it is being set to "mysecretpassword".- POSTGRES_DB : Any other database that needs to be created
- POSTGRES_ROOT_PASSWORD : Optional variable used for assigning a default password to postgres user.
- POSTGRES_HOST : Lucee will use this to connect to postgres
- PGDATA : The default is /var/lib/postgresql/data, but if the data volume you're using is a fs mountpoint (like with GCE persistent disks), Postgres initdb recommends a subdirectory (for example /var/lib/postgresql/data/pgdata ) be created to contain the data.

