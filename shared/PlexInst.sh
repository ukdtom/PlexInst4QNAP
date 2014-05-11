#!/bin/sh
CONF=/etc/config/qpkg.conf
QPKG_NAME="PlexInst"

case "$1" in
  start)
    ENABLED=$(/sbin/getcfg $QPKG_NAME Enable -u -d FALSE -f $CONF)
    if [ "$ENABLED" != "TRUE" ]; then
        echo "$QPKG_NAME is disabled."
        exit 1
    fi
    : ADD START ACTIONS HERE
	
	# Get dir of this script
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	/sbin/log_tool -t 0 -a "Starting PlexInst from $DIR"
#	echo $DIR
 	/sbin/log_tool -t 0 -a "Finding the newest Plex Media Server link"
	# Get the download page from Plex, and ignore the certificate
	/sbin/curl -sk https://plex.tv/downloads -o $DIR/downloads
	# Filter out all lines, that contains the word .qpkg, and save in the file named match
	grep ".qpkg" $DIR/downloads > $DIR/match
	# Remove <a href=" from start of all lines
	sed 's/<a href="//' $DIR/match > $DIR/downloads
	# Remove remaining part of the line for Intel builds
	sed 's/" class="btn btn-left track-download">Intel<\/a>//' $DIR/downloads > $DIR/match
	# Remove remaining part of the line for Arm builds
	sed 's/" class="btn btn-right track-download">ARM<\/a>//' $DIR/match > $DIR/downloads
	# Remove match file, since we only need the download file
	rm -f -r $DIR/match
	# Find the relevant URL based on processor type
	if [ $HOSTTYPE == 'i686' ]; then
		myUrl=$(sed -n '1p' < $DIR/downloads)	# This is for Intel
	else
		myUrl=$(sed -n '2p' < $DIR/downloads)	# This is for other platforms, like Arm 	
	fi
	/sbin/log_tool -t 0 -a "About to download the file $myUrl"
	# Remove the download file since it's no longer needed
	rm -f -r $DIR/downloads
	# Download the darn thingy
	/sbin/curl -sk $myUrl -o $DIR/pms.qpkg
	# Change rights, so we can execute it
	chmod 755 $DIR/pms.qpkg
	# Install the latest and greatest version of Plex
	$DIR/pms.qpkg 
	# Remove the Plex file since it's no longer needed
	rm -f -r $DIR/pms.qpkg
	# Lets inform our Master, but as a warning, so it pop's up in the admin interface
	/sbin/log_tool -t 1 -a "All done....Plex Media Server is now installed" 
    ;;

  stop)
    : ADD STOP ACTIONS HERE
    ;;

  restart)
    $0 stop
    $0 start
    ;;

  *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
esac

exit 0
