#!/bin/bash

# School's darn proxy
echo 'Acquire::http {
    Proxy "http://192.168.1.253:9999";
};' > /etc/apt/apt.conf.d/30proxy

# Using Trusty64 Ubuntu
rm /var/lib/apt/lists/* -f
apt-get update
apt-get install -y build-essential software-properties-common python-software-properties

#
# Setup locales
#
echo -e "LC_CTYPE=fr_FR.UTF-8\nLC_ALL=fr_FR.UTF-8\nLANG=fr_FR.UTF-8\nLANGUAGE=fr_FR.UTF-8" | tee -a /etc/environment > /dev/null
locale-gen fr_FR fr_FR.utf8
dpkg-reconfigure locales

export LANGUAGE=fr_FR.UTF-8
export LANG=fr_FR.UTF-8
export LC_ALL=fr_FR.UTF-8

#
# Hostname
#
hostnamectl set-hostname slim-vm

#
# Apache
#
apt-get install -y apache2 libapache2-mod-php5

#
# PHP
#
apt-get install -y php5 php5-cli php5-dev php-pear php5-mcrypt php5-curl php5-intl php5-xdebug php5-gd php5-imagick php5-imap php5-mhash php5-xsl
php5enmod mcrypt intl curl

# Update PECL channel
pecl channel-update pecl.php.net

#
# Apc
#
apt-get -y install php-apc php5-apcu
echo 'apc.enable_cli = 1' | tee -a /etc/php5/mods-available/apcu.ini > /dev/null

#
# Memcached
#
apt-get install -y memcached php5-memcached php5-memcache

#
# Beanstalkd
#
apt-get -y install beanstalkd

#
# YAML
#
apt-get install libyaml-dev
(CFLAGS="-O1 -g3 -fno-strict-aliasing"; pecl install yaml < /dev/null &)
echo 'extension = yaml.so' | tee /etc/php5/mods-available/yaml.ini > /dev/null
php5enmod yaml

#
# Utilities
#
apt-get install -y curl htop git dos2unix unzip vim grc gcc make re2c libpcre3 libpcre3-dev lsb-core autoconf npm

#
# Front-end Utilities
#
npm install -g bower yo grunt
ln -s /usr/bin/nodejs /usr/bin/node

#
# Composer for PHP
#
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

#
# Apache VHost
#
mkdir -p /vagrant/www/application/public
cd ~
echo '<VirtualHost *:80>
        DocumentRoot /vagrant/www/application/v1
        ErrorLog  /vagrant/www/projects-error.log
        CustomLog /vagrant/www/projects-access.log combined
</VirtualHost>

<Directory "/vagrant/www">
        Options Indexes Followsymlinks
        AllowOverride All
        Require all granted
</Directory>' > vagrant.conf

mv vagrant.conf /etc/apache2/sites-available
a2enmod rewrite

#
# Update PHP Error Reporting
#
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php5/apache2/php.ini
sudo sed -i 's/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ALL/' /etc/php5/apache2/php.ini
sudo sed -i 's/display_errors = Off/display_errors = On/' /etc/php5/apache2/php.ini
#  Append session save location to /tmp to prevent errors in an odd situation..
sudo sed -i '/\[Session\]/a session.save_path = "/tmp"' /etc/php5/apache2/php.ini

#
# Reload apache
#
sudo a2ensite vagrant
sudo a2dissite 000-default
sudo service apache2 restart

#
#  Cleanup
#
sudo apt-get autoremove -y

sudo usermod -a -G www-data vagrant

echo -e "----------------------------------------"
echo -e "Done!:\n"
echo -e "----------------------------------------"
echo -e "$ cd /vagrant/www"
echo -e "$ if you are at home remove the proxy setup"
echo -e "$ in /etc/apt/apt.conf.d/30proxy"
echo -e "----------------------------------------"
echo -e "Default Site: http://192.168.33.10"
echo -e "----------------------------------------"
