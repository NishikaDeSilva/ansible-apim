#!/bin/bash

set -o xtrace; set -e

WUM_USER=$1
WUM_PASS=$2

AWS_ACCESS_KEY=$3
AWS_SECRET_KEY=$4

PRODUCT="wso2am"
VERSION="2.1.0"

WORKSPACE=$(pwd)
echo $WORKSPACE

# install aws
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws --version

aws configure set aws_access_key_id $AWS_ACCESS_KEY
aws configure set aws_secret_access_key $AWS_SECRET_KEY

#install wum 
wget -q http://product-dist.wso2.com/downloads/wum/3.0.6/wum-3.0.6-linux-x64.tar.gz
tar -C /usr/local -xzf wum-3.0.6-linux-x64.tar.gz
export PATH=$PATH:/usr/local/wum/bin

which wum

wum init -u $WUM_USER -p $WUM_PASS

# add product
wum add $PRODUCT-$VERSION -y

cp $HOME/.wum3/products/$PRODUCT/$VERSION/$PRODUCT-$VERSION.zip $WORKSPACE/ansible-apim/files/packs/$PRODUCT-$VERSION.zip

# install ansible
if !which ansible; then 
    apt update
    apt install software-properties-common -y
    apt-add-repository --yes --update ppa:ansible/ansible
    apt install ansible -y
fi

wget -q https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u252-b09/OpenJDK8U-jdk_x64_linux_hotspot_8u252b09.tar.gz -P $WORKSPACE/ansible-apim/files/lib
wget -q https://download.jar-download.com/cache_jars/mysql/mysql-connector-java/5.1.49/jar_files.zip
unzip -q jar_files.zip -d $WORKSPACE/ansible-apim/files/lib