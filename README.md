# check_routeros-upgrade

A simple monitoring plugin to check RouterOS for updates. A simple monitoring plugin to check RouterOS for updates.

**Features**
* connect with SNMP or SSH
* select your RouterOS release tree

**Exampleoutput**
* RouterOS 6.39.2 is up to date (release: 2017-Jun-06)
* RouterOS is upgradable to 6.38.7 (release: 2017-Jun-20)

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
