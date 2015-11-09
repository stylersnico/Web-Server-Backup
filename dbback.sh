#!/bin/bash

#Variables
USER="root"
PASSWORD="yourrootpasswordofmysqlormariadb"
OUTPUT="/backup/DBs"

#Go to working dir
cd /backup/DBs/

#Extract all databases
databases=`mysql -u $USER -p$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

#Backup all databases
for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db"
        mysqldump -u $USER -p$PASSWORD --databases $db > `date +%Y%m%d`.$db.sql
    fi
done
