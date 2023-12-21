# Desactivar swap

sudo swapoff -a
sudo vi /etc/fstab # Comentar la linea de swap
free

# Instalar dependencias de CRIO
sudo apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common -y
sudo su -

# Hay que activar un par de modulos en el kernel de Linux
#  (root) -> 644
echo "overlay
br_netfilter" > /etc/modules-load.d/k8s_crio.conf

export OS=xUbuntu_22.04
export CRIO_VERSION=1.27
export kubernetes_version=1.28.0

curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -


echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"| sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list
apt update

apt install cri-o cri-o-runc -y
apt install cri-tools -y

echo "net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-ip6tables=1" > /etc/sysctl.d/k8s_crio.conf
sysctl -p  /etc/sysctl.d/k8s_crio.conf


systemctl enable crio
systemctl restart crio
systemctl status crio
crictl info

exit # Salir de root
# Instalacion de kubernetes
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update

## A instalar

sudo apt install kubelet kubeadm kubectl  -y

### HASTA AQUI LO HARIAMOS EN TODAS LAS MAQUINAS DEL CLUSTER

# Lo que viene ahora solo en 1 de los maestros
sudo kubeadm init --pod-network-cidr "10.10.0.0/16" --upload-certs

# Este comando va a montar un monton de pods con contenedores que contienen los proigramas básicos de kubernetes
# Pero aún no tenemos creada una red virtual de kubernetes.
# En qué red los pincha? Se hace un truco... le indicamos IPS de las que tendremos en el futuro en la red virtual que vamos a crear
# La red virtual la crean nuevos pods que montaremos mas adelante dentro del cluster

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Permitir que en los nodos del plano de control se puedan desplegar aplicaciones que no sean del plano de control: WP
# ESTO SOLO SERIA EN ENTORNOS DE PRUEBA
kubectl taint nodes node-role.kubernetes.io/control-plane:NoSchedule- --all

# Montar red virtual: CALICO
# Montar dashboard
# Mostar metric-server

# Montar WP/mariadb