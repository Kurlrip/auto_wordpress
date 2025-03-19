#!/bin/bash
set -e

# Variables de configuration
WP_DB_NAME="wordpressdb"
WP_DB_USER="wp_user"
WP_DB_PASSWORD="qc3wvwe"  # Changez ce mot de passe
WP_DIR="/var/www/html"

echo "Mise à jour du système..."
sudo apt update && sudo apt upgrade -y

echo "Installation des paquets nécessaires : Apache, OpenSSH, MySQL, PHP et modules complémentaires..."
sudo apt install -y apache2 openssh-server mysql-server php php-mysql libapache2-mod-php php-curl php-json php-mbstring php-xml php-xmlrpc php-zip php-soap php-intl php-bcmath wget unzip

echo "Activation du module Apache rewrite..."
a2enmod rewrite
systemctl restart apache2

echo "Téléchargement et extraction de WordPress..."
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz

echo "Copie des fichiers WordPress dans $WP_DIR..."
rm -rf $WP_DIR/*
cp -R wordpress/* $WP_DIR/

echo "Mise en place des permissions sur $WP_DIR..."
chown -R www-data:www-data $WP_DIR
chmod -R 755 $WP_DIR

echo "Création de la base de données et de l'utilisateur MySQL..."
mysql -e "CREATE DATABASE ${WP_DB_NAME} DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql -e "CREATE USER '${WP_DB_USER}'@'localhost' IDENTIFIED BY '${WP_DB_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON ${WP_DB_NAME}.* TO '${WP_DB_USER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

echo "Configuration de WordPress..."
cd $WP_DIR
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/${WP_DB_NAME}/" wp-config.php
sed -i "s/username_here/${WP_DB_USER}/" wp-config.php
sed -i "s/password_here/${WP_DB_PASSWORD}/" wp-config.php

echo "Installation terminée !"
echo "Vous pouvez finaliser la configuration de WordPress en accédant à votre serveur via un navigateur."
