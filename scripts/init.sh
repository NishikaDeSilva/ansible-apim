#!/bin/bash

set -o xtrace; set -e

WUM_USER=$1
WUM_PASS=$2

PRODUCT=$3
VERSION=$4

WORKSPACE=$(pwd)
echo $WORKSPACE

#install wum 
wget -q http://product-dist.wso2.com/downloads/wum/3.0.6/wum-3.0.6-linux-x64.tar.gz
tar -C /usr/local -xzf wum-3.0.6-linux-x64.tar.gz
export PATH=$PATH:/usr/local/wum/bin

which wum

wum init -u $WUM_USER -p $WUM_PASS

sed -i '0,/https:\/\/api.updates.wso2.com/{s/https:\/\/api.updates.wso2.com/https:\/\/gateway.api.cloud.wso2.com\/t\/wso2umuat/}' $HOME/.wum3/config.yaml
sed -i "s/${WUM_APPKEY_UAT}/${WUM_APPKEY_LIVE}/g" $HOME/.wum3/config.yaml

wum init -u $WUM_USER -p $WUM_PASS

# add product
wum add $PRODUCT-$VERSION -y
wum update $PRODUCT-$VERSION

cp $HOME/.wum3/products/$PRODUCT/$VERSION/full/$PRODUCT-$VERSION*.zip $WORKSPACE/ansible-apim/files/packs/$PRODUCT-$VERSION.zip

# install ansible
apt update
apt install software-properties-common -y
apt-add-repository --yes --update ppa:ansible/ansible
apt install ansible -y

wget -q https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u252-b09/OpenJDK8U-jdk_x64_linux_hotspot_8u252b09.tar.gz -P $WORKSPACE/ansible-apim/files/lib
wget -q https://download.jar-download.com/cache_jars/mysql/mysql-connector-java/5.1.49/jar_files.zip
unzip -q jar_files.zip -d $WORKSPACE/ansible-apim/files/lib