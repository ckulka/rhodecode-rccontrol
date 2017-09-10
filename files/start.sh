#!/bin/bash

RC_APPHOME="$HOME/.rccontrol/${RC_APP,,}-1"

# Set VCS Server specific variables
if [ "x$RC_APP" == "xVCSServer" ]
then
	RC_INI="$RC_APPHOME/vcsserver.ini"

# Set RhodeCode CE/EE specific variables
elif [ "x$RC_APP" == "xCommunity" ] || [ "x$RC_APP" == "xEnterprise" ]
then
	RC_INI="$RC_APPHOME/rhodecode.ini"

# Unknown app, therefore abort
else
	>&2 echo "Please set the RC_APP to either VCSServer, Enterprise or Community"
	exit 1
fi

# Update the configuration
if [ "x$RC_CONFIG" != "x" ]
then
	echo "$RC_CONFIG" | crudini --merge $RC_INI
else
	crudini --merge $RC_INI < $HOME/rhodecode.override.ini
fi
if [ "x$RC_DB" != "x" ]
then
	crudini --set $RC_INI app:main sqlalchemy.db1.url "$RC_DB"
fi

# Launch the application
$RC_APPHOME/profile/bin/gunicorn					\
	--paster=$RC_INI	\
	--config=$RC_APPHOME/gunicorn_conf.py	\
	--error-logfile=-
