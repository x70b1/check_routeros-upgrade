# check_routeros-upgrade

A simple monitoring plugin to check RouterOS for updates. This script should work with different monitoring frameworks like Nagios, Icinga, Naemon, Shinken or Sensu.

**Features**

* connect with SNMP or SSH
* select your RouterOS release tree
* read the changelog to get more information about bugfix importance

**Message and return code**

The return code depends on the importance of the fixes found in the changelog. An important bugfix leads to a `CRITICAL`. Average fixes result in a `WARNING`. Some examples:

* OK: RouterOS 6.39.2 is up to date (release: Jun-06)
* WARNING: RouterOS is upgradable to 6.39.2 (6 average fixes)
* CRITICAL: RouterOS is upgradable to 6.38.7 (2 important fixes, 75 average fixes)

## Configuration

* sh **check_routeros-upgrade.sh** *snmp* *HOST* [*PORT*] [*COMMUNITY*] [*RELEASE-TREE*]
* sh **check_routeros-upgrade.sh** *ssh* *HOST* [*PORT*] [*USER*] [*RELEASE-TREE*]

The default values for SNMP are:
* PORT=161
* COMMUNITY=public

For a check over SSH:
* PORT=22
* USER=user

You need an user and SSH keys. There is no option for a password.

**[RELEASE TREE]**

Different settings are available. The default is `stable`. Choose wise.

* stable
* bugfix
* release-candidate
