#!/bin/bash

function crearVolumen(){
    NOMBRE=$1
    CLASSNAME=$2
    STORAGE=$3
    VOLUMEPATH=$4

    cat << EOF | kubectl apply -f -
    kind: PersistentVolume
    apiVersion: v1
    metadata:
        name: $NOMBRE 
    spec:
        storageClassName: $CLASSNAME
        capacity:
                storage: $STORAGE
        accessModes:
            - ReadWriteOnce
        hostPath:
            path: $VOLUMEPATH
            type: DirectoryOrCreate
EOF
}

while [[ $# != 0 ]];
do
    case $1 in
      -n|--name)
          NOMBRE=$2
          ;;
      -c|--classname)
          CLASSNAME=$2
          ;;
      -s|--storage)
          STORAGE=$2
          ;;
      -p|--path)
          VOLUMEPATH=$2
          ;;
      *)
        echo Error... parametro no soportado.
        echo Los parametros disponibles son:
        echo "  -n|--name"
        echo "  -c|--classname"
        echo "  -s|--storage"
        echo "  -p|--path"
        exit 1
    esac
    shift
    shift
done;

kubectl delete pv $NOMBRE
mkdir -p $VOLUMEPATH
sudo chmod 777 -R $VOLUMEPATH
crearVolumen $NOMBRE $CLASSNAME $STORAGE $VOLUMEPATH
