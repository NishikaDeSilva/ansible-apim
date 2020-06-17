#!/bin/bash

WUM_USER=$1
WUM_PASS=$2
PRODUCT="wso2am"
VERSION="2.1.0"

WORKSPACE=$(pwd)
echo $WORKSPACE

#install wum 
wget http://product-dist.wso2.com/downloads/wum/3.0.6/wum-3.0.6-linux-x64.tar.gz
tar -C /usr/local -xzf wum-3.0.6-linux-x64.tar.gz
export PATH=$PATH:/usr/local/wum/bin

which wum

wum init -u $WUM_USER -p $WUM_PASS

# add product
wum add $PRODUCT-$VERSION

cp $HOME/.wum3/products/$PRODUCT/$VERSION/$PRODUCT-$VERSION.zip $WORKSPACE/ansible-apim/files/lib/packs/$PRODUCT-$VERSION.zip

# install ansible
apt update
apt install software-properties-common
apt-add-repository --yes --update ppa:ansible/ansible
apt install ansible

wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u252-b09/OpenJDK8U-jdk_x64_linux_hotspot_8u252b09.tar.gz -P $WORKSPACE/ansible-apim/files/lib
wget https://download.jar-download.com/cache_jars/mysql/mysql-connector-java/5.1.49/jar_files.zip
unzip jar_files.zip -d $WORKSPACE/ansible-apim/files/lib