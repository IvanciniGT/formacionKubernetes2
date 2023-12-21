helm repo add nfs-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/


helm template nfs-provisioner/nfs-subdir-external-provisioner \
    -f nfs-values.yaml \
    -n nfs-provisioner \
    --create-namespace


helm install provisionador-redundante nfs-provisioner/nfs-subdir-external-provisioner \
    -f nfs-values.yaml \
    -n nfs-provisioner \
    --create-namespace
