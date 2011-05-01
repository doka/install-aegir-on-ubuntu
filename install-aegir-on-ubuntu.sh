#! /bin/bash
#
# Aegir 1.1 install script for Ubuntu 10.10 (Maverick) servers
# (install-aegir-on-ubuntu.sh)
#
# run with users having sudo rights
#

# Prerequisites:
#  - bare ubuntu server install, with OpenSSH server
#
#  - change /etc/hostname 
#        set hostname to $MYFQDN
#
#  - static IP address in /etc/network/interfaces
#       auto eth0
#       iface eth0 inet static
#       address 192.168.1.101
#       network 192.168.1.0
#       netmask 255.255.255.0
#       gateway 192.168.1.1
#
#
#    1. set some parameters in the script
#  
MYHOST="myhost"
MYHOSTIP="192.168.1.101"
MYFQDN=$MYHOST".local"
#       admin.$MYFQDN will be the Aegir admin interface
#
#
#    2. install software requirements by Aegir, but not preinstalled on a bare Ubuntu server
#
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install apache2 php5 php5-cli php5-gd php5-mysql mysql-server postfix git-core unzip 
#
#
#    3. FQDN Configuration
#
# update /etc/hosts
echo '# Aegir FQDN'                             | sudo tee -a /etc/hosts
echo $MYHOSTIP    $MYFQDN admin.$MYFQDN $MYHOST | sudo tee -a /etc/hosts
#       $MYFQDN has to stand right after the IP, otherwise DNS won't work
#
#
#    4. LAMP configurations
#
# PHP: set higher memory limits
sudo sed -i 's/memory_limit = -1/memory_limit = 192M/' /etc/php5/cli/php.ini
#
# Apache
sudo a2enmod rewrite
sudo ln -s /var/aegir/config/apache.conf /etc/apache2/conf.d/aegir.conf
echo 'aegir ALL=NOPASSWD: /usr/sbin/apache2ctl' | sudo tee /tmp/aegir
sudo chmod 440 /tmp/aegir
sudo cp /tmp/aegir /etc/sudoers.d/aegir
#
# MySQL: enable all IP addresses to bind
sudo sed -i 's/bind-address/#bind-address/' /etc/mysql/my.cnf
sudo /etc/init.d/mysql restart
#
#
#   5. Aegir install
#
# add Aegir user
sudo adduser --system --group --home /var/aegir aegir
sudo adduser aegir www-data
#
# Drush install
# 
sudo su -s /bin/sh aegir -c "
cd /var/aegir ;
wget http://ftp.drupal.org/files/projects/drush-7.x-4.4.tar.gz ;
gunzip -c drush-7.x-4.4.tar.gz | tar -xf - ;
rm drush-7.x-4.4.tar.gz ;
"
sudo ln -s /var/aegir/drush/drush /usr/local/bin/drush
#
# install provision backend by drush
echo "installing provision backend ..."
sudo su -s /bin/sh aegir -c "drush dl --destination=/var/aegir/.drush provision-6.x"
#
# install hostmaster frontend by drush
echo "installing frontend: Drupal 6 with hostmaster profile ..."
sudo su -s /bin/sh aegir -c "drush hostmaster-install"
#
#
# Checkpoint / Finished!
#
# The installation will provide you with a one-time login URL to stdout
# or via an e-mail. Use this link to login to your new Aegir site for the 
# first time.
#
# Do not forget to add all the domains you are going to manage by Aegir,
# to your /etc/hosts files, like this:
echo $MYHOSTIP    $MYFQDN admin.$MYFQDN www.$MYFQDN

