#!/bin/bash

# servicename=$1, imagetag=$2, input template=$3, config_file=$4

homeloc=`pwd`
cd $homeloc;
copyloc="$homeloc/$3"
echo "Copy Folder Location : " $copyloc;
orgloc="$homeloc/$1"
echo "Folder Location : " $orgloc;

# 1. helm create service-name
helm create $1

# 2. copy from replica service service.yaml, deployment.yaml, configmap.yaml, NOTES.text
cp -rf $copyloc/templates/deployment.yaml $orgloc/templates/
cp -rf $copyloc/templates/configmap.yaml $orgloc/templates/
cp -rf $copyloc/templates/NOTES.txt $orgloc/templates/
cp -rf $copyloc/templates/service.yaml $orgloc/templates/

cp -rf $copyloc/Chart.yaml  $orgloc/
cp -rf $copyloc/values.yaml  $orgloc/

echo "Current location: $(pwd)"

# 3. remove files hpa.yaml, ingress.yaml, serviceaccount.yaml
rm -rf $orgloc/templates/hpa.yaml
rm -rf $orgloc/templates/ingress.yaml
rm -rf $orgloc/templates/serviceaccount.yaml


# 4. change config value in configmap.yaml, values.yaml

./config.sh $1 $orgloc $4
./removeline.sh $1 $orgloc

# replace file name
echo "Current location: $(pwd)"

find ./$1 -type f -exec sed -i -e 's/cashinpostingcbsmta/'$1'/g' {} \;

# change images tag 
sed -i 's/1234567890/'$2'/g' $orgloc/values.yaml

# 7. helm template service-name
helm template $1

helm package $1

helm registry login registry.preprod.finopaymentbank.in --username admin --password redhat --insecure

helm push $1-1.0.0.tgz oci://registry.preprod.finopaymentbank.in/p2mpayhelm --insecure-skip-tls-verify

