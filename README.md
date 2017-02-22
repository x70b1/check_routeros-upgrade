# check_routeros-upgrade
	
This script checks if there is an upgrade for a mikrotik device available. It should work with different monitoring frameworks like Nagios, Icinga, Naemon, Shinken or Sensu.

**Features**
* check your device over SNMP or SSH
* select your RouterOS release tree

**Exampleoutput**
* RouterOS version 6.38.3 is up to date (Release: Di 07 Feb 2017)
* RouterOS is upgradable to version 6.39rc33 (Release: Fr 17 Feb 2017)

## Configuration

* sh **check_routeros-upgrade.sh** *snmp* *HOST* [*PORT*] [*COMMUNITY*] [*RELEASE-TREE*]
* sh **check_routeros-upgrade.sh** *ssh* *HOST* [*PORT*] [*USER*] [*RELEASE-TREE*]

The default values for SNMP are:
* PORT=161
* COMMUNITY=public
* RELEASE-TREE=stable 

For a check over SSH:
* PORT=22
* USER=user
* RELEASE-TREE=stable 

You have to setup an user with ssh-key-access. There are no options for a password.

**[RELEASE TREE]**

Here are different settings usable. Select yours:

* stable
* bugfix
* release-candidate
