Aegir install script for Ubuntu10.4 LTS server
----------------------------------------------
https://github.com/doka/install-aegir-on-ubuntu/raw/master/install-aegir-on-ubuntu.sh

It installs Aegir 0.4 (http://aegirproject.org/) with all prerequisites
together on a bare Ubuntu 10.4 LTS server on a local network.


This script helps Aegir users
-----------------------------
- to quick start with Aegir installation on Ubuntu
- install all software requirements
- configure the system parameters
- run the Aegir install script


Getting started
---------------
- install a bare Ubuntu 10.4 LTS server, with OpenSSH
- login and switch to root ('sudo su')
- set a fix IP address to the server
- download this script
- adjust the parameters like IP of the host
- change access and execution rights: chmod 775 install-aegir-on-ubuntu.sh
- execute the script
- follow the instruction on the terminal, answer few questions during install


Restrictions
------------
- the install script works with Aegir 0.4-rc1 or 0.4-beta2,
  use the respective tag
- Do not use on production environments
- It has no security hardening


Maintainers
-----------
- doka@wepoca.net


Credits
-------
http://aegirproject.org/

