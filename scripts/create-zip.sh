#!/usr/bin/env bash
set -o xtrace; set -e;
PRODUCT_PATH=$PWD
echo "--->PATH<--- : $PRODUCT_PATH"
platform="api-manager"
params_file="ansible-params.json"

parent_repo=$(jq -r '.platforms[] | select( .name == '\"${platform}\"') | .git_repo.parent' ${params_file} )
repo=$(jq -r '.platforms[] | select( .name == '\"${platform}\"') | .git_repo.name' ${params_file} )
branch=$(jq -r '.platforms[] | select( .name == '\"${platform}\"') | .git_repo.branch' ${params_file} )

git clone "https://github.com/${parent_repo}/${repo}" && git checkout ${branch} 

# add dependencies

curl -L $(jq -r '.common.jdk_download_link' ${params_file}) --create-dirs -o ${repo}/files/lib/jdk-distribution.tar.gz
mkdir -p trash dir && wget $(jq -r '.common.jdbc_download_link' ${params_file}) -P trash/
unzip -qd dir/ trash/*
jar_file_location=$(find dir -name '*bin.jar') && mv ${jar_file_location} ${repo}/files/lib/db-connector-java.jar

rm -r trash dir

#add products to files/packs/
products=$(jq -r '.platforms[] | select( .name == '\"${platform}\"') | .products' ${params_file})

for row in $(echo "${products}" | jq -r '.[] | @base64')
do
  _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }

  product_name=$(_jq '.name')
  product_version=$(_jq '.version')
  product_zip="${product_name}-${product_version}.zip"

  #mkdir -p ${repo}/files/packs && cp ~/.wum3/products/${product_name}/${product_version}/${product_zip} ${repo}/files/packs/
  mkdir -p ${repo}/files/packs && cp $PRODUCT_PATH/${product_name}/${product_version}/${product_zip} ${repo}/files/packs/

done

zip -qr ${repo}.zip ${repo}/*
