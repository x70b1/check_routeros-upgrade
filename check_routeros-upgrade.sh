#!/bin/sh

#  check_routeros-upgrade.sh
#
#  A simple monitoring plugin to check RouterOS for updates.

error="0"


if [ "$1" = "snmp" ]; then
    if [ -z "$3" ]; then
        param_port="161"
    else
        param_port=$3
    fi

    if [ -z "$4" ]; then
        param_community="public"
    else
        param_community=$4
    fi

    if ! routeros_installed=$(snmpget -O qv -v 2c -c "$param_community" "$2":"$param_port" SNMPv2-SMI::enterprises.14988.1.1.4.4.0 2> /dev/null); then
        error="Could not establish an SNMP connection to the device!"
    else
        routeros_installed=$(echo "$routeros_installed" | tr -d '"')
    fi
elif [ "$1" = "ssh" ]; then
    if [ -z "$3" ]; then
        param_port="22"
    else
        param_port=$3
    fi

    if [ -z "$4" ]; then
        param_user="user"
    else
        param_user=$4
    fi

    if ! routeros_installed=$(ssh -q -p "$param_port" "$param_user"@"$2" ':put [/system package get system version]'); then
        error="Could not establish an SSH connection to the device!"
    else
        routeros_installed=$(echo "$routeros_installed" | tr -d "\r\n")
    fi
else
    echo "Use SNMP or SSH as connection type!"
    exit 2
fi


if [ "$error" = "0" ]; then
    # select the version
    case $5 in
        "stable")
            param_version="6"
            ;;
        "release-candidate")
            param_version="6rc"
            ;;
        "bugfix")
            param_version="6fix"
            ;;
        *)
            param_version="6"
            ;;
    esac

    # check the mikrotik server for upgrades
    if ! routeros_available=$(curl -fsA 'check_routeros-upgrade' https://upgrade.mikrotik.com/routeros/LATEST.$param_version); then 
        echo "Could't reach the Mikrotik-Server!"
        exit 1

    fi

    routeros_available_version=$(echo "$routeros_available" | cut -d ' ' -f 1)
    routeros_available_releasedate=$(echo "$routeros_available" | cut -d ' ' -f 2)

    # compare latest version with device version
    if [ "$routeros_available_version" = "$routeros_installed" ]; then
        echo "RouterOS $routeros_available_version is up to date (release: $(date -u -d @"$routeros_available_releasedate" +'%Y-%b-%d'))"
        exit 0
    else
        echo "RouterOS is upgradable to $routeros_available_version (release: $(date -u -d @"$routeros_available_releasedate" +'%Y-%b-%d'))"
        exit 2
    fi
else
    echo "$error"
    exit 1
fi
