Aegir 1.x install scripts for Ubuntu servers
-----------------------------------------------------
Repo: https://github.com/doka/install-aegir-on-ubuntu

Few scripts to help install Aegir 1.x (http://aegirproject.org/) with all prerequisites
on bare Ubuntu servers, on a local network or on virtual machines.

The scripts:
1. install-aegir-on-ubuntu.sh: it installs the Aegir master server
2. install-remote-webserver.sh <AEGIR-SERVER-IP>: installs remote servers to be managed by Aegir
3. install-bind9-on-aegir.sh: installs DNS services on Aegir master or remote servers


These scripts help Aegir users
-----------------------------
- to quick start with Aegir installation on Ubuntu
- install all software requirements
- set Aegir and Drush versions as required
- configure the system parameters
- run the Aegir install script
- apply patches if needed


Getting started
---------------
- install a bare Ubuntu server, with OpenSSH
- login and switch to root ('sudo su')
- choose the appropriate Ubuntu branch on Github and download the script
- starts with the install-aegir-on-ubuntu.sh script, then eventually install some
  remote servers by the install-remote-webserver.sh script, and pick one server for
  the DNS service, and install it via install-bind9-on-aegir.sh
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
- the install scripts work with Aegir 1.x,
- the install-remote-webserver.sh and the install-bind9-on-aegir.sh scripts has been
  only tested on Ubuntu 11.10
- Do not use on production environments
- It has no security hardening


Maintainers
-----------
- doka@wepoca.net


Credits
-------
http://aegirproject.org/

