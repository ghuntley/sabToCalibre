#!/bin/bash
DOWNLOAD_DIRECTORY="/home/sabnzbd/downloads"
CALIBRE_PATH=/usr/local/calibre
EXPECTED_ARGS=7

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {arg}"
  cat <<'END_HEREDOC'
 
    1     The final directory of the job (full path)
    2     The original name of the NZB file
    3     Clean version of the job name (no path info and ".nzb" removed)
    4     Indexer's report number (if supported)
    5     User-defined category
    6     Group that the NZB was posted in e.g. alt.binaries.x
    7     Status of post processing. 0 = OK, 1=failed verification, 2=failed unpack, 3=1+21

END_HEREDOC
  exit 1
fi

# Test to ensure the directory which was passed on the command line from SABz exists 
if [ ! -d "$1" ]
then
 echo "`basename $0`: Directory does not exist ($1)"
 exit 1 
fi

if [[ $1 != *$DOWNLOAD_DIRECTORY* ]]
then
 echo "`basename $0`: Unsafe directory specified ($1)"
 exit 1
fi


# Only process successfully completed downloads, delete the rest.
if [ $7 -eq 0 ]
then
 echo "`basename $0`: Adding $3 to Calibre...."
 $CALIBRE_PATH/calibredb add --one-book-per-directory --recurse  "$1"
 RC=$?
 if [ $RC  -eq 0 ] 
 then
   echo "`basename $0`: Sucess! Removing original...."
   rm  -rf "$1"
   exit 0
 fi
 else
   echo "`basename $0`: Failed to add $3 to Calibre library (RC=$RC)...."
   exit 1
 fi
fi
else 
 echo "`basename $0`: Incomplete download detected (RC=$7 || 0 = OK, 1=failed verification, 2=failed unpack, 3=1+21) removing..."
 rm  -rf "$1"
 exit 1
fi
