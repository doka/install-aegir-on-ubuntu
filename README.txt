Aegir 1.x install script for Ubuntu servers
---------------------------------------------------------
Repo: https://github.com/doka/install-aegir-on-ubuntu/tree/master
Raw script: https://raw.github.com/doka/install-aegir-on-ubuntu/master/install-aegir-on-ubuntu.sh


It installs Aegir 1.x (http://aegirproject.org/) with all prerequisites
together on a bare Ubuntu server, on a local network.


This script helps Aegir users
-----------------------------
- to quick start with Aegir installation on Ubuntu
- install all software requirements
- configure the system parameters
- run the Aegir install script
- apply patches if needed


Getting started
---------------
- install a bare Ubuntu server, with OpenSSH
- login and switch to root ('sudo su')
- choose the appropriate branch on Github (Natty or Maverick or ...)
  and download the script
- check and change the versions for Aegir & Drush in the script
- prepare your server
    - set a fix IP address to the server
    - adapt the hostname in /etc/hostname
    - update /etc/hosts and /etc/resolv.conf
  as described in the script
- change access and execution rights: chmod 775 install-aegir-on-ubuntu.sh
- execute the script
- follow the instruction on the terminal, answer few questions during install


Restrictions
------------
- the install script works with Aegir 1.x,
- Do not use on production environments
- It has no security hardening


Maintainers
-----------
- doka@wepoca.net


Credits
-------
http://aegirproject.org/

