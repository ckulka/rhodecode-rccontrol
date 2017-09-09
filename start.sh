#!/bin/bash

# Initialises variables and RhodeCode Control. Exits the script if mandatory parameters are missing.
function rc_init {
	source ~/.profile

	case "$RC_APP" in
		VCSServer)
			RC_INSTANCEINI="vcsserver.ini"
			RC_INSTALL_OPTS='{"host": "0.0.0.0", "port": 9900}'
			;;
		Community)
			RC_INSTANCEINI="rhodecode.ini"
			RC_INSTALL_OPTS='{"host": "0.0.0.0", "port": 5000, "username": "'$RC_USER'", "password": "'$RC_PASSWORD'", "email": "'$RC_EMAIL'", "repo_dir": "/data", "database": "'$RC_DB'"}'
			;;
		Enterprise)
			RC_INSTANCEINI="rhodecode.ini"
			RC_INSTALL_OPTS='{"host": "0.0.0.0", "port": 5000, "username": "'$RC_USER'", "password": "'$RC_PASSWORD'", "email": "'$RC_EMAIL'", "repo_dir": "/data", "database": "'$RC_DB'"}'
			;;
		*)
			>&2 echo "Please set the RC_APP to either VCSServer, Enterprise or Community"
			exit 1
			;;
	esac
	if [ "x$RC_VERSION" == "x" ]
	then
		>&2 echo "Please set the RC_VERSION. For available releases, see https://docs.rhodecode.com/RhodeCode-Enterprise/release-notes/release-notes.html"
		exit 1;
	fi
	[ "x$RC_INSTANCEID" == "x" ] && RC_INSTANCEID="${RC_APP,,}-1"
}

# Provisions, i.e. installs or updates, the RhodeCode app in the specified version
function rc_provision {
	currentVersion=`rccontrol status $RC_INSTANCEID | sed -rn 's/^ - VERSION: (.+) '$RC_APP'$/\1/p'`
	if [ "x$currentVersion" == "x" ]
	then
		rccontrol install $RC_APP --version $RC_VERSION --accept-license $RC_INSTALL_OPTS
	elif [ "$currentVersion" != "$RC_VERSION" ]
	then
		rccontrol upgrade $RC_INSTANCEID --version $RC_VERSION
	fi
	rccontrol self-stop
	echo "$RC_CONFIG" | crudini --merge $HOME/.rccontrol/$RC_INSTANCEID/$RC_INSTANCEINI
}

# Initialise variables and RhodeCode Control
rc_init

# Provision the RhodeCode app
rc_provision

# Start the RhodeCode app
.rccontrol/$RC_INSTANCEID/profile/bin/gunicorn --error-logfile=- --paster=$HOME/.rccontrol/$RC_INSTANCEID/$RC_INSTANCEINI --config=$HOME/.rccontrol/$RC_INSTANCEID/gunicorn_conf.py
