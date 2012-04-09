#! /bin/bash
#
# install script for remote webserver for Aegir on Ubuntu servers
# (install-remote-webserver.sh <AEGIR-SERVER-IP>)
# on Github: https://github.com/doka/install-aegir-on-ubuntu 
#
# run with users with sudo rights:
# ./install-remote-webserver.sh <AEGIR-MASTER-SERVER-IP>
#
# this script assumes:
#    - it has one paramater, which is the IP of the Aegir master server ($1)
#    - your hostname is: myhost.local
#    - your IP address is: 192.168.1.101, which is on the same subnet with
#      Aegir master server
#
# you can use other hostname and network parameters, but
# your hostname has to be a full qualified domain name (FQDN) 
#
# Prerequisites:
#  you run this script on a bare ubuntu server install, with OpenSSH server
#  and you have already done the following changes on that server:
#  
#  - change the hostname 
#        delete the old hostname, and write your hostname (myhost.local) into
#        /etc/hostname
#
#  - change to static IP address in /etc/network/interfaces
#       auto eth0
#       iface eth0 inet static
#       address 192.168.1.101
#       network 192.168.1.0
#       netmask 255.255.255.0
#       gateway 192.168.1.1
#
#  - update /etc/hosts
#       add following line to the end:
#       192.168.1.101    myhost.local  myhost
#
#  - copy this script to the remote server and make it executable
#       chmod 750 ./install-remote-webserver.sh
#
#  and reboot your server!
#
# -----------------------------------------------------------------------------
#    0. Parameter check
if [ "$1" = "" ]
then
  echo "Usage: $0 <AEGIR-MASTER-SERVER-IP>"
  exit
fi
#
#    1. install software requirements by Aegir, but not preinstalled on a bare
#       Ubuntu server. Set the root password for MySQL, and accept the defaults
#       at postfix install (Internet site, ...)
#
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install rsync apache2 php5 php5-cli php5-mysql postfix mysql-client mysql-server php5-gd
#
#
#    2. LAMP configurations
#
echo "LAMP configurations ..."
#
# PHP: set higher memory limits
sudo sed -i 's/memory_limit = -1/memory_limit = 192M/' /etc/php5/cli/php.ini
#
# Apache
sudo a2enmod rewrite
sudo ln -s /var/aegir/config/apache.conf /etc/apache2/conf.d/aegir.conf
#
# MySQL
#   enable all IP addresses to bind
sudo sed -i 's/bind-address/#bind-address/' /etc/mysql/my.cnf
sudo service mysql restart
#
#   authorize the Aegir master server to access the database
read -s -p "MySQL password for Aegir: " MYSQLPWD; echo 
SQL="GRANT ALL PRIVILEGES ON *.* TO root@'$1' IDENTIFIED BY '$MYSQLPWD' WITH GRANT OPTION;FLUSH PRIVILEGES;"
echo "Enter the root password for MySQL!"
mysql -uroot -p -e "$SQL"
#
#
#   3. Aegir install
#
echo "Aegir install ..."
#
# add Aegir user
sudo adduser --system --group --home /var/aegir aegir
sudo adduser aegir www-data
#
# sudo rights for the Aegir user to restart Apache
echo 'aegir ALL=NOPASSWD: /usr/sbin/apache2ctl' | sudo tee /tmp/aegir
sudo chmod 440 /tmp/aegir
sudo cp /tmp/aegir /etc/sudoers.d/aegir
#
# set login shell for the aegir user
sudo chsh -s /bin/sh aegir
#
# set password for the aegir user
echo "
Set password for the aegir user:"
sudo passwd aegir
#
# prepare the SSH login for the aegir user, and read comments below to finish!
sudo su -s /bin/sh - aegir -c "
mkdir .ssh
chmod 700 .ssh
touch .ssh/authorized_keys
chmod 600 .ssh/authorized_keys
"
# -----------------------------------------------------------------------------
#
echo "Checkpoint / But not yet finished!
#
# post install activities:
# 
# 1. Do not forget to add all the domains you are going to manage by Aegir,
#    to your /etc/hosts files on every boxes your are using!
# 
# 2. Create and copy the SSH public key to the remote server. Login as aegir
#    to the Aegir master and:
#       - if SSH keys not yet exist on Aegir master, execute: ssh-keygen -t rsa
#         follow the promts, but do not set a passphrase!
#       - copy the public key to the remote server: ssh-copy-id <myhost.local>
#       - login to the remote server via SSH: ssh <myhost.local>
#
# 3. Validate this remote server in Aegir frontend at Aegir master server, 
#    and create platforms and sites.
#
# You can switch to the aegir user by: 
#     sudo su -s /bin/bash - aegir
#
# good luck!
#
"
