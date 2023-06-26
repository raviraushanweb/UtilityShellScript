#!/bin/bash

# Update Packages
echo "[Updating Packages]"
sudo apt update
sudo apt upgrade -y

# Install Apache
echo "[Installing Apache]"
sudo apt install apache2 -y

# Install MySQL
echo "[Installing MySQL]"
sudo apt install mysql-server -y

echo "[Securing MySQL]"
sudo mysql -e "CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY 'password';"  # Replace 'password' with your desired password
sudo mysql -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
sudo mysql -e "GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Install PHP
echo "[Installing PHP]"
sudo apt-get purge `dpkg -l | grep php| awk '{print $2}' |tr "\n" " "` -y
sudo apt install php libapache2-mod-php php-mysql -y
PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1,2)
sudo a2enmod php$PHP_VERSION

# Download and Setup WordPress
echo "[Setting up WordPress]"
cd /tmp
curl -LO https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
sudo cp -a /tmp/wordpress/. /var/www/html

echo "[Configuring WordPress]"
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo sed -i "s/database_name_here/wordpress/g" /var/www/html/wp-config.php
sudo sed -i "s/username_here/wordpressuser/g" /var/www/html/wp-config.php
sudo sed -i "s/password_here/password/g" /var/www/html/wp-config.php  # Replace 'password' with your MySQL user password

# Adjust Apache's Configuration to Correctly Handle WordPress
echo "[Configuring Apache for WordPress]"
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf
sudo sed -i "s|DocumentRoot /var/www/html|DocumentRoot /var/www/html|g" /etc/apache2/sites-available/wordpress.conf
sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# Configure Ownership and Permissions
echo "[Setting Permissions]"
sudo chown -R www-data:www-data /var/www/html/
sudo find /var/www/html/ -type d -exec chmod 750 {} \;
sudo find /var/www/html/ -type f -exec chmod 640 {} \;

# Disable default Apache page
echo "[Disabling Default Apache Page]"
if [ -f /var/www/html/index.html ]; then
    sudo rm /var/www/html/index.html
fi
