# Para qué vamos a usar contenedores?

- Para desplegar aplicaciones comerciales, cuyos desarrolladores nos hayan proporcionado una imagen de contenedor.
  - Tanto en entornos locales       (docker)
  - Como en entornos de producción  (kubernetes)
  Ejemplo: Desplegar una BBDD, un servidor de apps, un indexador...
  Estos contenedores tendrán duración en el tiempo (lo que corren son servicios)
- Disponer de un entorno con una serie de programas (comandos) disponibles, que usaremos para ejecutar TAREAS PUNTUALES
  Ejemplo: Disponer de un entorno con una versión concreta de JAVA / MAVEN para trabajar
            Disponer de un entorno con JMeter para hacer pruebas de carga
            Disponer de un entorno con Selenium para hacer pruebas de sistema
    - Esto nos puede ser útil tanto en entornos locales como en entornos de producción
      - En algunas ocasiones vamos a usar contenedores con Docker en entornos de producción
  Estos contenedores no van a tener una gran duración en el tiempo (lo que corren son comandos / scripts) 
  En este caso, es útil ese comando "docker run", normalmente acompañado de un parámetro "--rm" para que el contenedor se borre cuando termine de ejecutarse.
- Para entregar nuestra aplicación. En este caso, generaremos nuestra propia imagen de contenedor, que contendrá nuestra aplicación.

---

# Carrefour                                                                     = CLUSTER DE KUBERNETES

    Carnicería:                                                                     Servicio
       Mostrador
            Puestos de trabajo:                                                     POD/Contenedor
                Carne                                                                   Datos
                Tabla para cortar carne                                                 RAM
                Báscula
                Cuchillos                                                               CPU
                Carnicer@                                                               Proceso
            Expositor refrigerado                                                   Volumen de almacenamiento (RAPIDO)
        Cámara frigorífica                                                          Volumen de almacenamiento (LENTO)
        Sacar numerito / Pantalla de turnos                                         IP de Balanceo de Carga
    Frutería:
    Pescadería:
    Cajas:
        Fila única -> Pantallita que me manda a una caja u otra
        Lineas de caja                                                              Máquina / Nodo (Recursos)
            Cintas transportadoras
                Supervidor/Profesor                                                 Proceso/Contenedor sidecar \
                v                                                                     v                         > Pod
            Cajer@                                                                  Proceso/Contenedor         /
            Caja registradora
    Carteles: 
        Carnicería ->                                                               Ingress (Regla de configuración de proxy reverso)
        Pescadería <-
    Puerta de entrada                                                               IngressController (Proxy reverso)
        Guarda de seguridad                                                         NetworkPolicy (Reglas de firewall)
    Puerta de entrada para mercancías
    Puerta de entrada para empleados
    Gerente de la tienda                                                            Kubernetes (El que gestiona todo)
        Conseguir gente nueva para hacer un trabajo concreto:
            Para alguien que vaya a trabajar en la carnicería exigiré:              Imagen de contenedor
                - Carnet de manipulador de alimentos
                - Conocimientos de corte de carne

## Configurar kubernetes

Una cosa es instalar un cluster de kubernetes... que lo haremos en el curso.
Y otra cosa, irle diciendo al cluster de kubernetes cómo queremos que opere ese entorno de producción (cluster).

Una ventaja de kubernetes es que nos permite utilizar un lenguaje declarativo a la hora de comunicarnos con él.
Lo que vamos a hacer es configurar programas dentro de kubernetes.
Cuando hablo de programas no me refiero a Temis.
Me refiero a un programa que voy a montar para que despliegue Temis dentro de kubernetes!

Antiguamente este tipo de cosas también las hacíamos con scripts: .sh .bat .ps1 .py

### Lenguaje declarativo

Toda la configuración la haremos mediante archivos YAML. No hay otra forma de hacerla.
Hay una consola gráfica oficial (no incluida en la instalación básica de kubernetes) que permite hacer algunas cosas contra el cluster.
NO SE USA NUNCA PARA NADA, mas que para ojear el cluster!

En esos archivos vamos a declarar los estados / objetos que quiero en el cluster. Kubernetes es quien se encarga de llegar a ese estado.

De forma estándar, Kubernetes lleva unos 30 objetos definidos.... pero permite añadir más tipos de objetos (CRD: Custom resource definition)
Podemos instalar nuevos objetos en el cluster, y luego usarlos en nuestros archivos YAML.

Eso por ejemplo es una de las cosas que hace Openshift: Distribución de Kubernetes de la gente de REDHAT
    Darnos más tipos de objetos que configurar en el cluster de kubernetes.

Y es que hay un huevo de distribuciones de kubernetes:
- K8S
- K3S
- Openshift     La distro de kubernetes de REDHAT       ** DE PAGO
- Tanzu         La distro de kubernetes de VMWare
- AKS           La distro de kubernetes de Microsoft
- GKE           La distro de kubernetes de Google

Cada objeto lo voy a definir en un documento YAML.
Para un despliegue típico de kubernetes (TEMIS) necesitaré configurar unos 10-15 documentos yaml.
---
# Documento típico YAML en Kubernetes
```yaml
apiVersion: libreria/version        # Esta será la librería donde se define el objeto:
kind:       tipo_de_objeto          # Este será el tipo de objeto que voy a definir: Pod, Service, Ingress, Namespace, PersistentVolume,

metadata:                           # Metadatos del objeto
  name:       nombre_del_objeto     # Nombre del objeto / ID del objeto (en la mayoría de los casos, ese nombre no se puede repetir para el mismo tipo de objeto dentro del mismo NAMEspace)
  namespace:  nombre_del_namespace  # Namespace donde se va a crear el objeto / NO LO HACEMOS NUNCA (salvo muy gloriosas excepciones)
  labels:                           # Etiquetas que voy a usar para identificar el objeto
    - nombre: valor
    - nombre: valor
    - nombre: valor

spec:                               # Especificación del objeto
    # Lo que va aquí dentro ya depende del tipo de objeto que estemos definiendo
```
---

# Paradigmas de programación

- Imperativo            Donde pongo un comando/sentencia/tarea detrás de otro. IF/ELSE/FOR/WHILE
- Procedural            Cuando el lenguaje me permite definir funciones y ejecutarlas
- Funcional             Cuando el lenguaje me permite que variables apunten a funciones, y ejecutar las funciones desde las variables
- Orientado a objetos   Cuando el lenguaje me permite definir mis propios tipos de datos con sus métodos y propiedades

- Declarativo           Cuando el lenguaje me permite definir un estado final, y el lenguaje se encarga de llegar a ese estado final

El lenguaje imperativo me hace olvidar mi objetivo, y centrarme en lo que alguien debe hacer para llegar a mi objetivo
El lenguaje Declarativo me invita a centrarme en mi objetivo, y olvidarme de cómo llegar a él.
Toda la comunicación con kubernetes se realiza mediante lenguaje declarativo...
Todas lasa herramientas de software / lenguajes / frameworks que hoy en día están de moda/triunfando lo hacen precisamente por usar
un paradigma de programación declarativo: 
- Docker-compose
- Kubernetes
- Ansible
- Terraform
- Spring Boot
- Angular

```properties
# Spring app file. 
# Databse connection properties
spring.datasource.url=jdbc:postgresql://localhost:5432/postgres
spring.datasource.username=postgres
spring.datasource.password=postgres
spring.datasource.driver-class-name=org.postgresql.Driver
```

```yaml 
# Spring app file. 
# Databse connection properties
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/postgres
    username: postgres
    password: postgres
    driver-class-name: org.postgresql.Driver
```

---

# Aquitectura de un cluster de kubernetes

En un entono de producción un cluster de kubernetes tendrá al menos 5 nodos.
Kubernetes no es un programa... Realmente son un montón de programas que se comunican entre sí.
Algunos de esos programas se instalan a hierro en las máquinas que forman el cluster.
Otros se instalan como contenedores dentro del propio cluster. Estos programas forman lo que llamamos el "plano de control" de kubernetes.
El plano de control de un cluster de producción debe tener al menos 3 nodos.... y esto es debido a qué una de las apps que forman parte de kubernetes necesita al menos 3 replicas para ofrecer la alta disponibilidad que necesitamos en un entorno de producción: ETCD

En general todas las herramientas de almacenamiento de datos (bbdd, sistemas de mensajería -kafka, indexadores -elastic, etc) necesitan un número impar de nodos (>=3) para ofrecer alta disponibilidad. Esto se hace para que al elegir uno de ellos como maestro pueda haber una votación con mayorías... y evitar un gran problema que puede ocurrir en caso contrario: Split Brain

Al menos necesitaré 2 nodos adicionales para carga de trabajo (mis aplicaciones)
En los nodos del plano de control NO es recomendable desplegar aplicaciones de usuario. Se reservan para las apps de kubernetes.

Herramientas del plano de control de kubernetes:

- ETCD: Base de datos de clave/valor distribuida. Almacena la configuración de kubernetes. Necesita al menos 3 nodos para ofrecer alta disponibilidad.
- ApiServer: Servidor de API REST. Es el que recibe las peticiones al cluster.
- ControllerManager: Es el que se encarga de gestionar los recursos del cluster. 
  - Es el que se encarga de que los nodos estén en el estado que deben estar.
  - El que monitoriza los nodos y los pods.
- CoreDNS: DNS interno al cluster de kubernetes.
- Scheduler: Es el que se encarga de decidir en que nodo se va a desplegar cada pod.
- Plugins de red: va a crear una red virtual a la que conectar los pods. 
  - Docker crea su propia red virtual dentro del host. Eso en Kubernetes no funciona.
  - En kubernetes los pods deben tener comunicación entre si... a pesar de estar en diferentes nodos.
  - Necesitamos una red virtual montada sobre la red física de la máquina.
  - Hay un montón de proveedores (plugins) que nos ayudan a montar esas redes virtuales. Los 2 más usqados son:
     - Calico:  Es un poquito más complejo, pero es el que más se usa en producción: Rendimiento + Funcionalidad
     - Flannel: Se instala muy sencillo... pero tiene poca funcionalidad

Fuera del cluster hará falta montar adicionalmente:
- Un gestor de contenedores: crio / containerd
- kubelet: Es un servicio el que se encarga de gestionar los contenedores en cada nodo. Más propiamente, es el que se encarga de hablar con el gestor de contenedores local.
- kube-proxy: Es el que se encarga de gestionar las reglas de red en cada nodo. 
- kubeadm: Es el que se encarga de gestionar el cluster de kubernetes:
  - Crear el cluster
  - Añadir nodos al cluster. Cada nodo solicita ser añadido a un cluster ... y en todos los nodos necesitamos esta herramienta para añadirlos al cluster.

En alguna máquina (normalmente externa al cluster), montaremos kubectl: Es la herramienta que nos permite comunicarnos con el cluster de kubernetes. CLIENTE DE KUBERNETES:

    Docker      Kubernetes
    dockerd     apiServer
       ^           ^
    docker      kubectl

# Instalación de kubernetes

Maquina 1: Será una máquina del plano de control
Instalaremos:
- crio
- kubelet
- kubeadm
- kubectl

Después solicitaremos a kubeadm que cree un cluster de kubernetes en esta máquina:
- Descargará las imagenes de los contenedores de los pods del plano de control (apiServer, etcd, coredns, controllerManager, scheduler...)
- Crea contenedores y los arranca
- En este momento ya tendremos cluster

Posteriormente con kubectl crearemos los objetos que gestionen la RED Virtual de kubernetes

Maquina 2... Máquina N
- crio
- kubelet
- kubeadm

con kubeadm añadiremos la máquina al cluster de kubernetes
Algunas de estas máquinas las etiquetaremos como "nodos del plano de control" y esos nodos será gestionados y usados por el propio kubernetes para despliegue del plano de control con HA (replicas de pods del plano de control)

Una vez hecho esto, comenzaremos a crear configuraciones/objetos dentro de kubernetes , para que KUBERNETES empiece a gestionar nuestro cluster.
Lo haremos mediante ficheros YAML que pasaremos al cluster con el kubectl 

---

# Objetos que vamos a tener que aprender a configurar en kubernetes

- Namespace                     Entornos lógicos de trabajo
- Node                          Máquinas
- Pods                          Contienen los contenedores que ejecutan nuestras aplicaciones
- Plantillas de pods
  - Deployments
  - StatefulSets
  - DaemonSets
- Jobs                          Contienen contenedores... one shot (que ejecutan tareas simples: Backup de la BBDD)
- Plantilla de Jobs:
  - CronJobs
- Services                      IP de Balanceo de carga
  - ClusterIP
  - NodePort    
  - LoadBalancer    
- Ingress                       Reglas de proxy reverso
- PersistentVolume              Está muy claro
- PersistentVolumeClaim         Peticiones de almacenamiento
- ConfigMap                     Configuraciones editables de las apps (al cambiar la app de entorno)
- Secret                        Similar pero encritado
- HorizontalPodAutoscaler       Escaladores de pods
--------------^ DESARROLLO DE SOFTWARE ^-----------------
- NetworkPolicy                 Reglas de firewall (hablaremos poco)
- ResourceQuota
- LimitRange
- ServiceAccount

---

Un cluster de kubernetes no es solo instalar eso de ahí...
Encima de eso . nos hará falta instalar más cosas:
- Metric Server: Es el que se encarga de recoger las métricas de los pods y los nodos (Sin ésto no funciona el autoescalado de pods)
- Dashboard: Es una consola gráfica para ver el estado del cluster  
- Provisionador de almacenamiento: Es el que se encarga de crear los volúmenes de almacenamiento dinámicamente en el cluster:
  - NFS
  - Cabina fibra-optica (LUN)
  - Ceph
- Un IngressController: Es el que se encarga de gestionar las reglas de proxy reverso en el cluster de kubernetes
- Si trabajamos en un cluster local (no en un cloud), adicionalmente necesitaremos un balanceador de carga externo al cluster compatible con kubernetes: MetalLB
- DNS externo al cluster. Podemos queres que se autoconfigure por kubernetes -> Despliegue / Operador
- Certificados(https). Solemos montar un gestor de certificados en el cluster de kubernetes: CertManager
- Istio? Service mesh

- Monitorización de las apps - Logs -> Prometheus / Grafana
                                    -> EFK (ElasticSearch / FluentD / Kibana) 

Introduccion a la contenedorización: 25 horas: DOCKER + IMAGENES DE DOCKER
Introduccion a Kubernetes: 30 horas
Administración: 25 horas
ISTIO: 30 horas (1 hora) / Linkerd
Helm: 30 horas (2 horas)
