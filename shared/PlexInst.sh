#!/bin/sh
CONF=/etc/config/qpkg.conf			# conf file for all qpkg's
QPKG_NAME="PlexInst"				# name of this file
TARGETAPP='Plex Media Server'			# name of the target application
QPKG_NAME_STRING='PlexMediaServer'		# search string in CONF file
DOWNLOADLINK='https://plex.tv/downloads'	# Download link @ vendor site


######################################################################
# This will set the variable named MyVer with the version of an 
# already installed version of Plex
######################################################################
get_installed_version(){
	MYVER=$(/sbin/getcfg $QPKG_NAME_STRING Version -d FALSE -f $CONF)
	/sbin/log_tool -t 0 -a "Currently installed version of $TARGETAPP is $MYVER";
#	MYVER='FORCEDOWN'		# Use when testing
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
	# Get the download page from Plex, and ignore the certificate, and filter out lines with qpkg
	PAGE=$(/sbin/curl -sk $DOWNLOADLINK |grep '.qpkg')
	# Strip start part of line
	PAGE=$(sed 's/<a href="//g' <<< $PAGE)
	# Strip end part of Intel line
	PAGE=$(sed 's/" class="btn btn-left track-download">Intel<\/a>//' <<< $PAGE)
	# Strip end part of ARM line
	PAGE=$(sed 's/" class="btn btn-right track-download">ARM<\/a>//' <<< $PAGE)
	ARMURL=${PAGE#*.qpkg}
	INTELURL=${PAGE/$ARMURL/''}
	# Find the relevant URL based on processor type
	if [ $HOSTTYPE == 'i686' ]; then
		myUrl=$INTELURL
	else
		myUrl=$ARMURL
	fi
}

######################################################################
# The actual download-install
######################################################################
fetch_and_install(){
	/sbin/log_tool -t 0 -a "About to download the file $myUrl"
	# Download the darn thingy
	/sbin/curl -sk $myUrl -o $DIR/MY.qpkg
	# Change rights, so we can execute it
	chmod 755 $DIR/MY.qpkg
	# Install the latest and greatest version of the QPKG
	$DIR/MY.qpkg
	# Remove the QPKG file since it's no longer needed
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
	DIR=$(/sbin/getcfg $QPKG_NAME Install_Path -d FALSE -f $CONF)
	/sbin/log_tool -t 0 -a "Starting $QPKG_NAME from $DIR"
	# Check for version already installed
	get_installed_version
	# Get download link from vendor
	getVendorVerAndLink
	if [[ -z $MYVER ]]
	then
		download_and_install;
	else
		# Already installed, so check if we should upgrade
		if [[ $myUrl != *$MYVER* ]]
		then
			/sbin/log_tool -t 0 -a "We need to upgrade $TARGETAPP";
			upgrade;
		else
			/sbin/log_tool -t 0 -a "Already newest version";	
		fi
	fi
	@/sbin/setcfg PlexInst Enable FALSE -f /etc/config/qpkg.conf
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

