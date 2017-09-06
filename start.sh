#!/bin/bash

# Initialises variables and RhodeCode Control. Exits the script if mandatory parameters are missing.
function rc_init {
    case "$RC_APP" in
        VCSServer)
            RC_INSTALL_OPTS='{"host": "0.0.0.0", "port": 8080}'
            ;;
        Community)
            RC_INSTALL_OPTS='{"host": "0.0.0.0", "port": 8080, "username": "'$RC_USER'", "password": "'$RC_PASSWORD'", "email": "'$RC_EMAIL'", "repo_dir": "/data", "database": "'$RC_DB'"}'
            ;;
        Enterprise)
            RC_INSTALL_OPTS='{"host": "0.0.0.0", "port": 8080, "username": "'$RC_USER'", "password": "'$RC_PASSWORD'", "email": "'$RC_EMAIL'", "repo_dir": "/data", "database": "'$RC_DB'"}'
            ;;
        *)
            >&2 echo "Please set the RC_APP to either VCSServer, Enterprise or Community"
            exit 1
            ;;
    esac

    if [[ "x$RC_VERSION" == "x" ]]
    then
        >&2 echo "Please set the RC_VERSION. For available releases, see https://docs.rhodecode.com/RhodeCode-Enterprise/release-notes/release-notes.html"
        exit 1;
    fi

    [[ "x$RC_INSTANCEID" == "x" ]] && RC_INSTANCEID="${RC_APP,,}-1"
    [[ "x$RC_COMMON_OPTS" == "x" ]] && RC_COMMON_OPTS="--install-dir $RC_DATA --config $RC_DATA/rccontrol.ini"

    # Initialise RhodeCode Control
    source ~/.profile
    rccontrol $RC_COMMON_OPTS self-init
    mkdir -p $RC_DATA/cache
    touch $RC_DATA/cache/MANIFEST
}

# Return codes:
#  - 0 instance-id updated to version
#  - 1 instance-id not installed
function rc_upgrade {
    currentVersion=`rccontrol status $RC_INSTANCEID | sed -rn 's/^ - VERSION: (.+) '$RC_APP'$/\1/p'`
    if [[ "x$currentVersion" -eq "x" ]]
    then
        return 1
    elif [[ "$currentVersion" -ne "$RC_VERSION" ]]
    then
        echo "Upgrading RhodeCode $RC_APP from $currentVersion to $RC_VERSION"
        rccontrol upgrade $RC_INSTANCEID --version $RC_VERSION
    fi
}

function rc_install {
    echo "Installing RhodeCode $RC_APP $RC_VERSION"
    rccontrol install $RC_COMMON_OPTS $RC_APP --version $RC_VERSION --accept-license --start-at-boot false $RC_INSTALL_OPTS
}


# Initialise variables and RhodeCode Control
rc_init

# Provision the RhodeCode app
rc_upgrade || rc_install

# Start the RhodeCode app
rccontrol start $RC_INSTANCEID
tail -fn 0 $RC_DATA/$RC_APP/${RC_APP,,}.log