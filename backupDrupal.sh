#!/bin/bash
#
# fullsitebackup.sh V1.0
#
# Full backup of website files and database content.
#
# A number of variables defining file location and database connection
# information must be set before this script will run.
# Files are tar'ed from the root directory of the website. All files are
# saved. The MySQL database tables are dumped without a database name and
# and with the option to drop and recreate the tables.
#
# Parameters:
#    tar_file_name (optional)
#
# Configuration
#

. parameters.sh

# Website Files
  webrootdir=$WEB_ROOT$SITE_DIRECTORY  # (e.g.: webrootdir=/home/user/public_html)


#
# Variables
#


# Default TAR Output File Base Name
  tarnamebase=sitebackup-
  datestamp=`date +'%Y-%m-%d'`


# Execution directory (script start point)
  startdir=`pwd`


# Temporary Directory
  tempdir=tmpbckdir$datestamp


#
# Input Parameter Check
#


if test "$1" = ""
  then
    tarname=$tarnamebase$datestamp.tgz
  else
    tarname=$1
fi


#
# Banner
#
echo ""
echo "fullsitebackup.sh V1.0"


#
# Create temporary working directory
#
echo " .. Setup"
mkdir $tempdir
echo "    done"


#
# TAR website files
#
echo " .. TARing website files in $webrootdir"
cd $webrootdir
tar cf $startdir/$tempdir/filecontent.tar .
echo "    done"


#
# sqldump database information
#
echo " .. sqldump'ing database:"
echo "    user: $dbuser; database: $dbname; host: $dbhost"
cd $startdir/$tempdir
mysqldump -p$dbpassword --user=$dbuser --host=$dbhost --add-drop-table $dbname > dbcontent.sql
echo "    done"


#
# Create final backup file
#
echo " .. Creating final compressed (tgz) TAR file: $tarname"
tar czf $startdir/$tarname filecontent.tar dbcontent.sql
echo "    done"


#
# Cleanup
#
echo " .. Clean-up"
cd $startdir
rm -r $tempdir
echo "    done"


#
# Exit banner
#
echo " .. Full site backup complete"
echo ""

