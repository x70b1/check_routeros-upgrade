#!/bin/sh

#  check_routeros-upgrade.sh
#
#  A simple monitoring plugin to check RouterOS for updates.

error="0"

if [ -z "${ROUTEROS_UPDATEURL}" ]; then
    routeros_url="https://download.mikrotik.com/routeros"
else
    routeros_url="${ROUTEROS_UPDATEURL}"
fi

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

    if ! routeros_installed=$(snmpget -O qv -v 2c -c "$param_community" "$2":"$param_port" .1.3.6.1.4.1.14988.1.1.4.4.0 2> /dev/null); then
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
        routeros_installed=$(echo "$routeros_installed" | tr -d "\\r\\n")
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

    # check the MikroTik server for upgrades
    if ! routeros_available=$(curl -fsA "check_routeros-upgrade" "$routeros_url/LATEST.$param_version"); then
        echo "Could not reach the MikroTik server to check the latest version!"
        exit 1
    fi

    routeros_available_version=$(echo "$routeros_available" | cut -d " " -f 1)
    routeros_available_releasedate=$(echo "$routeros_available" | cut -d " " -f 2)

    # compare latest version with device version
    if [ "$routeros_available_version" = "$routeros_installed" ]; then
        echo "RouterOS $routeros_available_version is up to date (release: $(date -u -d @"$routeros_available_releasedate" +'%b-%d'))"
        exit 0
    else
        # read the changelog
        if ! changelog=$(curl -fsA "check_routeros-upgrade" "$routeros_url/$routeros_available_version/CHANGELOG"); then
            echo "Could not reach the MikroTik server to read the changelog!"
            exit 1
        fi

        changelog_lines=$(echo "$changelog" | grep -n "What" | head -n 2 | tail -n 1 | cut -d ":" -f 1)

        changelog_impfix=$(echo "$changelog" | head -n "$changelog_lines" | grep -c '!)')
        changelog_avgfix=$(echo "$changelog" | head -n "$changelog_lines" | grep -c '[*])')

        if [ "$changelog_impfix" -ne 0 ] && [ "$changelog_avgfix" -ne 0 ]; then
            fix_text="$changelog_impfix important fixes, $changelog_avgfix average fixes"
            fix_result=2
        elif [ "$changelog_impfix" -ne 0 ]; then
            fix_text="$changelog_impfix important fixes"
            fix_result=2
        elif [ "$changelog_avgfix" -ne 0 ]; then
            fix_text="$changelog_avgfix average fixes"
            fix_result=1
        fi

        echo "RouterOS is upgradable to $routeros_available_version ($fix_text)"
        exit $fix_result
    fi
else
    echo "$error"
    exit 2
fi
