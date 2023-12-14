# Comunicaciones dentro (y fuera) de un cluster de kubernetes

        :80
            http://172.30.10.10:30080, http://172.30.10.20:30080, 
            http://172.30.10.30:30080, http://172.30.10.80:30080                temis.cabot.es -> 172.30.0.100
        ^^^                                                                     ^
    Balanceador de carga (HAProxy, Nginx, Apache httpd, envoy)        DNS Externo al cluster
        |                                                               |                      
    172.30.0.100                                                    172.30.0.101
        |                                                               |
-------------------------------------------------------------------------------------------- Red de cabot (172.30.0.0/16)
|                                                                                   |
|                                                                               172.30.0.200
|                                                                                   |
|                                                                               Federico PC [DNS publico de mi empresa o incluso externo]
|                                                                                   http://172.30.0.100 
|== 172.30.10.80 -- Maquina 0 de Kubernetes (cp)      Kernel Linux - NetFilter
||                                 |-- kubeproxy                     >     20.0.0.1:3307 -> 10.0.0.2:3306
||                                 |                                 >     20.0.0.2:8080 -> 10.0.0.1:80,10.0.0.3:80
||                                 |                                 >     20.0.0.3:80   -> 10.0.0.5:80
||                                 |                                 >     172.30.10.80:30080 -> ingress:8080
||                                 |
||                                 |-- 10.0.0.100 -- Pod CoreDNS
||                                 |                   \ Contenedor CoreDNS
||                                 |                            bbdd-wp -> 20.0.0.1
||                                 |                            mi-web  -> 20.0.0.2
||                                 |                            ingress -> 20.0.0.3
||                           Red virtual de Kubernetes (10.0.0.0/8)
||
|== 172.30.10.10 -- Maquina 1 de Kubernetes (trabajador)      Kernel Linux - NetFilter
||                       |         |-- kubeproxy                     >     20.0.0.1:3307 -> 10.0.0.2:3306
||                       |         |                                 >     20.0.0.2:8080 -> 10.0.0.1:80,10.0.0.3:80
||                       |         |                                 >     172.30.10.10:30080 -> ingress:8080 (-> 20.0.0.2:8080)
||                       |         |                                 >     20.0.0.3:80   -> 10.0.0.5:80
||                       |         |
||                       |         |-- 10.0.0.1 -- Pod Wordpress App - [ DNS-> CoreDNS ]
||                       |         |                   \ Contenedor Apache/WP (-e WORDPRESS_DB_HOST=bbdd-wp)    :80
||                       |         |
||                       |         |-- 10.0.0.5 -- Pod nginx - [ DNS-> CoreDNS ] HACE DE PROXY REVERSO <- IngressController
||                       |         |                   \ Contenedor nginx:80
||                       |         |                            http://temis.cabot.es:80 -> mi-web:8080  <-- INGRESS (Regla de proxy reverso)
||                 127.0.0.1       |
||                       |    Red virtual de Kubernetes (10.0.0.0/8)
||                       |             
||                   loopback (127.0.0.0/8)
||
|== 172.30.10.20 -- Maquina 2 de Kubernetes (trabajador)      Kernel Linux - NetFilter
||                                 |-- kubeproxy                     >     20.0.0.1:3307 -> 10.0.0.2:3306
||                                 |                                 >     20.0.0.2:8080 -> 10.0.0.1:80,10.0.0.3:80
||                                 |                                 >     172.30.10.20:30080 -> ingress:8080
||                                 |                                 >     20.0.0.3:80   -> 10.0.0.5:80
||                                 |
||                                 |-- 10.0.0.2 -- Pod Wordpress BBDD - [ DNS-> CoreDNS ]
||                                 |                    \ Contenedor MariaDB : 3306
||                                 |
|== 172.30.10.30 -- Maquina 3 de Kubernetes (trabajador)      Kernel Linux - NetFilter
||                                 |-- kubeproxy                     >     20.0.0.1:3307 -> 10.0.0.2:3306
||                                 |                                 >     20.0.0.2:8080 -> 10.0.0.1:80,10.0.0.3:80
||                                 |                                 >     172.30.10.30:30080 -> ingress:8080
||                                 |                                 >     20.0.0.3:80   -> 10.0.0.5:80
|                                  |
|                                  |-- 10.0.0.3 -- Pod 2 Wordpress App - [ DNS-> CoreDNS ]
|                                  |                   \ Contenedor Apache/WP (-e WORDPRESS_DB_HOST=bbdd-wp)  : 80
|                                  |
|                             Red virtual de Kubernetes (10.0.0.0/8)
|

NetFilter? esto es un modulo (programa) que hay dentro del kernel de Linux, que se encarga de procesar todos los paquetes de red.
      ^
    iptables

Para conseguir que Kubernetes haga esto, hemos de configurar en Kubernetes un SERVICIO:
Qué es un Service (de tipo CLUSTERIP) de Kubernetes?    Entrada en el DNS interno de Kubernetes que apunta a una IP de balanceo de carga,
                                                        que kubernetes mantiene actualizada para balancear entre uno o varios pods.
                                                        Estos servicios SOLO Sirven para comunicaciones internas en el cluster

                NOMBRE: 'bbdd-wp' que balancee entre pods del TIPO: 'Wordpress BBDD',
                cuando se usa el puerto 3307, llevandome al pod al puerto 3306
                ```yaml

                apiVersion: v1                   # La libreria y la versión de esa librería que define ese tipo de objeto
                                                 # En general tiene la sintaxis:             nombre_libreria/version
                                                 # Los objetos básicos de kubernetes están en la 
                                                 # librería básica (no tiene nombre) ... solo indicaremos la versión
                kind: Service                    # Tipo de objeto que quiero configurar en Kubernetes

                metadata:
                    name: bbdd-wp                # Nombre con el que identifico al objeto... 
                                                 # que en el caso de servicios es además el nombre que se da de alta en el DNS

                spec:                            # Especificación del objeto que quiero crear. Depende del tipo de objeto que esto configurando 
                    selector:
                        app: wordpress-bbdd
                    ports:
                        - protocol: TCP
                          port: 3307
                          targetPort: 3306
                    type: ClusterIP             # Por defecto, un servicio es de tipo ClusterIp
                ---
                ```yaml

Qué es un Service (de tipo NODEPORT) de Kubernetes?    Servicio CLUSTER IP + exposición de puerto a nivel de los hosts

                NOMBRE: 'mi-web' que balancee entre pods del TIPO: 'Wordpress App',
                cuando se usa el puerto 8080, llevandome al pod al puerto 80,
                Oye... y de paso... abre también un puerto (por encima del 30000) en TODOS los host de kubernetes, de forma
                que se si hace una petición a ese puerto, en cualquier IP del host, me lleve al servicio en su Puerto

                ```yaml

                apiVersion: v1                   # La libreria y la versión de esa librería que define ese tipo de objeto
                                                 # En general tiene la sintaxis:             nombre_libreria/version
                                                 # Los objetos básicos de kubernetes están en la 
                                                 # librería básica (no tiene nombre) ... solo indicaremos la versión
                kind: Service                    # Tipo de objeto que quiero configurar en Kubernetes

                metadata:
                    name: mi-web                 # Nombre con el que identifico al objeto... 
                                                 # que en el caso de servicios es además el nombre que se da de alta en el DNS

                spec:                            # Especificación del objeto que quiero crear. Depende del tipo de objeto que esto configurando 
                    selector:
                        app: wordpress-app
                    ports:
                        - protocol: TCP
                          port: 8080
                          targetPort: 80
                          nodePort: 30080
                    type: NodePort
                ---
                ```yaml


Qué es un Service (de tipo LOADBALANCER) de Kubernetes?    Servicio NodePORT + configuración/gestión automática
                                                           de un balanceador externo COMPATIBLE CON KUBERNETES
                                                                Si trabajamos en un cloud y contrato un cluster de kubernetes, 
                                                                me "regalan" (€€€€) un balanceador de carga externo
                                                                Si no trabajo en un cloud... y tengo mi propio cluster de kubernetes on premise
                                                                Entonces solo hay 1 balanceado de carga compatible con kubernetes: MetalLB

                NOMBRE: 'mi-web' que balancee entre pods del TIPO: 'Wordpress App',
                cuando se usa el puerto 8080, llevandome al pod al puerto 80,
                Oye... y de paso... abre también un puerto (por encima del 30000) en TODOS los host de kubernetes, de forma
                que se si hace una petición a ese puerto, en cualquier IP del host, me lleve al servicio en su Puerto
                Y además, que si hacen una petición en una IP de la red externa, que se mande a uno de los nodos 
                en el puerto ese por encima del 30000 que hayamos configurado.

                ES NECESARIO DISPONER DE UN BALANCEADOR QUE OPERE SOBRE LA RED EXTERNA, PARA OBTENER UNA IP EXTERNA.
                Al configurar ese balanceador (METALLB) le damos un rango de IPs que puede usar para asignar a los servicios:
                    172.30.0.100 - 172.30.0.120

                ```yaml

                apiVersion: v1                   # La libreria y la versión de esa librería que define ese tipo de objeto
                                                 # En general tiene la sintaxis:             nombre_libreria/version
                                                 # Los objetos básicos de kubernetes están en la 
                                                 # librería básica (no tiene nombre) ... solo indicaremos la versión
                kind: Service                    # Tipo de objeto que quiero configurar en Kubernetes
                
                metadata:
                    name: mi-web                 # Nombre con el que identifico al objeto... 
                                                 # que en el caso de servicios es además el nombre que se da de alta en el DNS

                spec:                            # Especificación del objeto que quiero crear. Depende del tipo de objeto que esto configurando
                    selector:
                        app: wordpress-app
                    ports:
                        - protocol: TCP
                          port: 8080
                          targetPort: 80
                          nodePort: 30080
                    type: LoadBalancer

OPENSHIFT, que es la distro de kubernetes de REDHAT si tiene una cosa para configurar el DNS externo:
Router = Servicio LoadBALANCER + Gestión automatizada de un DNS Externo

En Kubernetes hay alternativas, pero que solo funcionan con algunos proveedores de DNS:
    Google, GoDaddy, CloudFlare

---

A la vista de lo que he contado:

Cuántos servicios de cada tipo vamos a tener en un cluster estándar de Kubernetes?

                        %
    ClusterIP           99.99
    NodePort            0
    LoadBalancer        1-2             IngressController
            En ocasiones me interesa más de un IngressController
                IngressController que expone servicios públicos
                IngressController que expone servicios privados: conexión a la BBDD