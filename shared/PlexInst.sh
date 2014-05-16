#!/bin/sh
CONF=/etc/config/qpkg.conf			# conf file for all qpkg's
QPKG_NAME="PlexInst"				# name of this file
TARGETAPP='Plex Media Server'			# name of the target application
QPKG_NAME_STRING='PlexMediaServer'		# search string in CONF file
DOWNLOADLINK='https://plex.tv/downloads'	# Download link @ vendor site


######################################################################
# This will set the variable named MyVer with the version of an 
# already installed version of Plex
#
# TODO: Replace hardcoded searchstring with $QPKG_NAME_STRING
######################################################################
get_installed_version(){
	MYVER=$(sed -n '1,/PlexMediaServer/d;/\[/,$d;/^$/d;p' $CONF|grep 'Version')
	# Strip the first 10 caracters
	MYVER=${MYVER:10}
#	MYVER='1.2'		# Use when testing
	/sbin/log_tool -t 0 -a "Currently installed version of $TARGETAPP is $MYVER";		
}

######################################################################
# Download and install a new app
######################################################################
download_and_install(){
	/sbin/log_tool -t 0 -a "Installing $TARGETAPP";
	fetch_and_install
}

######################################################################
# Download and upgrade an app
######################################################################
upgrade(){
	/sbin/log_tool -t 0 -a "Upgrading $TARGETAPP";
	fetch_and_install
}

######################################################################
# Get Vendor Version and download link
# TODO: This part is hardcoded to Plex
######################################################################
getVendorVerAndLink(){
	# Get the download page from Plex, and ignore the certificate
	/sbin/curl -sk $DOWNLOADLINK -o $DIR/downloads
	# Filter out all lines, that contains the word .qpkg, and save in the file named match
	grep ".qpkg" $DIR/downloads > $DIR/match
	# Remove <a href=" from start of all lines
	sed 's/<a href="//' $DIR/match > $DIR/downloads
	# Remove remaining part of the line for Intel builds
	sed 's/" class="btn btn-left track-download">Intel<\/a>//' $DIR/downloads > $DIR/match
	# Remove remaining part of the line for Arm builds
	sed 's/" class="btn btn-right track-download">ARM<\/a>//' $DIR/match > $DIR/downloads
	# Find the relevant URL based on processor type
	if [ $HOSTTYPE == 'i686' ]; then
		myUrl=$(sed -n '1p' < $DIR/downloads)	# This is for Intel
	else
		myUrl=$(sed -n '2p' < $DIR/downloads)	# This is for other platforms, like Arm 
	fi
	# Remove files, since we dont need them anymore
	rm -f -r $DIR/match
	rm -f -r $DIR/downloads
}

######################################################################
# The actual download-install
######################################################################
fetch_and_install(){
	/sbin/log_tool -t 0 -a "About to download the file $myUrl"
	# Remove the download file since it's no longer needed
	rm -f -r $DIR/downloads
	# Download the darn thingy
	/sbin/curl -sk $myUrl -o $DIR/MY.qpkg
	# Change rights, so we can execute it
	chmod 755 $DIR/MY.qpkg
	# Install the latest and greatest version of Plex
	$DIR/MY.qpkg 
	# Remove the Plex file since it's no longer needed
	rm -f -r $DIR/MY.qpkg
	# Lets inform our Master, but as a warning, so it pop's up in the admin interface
	/sbin/log_tool -t 1 -a "All done....$TARGETAPP is now installed" 
}

######################################################################
# Main code
######################################################################

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
	/sbin/log_tool -t 0 -a "Starting $QPKG_NAME from $DIR"
	# Check for version already installed
	get_installed_version
	# Get download link from vendor
	getVendorVerAndLink
	if [[ -z $MYVER ]]
	then
		echo "$TARGETAPP is not installed....need to download and install";
		download_and_install;
	else
		# Already installed, so check if we should upgrade

		if [[ $myUrl != *$MYVER* ]]
		then
			/sbin/log_tool -t 0 -a "We need to upgrade $TARGETAPP";
	echo "Upgrade"
			upgrade;
		else
			/sbin/log_tool -t 0 -a "Already newest version";
	echo "Already got it"		
		fi
	fi
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

