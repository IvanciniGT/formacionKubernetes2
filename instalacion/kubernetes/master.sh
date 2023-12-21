# Crear un cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Preparamos la configuración del cliente: kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# A partir de aqui ya puedo usar kubectl

# Nos falta por montar ahora la RED VIRTUAL DEL CLUSTER.
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Listo !

# En nuestro caso... que estamos montando un cluster de juguete
# kubectl taint nodes --all node-role.kubernetes.io/master-
# Esto nunca lo haríamos en un entorno de producción

#kubeadm token create --print-join-command
# kubeadm reset

#            Service mess !!!!
#ISTIO                VV
#Linkerd     Service Mesh ;)

#TLS:
#    Man in the middle <<<<
#    Phishing