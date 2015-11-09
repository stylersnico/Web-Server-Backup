#!/bin/bash

#Go to working dir
cd /backup/WWW/

#Create a backup of all the /var/www/ dir
tar -czf `date +%Y%m%d`.www.tar.gz /var/www/
