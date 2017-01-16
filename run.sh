echo '* If permission issues you can use the run_old file.'

chown -R postgres:postgres /var/run/postgresql

/docker-entrypoint.sh postgres -c config_file=$CONFIG_FILE -c hba_file=$HBA_FILE -c ident_file=$IDENT_FILE
