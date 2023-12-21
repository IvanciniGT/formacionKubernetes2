#!/bin/bash

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.6/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.6/manifests/metallb.yaml

kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

. ./configuracionlb.properties

cat <<EOF > ./metallb-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - $LOAD_BALANCER_IP_POOL
EOF

kubectl apply -f ./metallb-config.yaml

if [[ $( kubectl get pods -n metallb-system | grep -c Running ) == 2 ]]
then
    echo INFO. Metallb instalado correctamente.
else
    echo ERROR. No se he podido instalar Metallb correctamente.
fi