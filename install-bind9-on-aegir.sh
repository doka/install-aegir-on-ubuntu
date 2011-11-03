#! /bin/bash
#
# This script installs the bind9 DNS server on top of Aegir 1.x on Ubuntu servers
# (install-bind9-on-aegir.sh)
# on Github: https://github.com/doka/install-aegir-on-ubuntu 
#
# this script assumes:
#  - you have successfully installed Aegir 1.x on Ubuntu server
#  - copy this script to the ubuntu server and make it executable
#       wget https://raw.github.com/doka/install-aegir-on-ubuntu/master/install-bind9-on-aegir.sh
#       chmod 750 ./install-bind9-on-aegir.sh
#
# *******************************************
#    1. install bind9
#
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install bind9
#
#
#    2. allow the aegir user to run rndc
sudo cp /etc/sudoers.d/aegir /tmp/aegir
sudo chmod 640 /tmp/aegir
echo 'aegir ALL=NOPASSWD: /usr/sbin/rndc' | sudo tee -a /tmp/aegir
sudo chmod 440 /tmp/aegir
sudo cp /tmp/aegir /etc/sudoers.d/aegir
#
#
#    3. the bind user get access to read Aegir's files
sudo adduser bind aegir
#
#
#    4. include zone files of Aegir into bind config
echo 'include "/var/aegir/config/bind.conf";' | sudo tee -a /etc/bind/named.conf.local 
#
#
#    5. add nameserver to the beginning of the /etc/resolv.conf file
sudo cp /etc/resolv.conf /tmp/resolv.conf
echo 'nameserver 127.0.0.1' | sudo tee /etc/resolv.conf
cat /tmp/resolv.conf | sudo tee -a /etc/resolv.conf
#
#
#    6. configure apparmor
# quick&dirty: disable the related apparmor profile
sudo ln -s /etc/apparmor.d/usr.sbin.named /etc/apparmor.d/disable/
# sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.named
sudo /etc/init.d/apparmor reload
#
# todo: use apparmor, but put all the Aegir zone files into apparmor scope
#   like sudo ln -s /var/aegir/config/server_master/bind/zone.d/ /var/lib/bind/aegir
#
#
#    7. restart bind
sudo /etc/init.d/bind9 restart
#
#
#    Checkpoint
echo "
#
# Checkpoint / But not yet finished!
#
#   1. activate the DNS Support hosting feature in Aegir frontend 
#   2. activate the DNS on the particular server: select the server in Aegir frontend, 
#      select the DNS service and the bind option. Change the restart command to
#      sudo rndc reload, and click save.
#   3. set the nameserver in /etc/resolv.conf file of every other server to point to this
#      nameserver: put one line nameserver <IP-OF-THIS-NAMESERVER>
"
