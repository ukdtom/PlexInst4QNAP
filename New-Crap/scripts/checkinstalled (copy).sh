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
	return $MYVER
}

######################################################################
#	Main code
######################################################################

	# Check for version already installed
	




