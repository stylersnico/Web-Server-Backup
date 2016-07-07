#!/bin/bash

# Usage : ./extract.sh <archive.7zip.pgp> <pgp_password> <7zip_password>

###############
###Variables###
###############

date="`echo "${1}" | cut -d'.' -f1`"
shapgptmp="${1}.sha512"
shapgp="`cat "${shapgptmp}"`"


##############
###GPG part###
##############

#Checking checksums

shapgplive="`sha512sum "${1}"`"

echo "Checking file: "${1}""
echo "Using SHA512 file: "${shapgp}""


if [ "${shapgp}" != "${shapgplive}" ]
then
  echo "SHA512 sums mismatch, archive corrupted"
  exit;
else
  echo "checksums OK, extracting GPG"
fi

#If checksums ok, extract
gpg --passphrase ${2} --batch --no-tty --yes ${1}


##############
###7ZA part###
##############

za="`echo ""${date}".full.7z"`"
zasha="`cat "${date}".full.7z.sha512`"

#Checking checksums
shazalive="`sha512sum "${za}"`"

echo "Checking file: "${zasha}""
echo "Using SHA512 file: "${shazalive}""


if [ "${zasha}" != "${shazalive}" ]
then
  echo "SHA512 sums mismatch, archive corrupted"
  exit;
else
  echo "checksums OK, extracting 7Zip"
fi

#If checksums ok, extract
7za x -p${3} ${za}

echo "\
\
\
Done"
