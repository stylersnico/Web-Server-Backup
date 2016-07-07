#!/bin/bash

###############
###Variables###
###############

#backup of the WWW folder
WWWBACKUPDIR="/backup/WWW/"

#backup of the Let's Encrypt folder
LEBACKUPDIR="/backup/LE/"

#Databases (MariaDB / MySQL)
DBBACKUPDIR="/backup/DBs/"
DBUSER="root"
DBPASSWORD="rootpassword"

#External FTP storage
ROOTFOLDER="/backup/*"
FTPSERVER="server"
FTPUSER="user"
FTPPASS="pass"

#Archives password and folder
ARCHIVEPASSWORD="password1"
GPGPASSPHRASE="password2"
ARCHIVEFOLDER="/home/someuser/"

#Storing old archive name
days=30

### !!! Don't edit anything above this line !!! ###
datediff=`date -d "today - "$days" days" +%Y%m%d`.full.7z.gpg
datediffsha1=`date -d "today - "$days" days" +%Y%m%d`.full.7z.sha512
datediffsha2=`date -d "today - "$days" days" +%Y%m%d`.full.7z.gpg.sha512

###################
###Creating dirs###
###################

mkdir -p $WWWBACKUPDIR
mkdir -p $LEBACKUPDIR
mkdir -p $DBBACKUPDIR


##############################
###backup of the WWW folder###
##############################

#Go to working dir
cd $WWWBACKUPDIR

#Create a backup of all the /var/www/ dir
tar -czf `date +%Y%m%d`.www.tar.gz /var/www/

#############################
###backup of the LE folder###
#############################

#Go to working dir
cd $LEBACKUPDIR

#Create a backup of all the possible Let's Encrypt dir
if [ -d "/etc/letsencrypt/" ]; then
  tar -czf `date +%Y%m%d`.le.etc.tar.gz /etc/letsencrypt/
fi
if [ -d "/opt/letsencrypt/" ]; then
  tar -czf `date +%Y%m%d`.le.opt.tar.gz /opt/letsencrypt/
fi


#############################
###backup of the databases###
#############################

#Go to working dir
cd $DBBACKUPDIR

#Extract all databases
databases=`mysql -u $DBUSER -p$DBPASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

#Backup all databases
for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db"
        mysqldump -u $DBUSER -p$DBPASSWORD --databases $db > `date +%Y%m%d`.$db.sql
    fi
done


##############################
###Create protected archive###
##############################

#Creating 7zip-aes encrypted archive
mkdir -p /tmp/backupworkingdir/
cd /tmp/backupworkingdir/
7za a -y -tzip -p$ARCHIVEPASSWORD -mem=AES256 `date +%Y%m%d`.full.7z $ROOTFOLDER
sha512sum `date +%Y%m%d`.full.7z > `date +%Y%m%d`.full.7z.sha512

#Creating gpg-twofish encrypted file
gpg -c --passphrase $GPGPASSPHRASE --batch --no-tty --yes --cipher-algo twofish `date +%Y%m%d`.full.7z
sha512sum `date +%Y%m%d`.full.7z.gpg > `date +%Y%m%d`.full.7z.gpg.sha512

#move to archive folder for sending
mv `date +%Y%m%d`.full.7z.gpg $ARCHIVEFOLDER
mv `date +%Y%m%d`.full.7z.sha512 $ARCHIVEFOLDER
mv `date +%Y%m%d`.full.7z.gpg.sha512 $ARCHIVEFOLDER
rm -f `date +%Y%m%d`.full.*


##################################
###Send to external FTP storage###
##################################

cd $ARCHIVEFOLDER



#Sending archive and SHA512sums to FTP storage
curl -T $ARCHIVEFOLDER`date +%Y%m%d`.full.7z.gpg.sha512 ftp://$FTPSERVER --user $FTPUSER:$FTPPASS
curl -T $ARCHIVEFOLDER`date +%Y%m%d`.full.7z.sha512 ftp://$FTPSERVER --user $FTPUSER:$FTPPASS
curl -T $ARCHIVEFOLDER`date +%Y%m%d`.full.7z.gpg ftp://$FTPSERVER --user $FTPUSER:$FTPPASS

#Purge old files
curl --quote "-dele $datediff" ftp://$FTPSERVER --user $FTPUSER:$FTPPASS
curl --quote "-dele $datediffsha1" ftp://$FTPSERVER --user $FTPUSER:$FTPPASS
curl --quote "-dele $datediffsha2" ftp://$FTPSERVER --user $FTPUSER:$FTPPASS


#####################################
###Deleting all local backup files###
#####################################

rm -rf $WWWBACKUPDIR
rm -rf $LEBACKUPDIR
rm -rf $DBBACKUPDIR
