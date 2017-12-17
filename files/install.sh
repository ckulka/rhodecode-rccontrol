#!/bin/bash

if [ "x$RC_APP" == "x" ] || [ "x$RC_VERSION" == "x" ]
then
	>&2 echo "This script relies on the environment variables RC_APP, RC_VERSION"
	exit 1
fi

if [ "x$1" != "x" ]
then
	RC_DB=$1
elif [ "x$RC_DB" == "x" ]
then
	>&2 echo "Please specify RC_DB, either as environment variable or as the first parameter to this script"
	exit 1
fi

$HOME/.rccontrol-profile/bin/rccontrol	\
	install $RC_APP						\
	--version $RC_VERSION				\
	--accept-license					\
	'{"host": "0.0.0.0", "port": 5000, "username": "admin", "password": "ilovecookies", "email": "adalovelace@example.com", "repo_dir": "/data", "database": "'$RC_DB'"}'
