#!/bin/bash

# echo "Entrez le nom de votre groupe de ressource"
# read RESSOURCEGROUP
# echo "Entrez le nom de votre reseau"
# read NETWORK
# echo "Entrez le nom de votre (vos si vous en avez plusieurs elles s'appeleront ) machine virtuelle"
# read VMNAME 
# echo "Entrez le nom de l'utilisateur de VM"
# read ADMINVM
# echo "Entrez le nom du service base de données Mariadb"
# read MARIADBNAME
# echo "Entrez le nom de l'administrateur MariaDB"
# read ADMINMARIADB
# echo "Entrez le mot de passe MariaDB"
# read MARIADBPASS
RESSOURCEGROUP=groupe_2Brief_wordpressLBCDSM
NETWORK=reseau_groupe2_brief_wordpress_CDSM
VMNAME=VMCDSM
VMPASSWORD=VmMot2P@ssecdsm
ADMINVM=camilledesousamathieu
MARIADBNAME=MariaDBCDSM
ADMINMARIADB=CDSMMariaDB
MARIADBPASS=Mot2passe
SUBNET=cdsmsousreseau
LOCATION=eastus
IPCDSM=ipcdsm
DNSLABEL=DnsCDSM
LOADBALANCER=cdsmLoadBalancer
IPFRONTEND=cdsmipFrontEnd
BACKLENDPOOL=cdsmBackEndPool
HEALTHPROBE=cdsmHealthProbe
HTTPRULE=cdsmHTTPRule
NSG=cdsmNSG
IPNAT=Ipnatcdsm
NAT=cdsmNATgateway
NIC=cdsmNic
SSHRULE=cdsmSSHRule


echo "Création du groupe de ressources"
az group create -l $LOCATION -n $RESSOURCEGROUP

echo "Création du réseau"
az network vnet create \
    --resource-group $RESSOURCEGROUP \
    --location $LOCATION \
    --name $NETWORK \
    --address-prefixes 10.1.0.0/16 \
    --subnet-name $SUBNET \
    --subnet-prefixes 10.1.0.0/24

echo "Création IP publique"
az network public-ip create \
    --resource-group $RESSOURCEGROUP \
    --name $IPCDSM \
    --sku Standard \
    --zone 1 2 3

echo "création IP pour Nat"
az network public-ip create \
    --resource-group $RESSOURCEGROUP \
    --name $IPNAT \
    --sku Standard \
    --zone 1 2 3

echo "Création d'une ressource passerelle NAT"
az network nat gateway create \
    --resource-group $RESSOURCEGROUP \
    --name $NAT \
    --public-ip-addresses $IPNAT \
    --idle-timeout 10


echo "Association une passerelle NAT au sous-réseau"
az network vnet subnet update \
    --resource-group $RESSOURCEGROUP \
    --vnet-name $NETWORK \
    --name $SUBNET \
    --nat-gateway $NAT

echo "Création de l'équilibreur de charges"
az network lb create \
    --resource-group $RESSOURCEGROUP \
    --name $LOADBALANCER \
    --sku Standard \
    --public-ip-address $IPCDSM \
    --frontend-ip-name $IPFRONTEND \
    --backend-pool-name $BACKLENDPOOL

echo "Création Sonde d'intégrité"
az network lb probe create \
    --resource-group $RESSOURCEGROUP \
    --lb-name $LOADBALANCER \
    --name $HEALTHPROBE \
    --protocol tcp \
    --port 80

echo "Création Règle équilibreur de charges"
az network lb rule create \
    --resource-group $RESSOURCEGROUP \
    --lb-name $LOADBALANCER \
    --name $HTTPRULE \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 80 \
    --frontend-ip-name $IPFRONTEND \
    --backend-pool-name $BACKLENDPOOL \
    --probe-name $HEALTHPROBE \
    --disable-outbound-snat true \
    --idle-timeout 15 \
    --enable-tcp-reset true


echo "Création groupe de sécurité réseau"
az network nsg create \
    --resource-group $RESSOURCEGROUP \
    --name $NSG

echo "Création règle de groupe de sécurité réseau"
az network nsg rule create \
    --resource-group $RESSOURCEGROUP \
    --nsg-name $NSG \
    --name $HTTPRULE \
    --protocol '*' \
    --direction inbound \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 80 \
    --access allow \
    --priority 300
az network nsg rule create \
    --resource-group $RESSOURCEGROUP \
    --nsg-name $NSG \
    --name $SSHRULE \
    --protocol '*' \
    --direction inbound \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 22 \
    --access allow \
    --priority 200

echo "Création une interface réseau"
for (( i=1; i<=2; i++ ))
do  
echo "La valeur est $i"
NICI=$NIC$i
az network nic create -g $RESSOURCEGROUP --vnet-name $NETWORK --subnet $SUBNET -n $NICI --network-security-group $NSG
done
echo "La boucle for est terminée "

echo "Création de la ou des VM"
for (( i=1; i<=2; i++ ))
do  
echo "La valeur est $i"
VMNAMEAVECI=$VMNAME$i
NICI=$NIC$i
  az vm create \
    --resource-group $RESSOURCEGROUP \
    --name $VMNAMEAVECI \
    --admin-username $ADMINVM \
    --admin-password $VMPASSWORD \
    --nics $NICI \
    --image Debian:debian-11:11-gen2:0.20220503.998 \
    --authentication-type password \
    --zone $i \
    --generate-ssh-keys \
    --no-wait
    az network nic ip-config address-pool add \
        --address-pool $BACKLENDPOOL \
        --ip-config-name ipconfig1 \
        --nic-name $NICI \
        --resource-group $RESSOURCEGROUP \
        --lb-name $LOADBALANCER
done
echo "La boucle for est terminée "

echo "Création du serveur MariaDB"
az mariadb server create -l $LOCATION -g $RESSOURCEGROUP -n $MARIADBNAME -u $ADMINMARIADB -p $MARIADBPASS --sku-name GP_Gen5_2

