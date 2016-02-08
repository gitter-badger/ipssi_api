#!/bin/bash

# School's darn proxy
echo 'Acquire::http {
    Proxy "http://192.168.1.253:9999";
};' > /etc/apt/apt.conf.d/30proxy

#
# Add some repos
#
# MongoDB
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

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

#
# MongoDB
#
sudo apt-get install -y mongodb-org

# Update PECL channel
pecl channel-update pecl.php.net

#
# Utilities
#
apt-get install -y curl htop git dos2unix unzip vim grc gcc make re2c libpcre3 libpcre3-dev lsb-core autoconf npm

#
# Front-end Utilities
#
npm install -g bower
npm install -g grunt-cli
npm install -g yo
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
