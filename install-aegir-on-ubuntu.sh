#! /bin/bash
#
# Aegir 1.x install script for Ubuntu servers
# (install-aegir-on-ubuntu.sh)
# on Github: https://github.com/doka/install-aegir-on-ubuntu 
#
# This script assumes:
#  - your hostname is: myhost.local (it will be the Aegir admin interface)
#  - your IP address is: 192.168.1.101
#  - you can use other hostname and network parameters, but your hostname has
#    to be a full qualified domain name (FQDN)
#
# Prerequisites:
#  - you run this script on a bare ubuntu server, only extra is OpenSSH server
#   
#  - you run this script with a user having sudo rights
#
#  - you have set static IP address in /etc/network/interfaces like this:
#       auto eth0
#       iface eth0 inet static
#       address 192.168.1.101
#       network 192.168.1.0
#       netmask 255.255.255.0
#       gateway 192.168.1.1
#
#  - change the hostname 
#        delete the old hostname, and write your hostname (myhost.local)
#        into /etc/hostname
#        echo 'myhost.local' | sudo tee /etc/hostname
#
#  - update /etc/hosts
#       add following line: 192.168.1.101    myhost.local
#       echo '192.168.2.101 myhost.local' | sudo tee -a /etc/hosts
#
#  - reboot your server!
#
#  - copy this script to the ubuntu server and make it executable
#       wget https://raw.github.com/doka/install-aegir-on-ubuntu/master/install-aegir-on-ubuntu.sh
#       chmod 750 ./install-aegir-on-ubuntu.sh
#
#
# ***********************************
# set versions Aegir & Drush versions
DRUSH_VERSION="7.x-4.5"
#DRUSH_VERSION="7.x-4.4"
#
AEGIR_VERSION="6.x-1.8"
#AEGIR_VERSION="6.x-1.7"
#AEGIR_VERSION="6.x-1.6"
#AEGIR_VERSION="6.x-1.5"
#AEGIR_VERSION="6.x-1.4"
#AEGIR_VERSION="6.x-1.3"
#AEGIR_VERSION="6.x-1.2"
#AEGIR_VERSION="6.x-1.1"
#AEGIR_VERSION="6.x-1.0"
# ***********************************
#
# 
#    1. install software requirements by Aegir, but not preinstalled on a bare
#       Ubuntu server. Set the root password for MySQL, and accept the defaults
#       at postfix install (Internet site, ...)
#
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install apache2 php5 php5-cli php5-gd php5-mysql mysql-server postfix git-core unzip
#
#
#    2. LAMP configurations
#
# PHP: set higher memory limits
sudo sed -i 's/memory_limit = -1/memory_limit = 192M/' /etc/php5/cli/php.ini
#
# Apache
sudo a2enmod rewrite
sudo ln -s /var/aegir/config/apache.conf /etc/apache2/conf.d/aegir.conf
#
# MySQL: enable all IP addresses to bind
sudo sed -i 's/bind-address/#bind-address/' /etc/mysql/my.cnf
sudo service mysql restart
#
#
#   3. Aegir install
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
# generate SSH keys for the aegir user
sudo su -s /bin/sh - aegir -c "ssh-keygen -t rsa"

# Drush install
# 
sudo su -s /bin/sh - aegir -c "
wget http://ftp.drupal.org/files/projects/drush-$DRUSH_VERSION.tar.gz ;
gunzip -c drush-$DRUSH_VERSION.tar.gz | tar -xf - ;
rm drush-$DRUSH_VERSION.tar.gz ;
"
sudo ln -s /var/aegir/drush/drush /usr/local/bin/drush
#
# install provision backend by drush
echo "installing provision backend ..."
sudo su -s /bin/sh - aegir -c "drush dl --destination=/var/aegir/.drush provision-$AEGIR_VERSION"
#
# install hostmaster frontend by drush, incl drush_make
echo "installing frontend: Drupal 6 with hostmaster profile ..."
sudo su -s /bin/sh - aegir -c "drush hostmaster-install"
echo "
Aegir install ready, above you have the login link!

Now we are patching...
"
#
#
# apply patches to drush_make
#
# Aegir 6.x-1.0 - 6.x-1.2 is using drush_make 6.x-2.2
if [ "$AEGIR_VERSION" == "6.x-1.0" ] || [ "$AEGIR_VERSION" == "6.x-1.1" ] || [ "$AEGIR_VERSION" == "6.x-1.2" ] ; then
# 1. http://drupal.org/node/947158
#    resolves recursive make file issue if two makefiles contains the same module
  sudo su -s /bin/sh - aegir -c "
  wget http://drupal.org/files/issues/947158-recursive_2.patch ;
  cd /var/aegir/.drush/drush_make ;
  patch -p 1 < ~/947158-recursive_2.patch ;
  rm ~/947158-recursive_2.patch ;
  "
# 
# 2. http://drupal.org/node/745224
#    Apply patches from git diff and git format-patch (p0 - p1)
  sudo su -s /bin/sh - aegir -c "
  wget http://drupal.org/files/issues/drush_make-745224-git-apply-104.patch ;
  cd /var/aegir/.drush/drush_make ;
  patch -p 1 < ~/drush_make-745224-git-apply-104.patch ;
  rm ~/drush_make-745224-git-apply-104.patch ;
  "
#
# from Aegir 6.x-1.3 drush_make 6.x-2.3 is used
else
# 1. http://drupal.org/node/1253414
#    Allows to use different versions of the same project in nested make files
  sudo su -s /bin/sh - aegir -c "
  wget http://drupal.org/files/1253414-allow-multiple-module-versions_0.patch ;
  cd /var/aegir/.drush/drush_make ;
  patch -p 1 < ~/1253414-allow-multiple-module-versions_0.patch ;
  rm ~/1253414-allow-multiple-module-versions_0.patch ;
  "
# 
fi
#
echo "
#
# Checkpoint / But not yet finished!
#
# The installation has provided you with a one-time login URL to stdout
# (see above), or via an e-mail. Use this link to login to your new Aegir site
# for the first time.
#
# 1. Do not forget to add all the domains you are going to manage by Aegir,
#    to your /etc/hosts files on every boxes your are using!
# 
# 2. Copy your public id to remote servers, if you use any remote servers:
#      ssh-copy-id <myhost.local>
#      ssh <myhost.local> 
#
# 3. You can switch to the aegir user by: 
#      sudo su -s /bin/bash - aegir
#
"
