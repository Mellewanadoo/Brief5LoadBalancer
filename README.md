# Brief5LoadBalancer

## Création de mes ressources.

Après un `az login` dans mon ubuntu puis, je lance mon script wordpressbash.sh, qui me crée et configure la majorité de mes ressources.

## Derniers parametrages 
Je vais sur [Lien](https://portal.azure.com/) pour faire les derniers parametrages.
 ![Règles NAT traffic entrant](https://github.com/Mellewanadoo/Brief5LoadBalancer/blob/main/regleNatEntrante.png)
  ![Règle PAT pour autorisé mon IP](https://github.com/Mellewanadoo/Brief5LoadBalancer/blob/main/mariadbpat.png)
  Je verifie mon diagramme ![Diagramme de mon réseau](https://github.com/Mellewanadoo/Brief5LoadBalancer/blob/main/diagramme.png)
  
## Configuration de mes VM
```bash
ssh camilledesousamathieu@20.124.63.90 -p 55555
sudo apt-get update 
# Installation de Apache
sudo apt -y install apache2
sudo systemctl enable apache2
#pour demarrer apache en même temps que la machine
sudo systemctl status apache2
ctrl+c
#pour verifier que apache est bien démarré
sudo apache2ctl -v
#pour verifier la version Apache2
sudo a2enmod rewrite
#pour avoir de belles url
sudo a2enmod ssl
#pour gerer les pages HTTPS
sudo a2enmod deflate
#pour les caches et cookies pour evitez trop de requètes serveur
sudo a2enmod headers
#Pour le a2 a2dismod <nomDuModule> pour desactiver l'un des module
sudo systemctl restart apache2
#pour redemarrer apache2 et que les modules soit utilisables
sudo apt-get install -y apache2-utils
############################################################################################
#
#				INSTALLATION PHP
#
############################################################################################
sudo apt -y update
# Installation de php
sudo apt -y install php libapache2-mod-php php-mysql
sudo apt-get install -y php
sudo apt-get install -y php-pdo php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath
php -v
sudo nano /var/www/html/phpinfo.php
############# 
<?php
phpinfo();
?>
############################################################################################
#
#				INSTALLATION MARIADB
#
############################################################################################
sudo apt -y install mariadb-client
mariadb --user=CDSMMariaDB@mariadbcdsm --password=Mot2passe --host=mariadbcdsm.mariadb.database.azure.com
CREATE DATABASE wpbriefloadbalancer_cdsm; # Je ne le fais qu'une fois #
FLUSH PRIVILEGES;
############################################################################################
#
#				INSTALLATION WORDPRESS
#
# 
############################################################################################
cd /tmp
wget https://wordpress.org/latest.zip

############Décompresser l'archive WordPress à la racine du site
sudo rm /var/www/html/index.html
sudo apt-get update 
sudo apt-get install -y zip
sudo unzip latest.zip -d /var/www/html
cd /var/www/html
sudo mv wordpress/* /var/www/html/
sudo rm wordpress/ -Rf
sudo find /var/www/html/ chmod u-w wp-config.php
sudo chown -R www-data:www-data /var/www/html/
sudo find /var/www/html/ -type f -exec chmod 644 {} \;
sudo find /var/www/html/ -type d -exec chmod 755 {} \;


sudo systemctl restart apache2
```
## Rendu du Wordpress 
![Mon Wordpress](https://github.com/Mellewanadoo/Brief5LoadBalancer/blob/main/Wordpress.png)
