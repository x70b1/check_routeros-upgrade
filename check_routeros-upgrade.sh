#!/bin/sh

# check_routeros-upgrade
# https://github.com/x70b1/check_routeros-upgrade
#
# This script checks if there is an upgrade for a mikrotik device available.

ERROR_MSG="0"

# connect to a device
if [ "$1" = "snmp" ]; then
    if [ -z "$3" ]; then
        PARAM_PORT="161"
    else
        PARAM_PORT=$3
    fi

    if [ -z "$4" ]; then
        PARAM_COMMUNITY="public"
    else
        PARAM_COMMUNITY=$4
    fi

    if ! ROUTEROS_INSTALLED=$(snmpget -O qv -v 2c -c "$PARAM_COMMUNITY" "$2":"$PARAM_PORT" SNMPv2-SMI::enterprises.14988.1.1.4.4.0 2> /dev/null); then
        ERROR_MSG="Could not establish an SNMP connection to the device!"
    else
        ROUTEROS_INSTALLED=$(echo "$ROUTEROS_INSTALLED" | tr -d '"')
    fi
elif [ "$1" = "ssh" ]; then
    if [ -z "$3" ]; then
        PARAM_PORT="22"
    else
        PARAM_PORT=$3
    fi

    if [ -z "$4" ]; then
        PARAM_USER="user"
    else
        PARAM_USER=$4
    fi

    if ! ROUTEROS_INSTALLED=$(ssh -q -p "$PARAM_PORT" "$PARAM_USER"@"$2" "/system package update print"); then
        ERROR_MSG="Could not establish an SSH connection to the device!"
    else
        ROUTEROS_INSTALLED=$(echo "$ROUTEROS_INSTALLED" | grep "installed" | tr -d '\r\n' | tr -d ' ' | cut -d ':' -f 2)
    fi
else
    echo "Use SNMP or SSH as connection type!"
    exit 2
fi


# are there connection errors?
if [ "$ERROR_MSG" = "0" ]; then
    # which version should run?
    case $5 in
        "stable")
            PARAM_VERSION="6"
            ;;
        "release-candidate")
            PARAM_VERSION="6rc"
            ;;
        "bugfix")
            PARAM_VERSION="6fix"
            ;;
        *)
            PARAM_VERSION="6"
            ;;
    esac

    # check the mikrotik server for upgrades
    if ! ROUTEROS_AVAILABLE=$(curl -f -s -A 'check_routeros-upgrade' http://upgrade.mikrotik.com/routeros/LATEST.$PARAM_VERSION); then 
        echo "Could not reach the mikrotik upgrade server :("
        exit 1

    fi

    ROUTEROS_AVAILABLE_VERSION=$(echo "$ROUTEROS_AVAILABLE" | cut -d ' ' -f 1)
    ROUTEROS_AVAILABLE_RELEASEDATE=$(echo "$ROUTEROS_AVAILABLE" | cut -d ' ' -f 2)

    # check latest requested version against the device version
    if [ "$ROUTEROS_AVAILABLE_VERSION" = "$ROUTEROS_INSTALLED" ]; then
        echo "RouterOS version $ROUTEROS_AVAILABLE_VERSION is up to date (Release: $(date -d @"$ROUTEROS_AVAILABLE_RELEASEDATE" +'%a %d %b %Y'))"
        exit 0
    else
        echo "RouterOS is upgradable to version $ROUTEROS_AVAILABLE_VERSION (Release: $(date -d @"$ROUTEROS_AVAILABLE_RELEASEDATE" +'%a %d %b %Y'))"
        exit 2
    fi
else
    echo "$ERROR_MSG"
    exit 1
fi
