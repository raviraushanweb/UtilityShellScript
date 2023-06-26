#!/bin/bash

# Stop the Apache and MySQL services first
echo "[Stopping Apache and MySQL]"
sudo systemctl stop apache2
sudo systemctl stop mysql

# Remove Apache
echo "[Removing Apache]"
sudo apt-get remove apache2* -y
sudo apt-get autoremove -y

# Remove PHP
echo "[Removing PHP]"
sudo apt-get remove php* -y
sudo apt-get autoremove -y

# Remove MySQL Server
echo "[Removing MySQL]"
sudo apt-get remove mysql-server -y
sudo apt-get autoremove -y

# Remove WordPress files
echo "[Removing WordPress]"
sudo rm -rf /var/www/html/*

# Remove MySQL data directory
echo "[Removing MySQL Data Directory]"
sudo rm -rf /var/lib/mysql/
