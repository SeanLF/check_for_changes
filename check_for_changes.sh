#!/bin/sh
# Edited from https://github.com/ioexception-de/website-changes-notifications/blob/master/simple-webpage/check-for-changes.sh

# This script keeps track of changes to a web page protected with basic
# authentication. It will save a copy of the web page for historic purposes
# and fetch a new version and compare the two. If the contents of the two files
# are not identical, we will send a pushbullet notification.

# Usage:
# ./check-for-changes.sh url log_file_name username password pushbullet_access_token directory

# Params
# directory -> /Users/Example/CheckForChanges
# log_file_name -> Example
# url -> http://www.example.com
# username -> example_username
# password -> example_password
# pushbullet_access_token -> xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx (32 char access token)

# If this script won't execute, run chmod +x ./check-for-changes.sh

# ---------------------------------------------------------------------------

# Use good variable names
directory=$1
log_file_name=$2
url=$3
username=$4
password=$5
pushbullet_access_token=$6
log="$directory/$log_file_name".log

if [ "$(uname)" = "Darwin" ];
then
  # only tested on Darwin, should work on other *BSDs too
  md5path=`which md5`
  tmpfilename=`$md5path -q -s ${url}`
fi

# Where to store the HTML files
localcopy="$directory/$tmpfilename".html
onlinecopy="$directory/$tmpfilename"_new.html

# Add date to log
date=`date`
echo "Started @ $date" >> $log

# Fetch online copy
curl -L ${url} --user ${username}:${password} > $onlinecopy
echo "Fetched online copy." >> $log

# temporary local copy already exists?
if [ ! -f $localcopy ]
then
  echo "Initializing (1st time run) $localcopy" >> $log
  cp $onlinecopy $localcopy
  git add "$directory/."
  git commit -m "Initial commit for ${log_file_name}"
fi

# are the files different?
if ! cmp -s $onlinecopy $localcopy;
then
  # Write to log that changes found
  echo "Changes found!" >> $log

  # Pushbullet link push notification
  curl --header "Authorization: Bearer ${pushbullet_access_token}" -X POST https://api.pushbullet.com/v2/pushes --header 'Content-Type: application/json' --data-binary "{\"type\": \"link\", \"title\": \"Changes to ${log_file_name}\", \"body\": \"${log_file_name} website has changed\", \"url\": \"${url}\"}"

  rm $localcopy
  mv $onlinecopy $localcopy
  git add /Users/Sean/Dropbox/University/3rdYear/2ndSemester/_check-for-changes/.
  git commit -m "Changes for ${log_file_name}"
else
  echo "No changes" >> $log
fi
