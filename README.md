Web Server Backup
=================

##License
Script for backuping your webserver to an external ftp share after making a 7zip-aes256 archive protected by gpg-twofish.
Copyleft (C) Nicolas Simond - 2016

This script is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This script is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this script.  If not, see <http://www.gnu.org/licenses/gpl.txt>

##New release - V2 - 07/07/2016

##About this script
This script backup your webserver by doing the followings things :

- tar.gz of /var/www
- tar.gz of /opt/letsencrypt and /etc/letsencrypt (if present)
- Export of every MariaDB / MySQL database on your server
- Making a 7zip aes256 encrypted archive of the above
- Making a SHA512sum of the 7zip archive
- Encrypting the 7zip archive a second time with gpg (Twofish)
- Making a SHA512sum of the gpg archive
- Exporting gpg archive and both SHA512sum to FTP

##Dependencies
<code>apt-get install p7zip-full curl gnupg</code>

##Designed for
Debian 8

##Installation
<code>cd /root && wget --no-check-certificate https://raw.githubusercontent.com/stylersnico/webserverbackup/master/backup.sh && chmod +x backup.sh && ./backup.sh</code>
