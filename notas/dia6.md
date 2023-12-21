# Volumes empty dir

Permiten compartir info (ficheros, carpetas) entre contenedores

    JBOSS   - temis
        access.log -> Los accesos al sistema
        server.log -> Los eventos que ocurren
        

Tengo 2 pods con esto, que van a ir generando estos logs.
Después de 1 año de funcionamiento... que va a pasar?
- Los logs se van rotando
    -> La información que hay en ellos, la pierdo
        ME INTERESA ESO?

Los logs son una de las fuentes de información más valiosa que tiene una empresa!


Soy Amazon:
    Tengo 200-300 pods con el servidor de apps y mis microservicios en un dia normalito.
            y cada uno genera sus logs.
            
    Desde el punto de vista de negocio, la información del access_log me permite:
        - Saber en tiempo real:
            - Cuantos usuarios están comprando
            - Qué cosas están mirando
            - Su geoposicionamiento: Cuantos tios tengo en cada pais/provincia
                -> Seguimiento de campañas publicitarias
        HOY, y dentro de un año... para sistema: 
            Cuánta gente se prevee que entre tal día... para ir dimensionandome
    De vez en cuando las apps tendrán problemas, fallos, bugs.
        Que provocarán perdidas/caidas del servidor -> Kubernetes ayuda a levantar aquello rápido.
        Y puedo adelantarme a una condición anómala?
    Tengo 300 ficheros, repartidos en 300 pods, repartidos en 50 servidores físicos que ir monitorizando 
    Por si en guno aparece algún error: OUTOFMEMORY EXCEPTION
    
    POD:
        con soporte en memoria RAM = 300Kbs
    
        Contenedor 1- JBOSS
            Serv. de apps:                                  ElasticSearch < Kibana      SISTEMAS
                server.log 2x100Kbs rotados
                access.log 2x 50kbs rotados                              ^
            Fluentd/filebeat                    > KAFKA > Logstash > Logstash
                                                                |>   Logstash 2
                                                                ElasticSearch < Kibana      NEGOCIO
        Contenedor2- Filebeat (SIDECAR)


# Volumenes persistentes

## PersistentVolume: Representa un volumen de almacenamiento FISICO -> ADM DEL CLUSTER 
    Tipos:  AWS_S3
            AWS_EBS
            AZURE
            GPC
            NFS
            CABINA DE ALMACENAMIENTO - fibra óptica
            iSCSI
            CEPH
            VSPHERE - VMWARE
    Un PV tiene un ID
    
## Petición de Volumen Persistente: PVC - PersistentVolumeClaim -> DESARROLLO

    - 100Gbs, redundanteX3 (por detrás serán 300Gbs), rápido, encriptado
    - 2Tbs, redundantex2, lento, encriptado o no... para backups

Eso si.. al final hay que hacer MATCH

    Los administraadores de un cluster crean volumenes 
        VOL0001, 50 gbs rapidito    (VMWARE)
        VOL0002, 100 gbs    lentito (AWS)
        
    Los desarrolladores piden volumenes
        PV0001, 60Gbs, me da igual la velocidad
        
    Y kubernetes hace MATCH:
        
    Hay algún volumen capaz de satisfacer la PV0001?
        VOL0002 <---> PV0001
        
    El desarrollador en la plantilla de pod, asocia un volumen a una PV: PV0001
    Y Kubernetes hace match, y monta el PV, el volumen en el POD que se crea.
    
    Los PVC y los PV son los que nos dan juego de cara a la High Availability:
        
        Template 1  ------+
        v                 v
        POD1  <------> PVC00001    <--Kub-->        PV000001

        Si un día el pod1, se pudre!
    
                       PVC00001    <--Kub-->        PV000001
                       
        Si kubernetes crea un pod nuevo para reemplazarlo
        
        POD1' <------> PVC00001    <--Kub-->        PV000001
        
Ojo... esto estaría guay... si todos los pods que se generen desde la plantilla comparten volumen.
Por contra si cada pod que se genere de la plantilla necesita su propio volumen:
El procedimiento se complica:
    El desarrollador no hace una PVC = Una petición d volumen
    Lo que hace en su lugar es definir una PLANTILLA DE PVC
    
    Y cada POD que se genere desde la plantilla de POD 
    genera su propia PVC desde la plantilla de PVC 
    
    Y Kubernetes tendrá que hacer match para cada PVC 
    Más vale que hayan dado de alta los administradores del cluster suficientes volumenes PV 
    para satisfacerlas.
    
    Y en general esto es mnás complejo.
    Ya que los sysadmin del cluster no están ahí sentados 24x7 a ver si a algun desarrollador se le ocurre lanzar una PVC.
    Y lo que hacen es configurar un PROVISIONADOR DINAMICO DE VOLUMENES PERSISTENTES
    
    De forma que cada vez que se lanza una PVC, el provisionador genera en automático un PV
    Y Kubernetes le hace MATCH, para que el/los pods que busquen el volumen asociado a la PVC que usen, los encuentren.

# POD
    Volumenes:
        Datos sql-server -> vol 10293735287326473 -> VMWARE
            Esto se puede hacer en kubernetes. NUNCA JAMAS EN LA VIDA LO HARÍAMOS
            
    Cuando defina el POD... realmente lo que voy a definir es una PLANTILLA DE POD
    Con lo cual podré querer que cada POD tenga su propio volumen de almacenamiento
    
    
# Instalación de SQLServer

- Standalone
- Replication       1 maestro / 1 o varias replicas <--- MAESTRO (APP) + REPLICA (BI)
                                                         su HDD         otro HDD
                                                       volumen 1  --->  volumen 2
- Cluster       3 nodos activos sqlserver
            NODO 1          NODO 2          NODO 3
            vol 1           vol 2           vol 3
            A               A               C
            B               C               B

    Al meter 3 nodos mejor teoricamente la carga máxima soportable en un 50% (300%)
        1 nodo atiendo 100 pet/min
        3 nodos conseguiré 150 peticiones/minuto
        
Cada nodo guarda datos diferentes. No todos los datos están en todos los nodos


---

# Capacidades de almacenamiento

18 Gi - Gibibytes = 1024 Mi
18 Gb - Gigabytes = 1000 Mb

Estoy cambio hace más de 20 años.

Antiguamente 1 Gigabyte = 1024 Megabytes
Hace más de 20 años, cambio la cosa... a una nueva nomenclatura, compatible con el SI de medidas

1 Gigabyte = 1000 Mb

---

En el mediamark tiene un HDD de 2 Tbs y otro de 6 Tbs... esos son los que venden

Tu llegas y dices que tienes que guardar 3 Tb

El del media mark que te contesta? Aquí tiene un dico que le sirve.. cuál me da? El de 6 Tbs

---

PASO 1:
Montar un cluster con:

1 NODO MAESTRO / CONTROL-PLANE
2 NODOS TRABAJADORES

Y dentro de ese cluster desplegaría:
- Sonarqube = MUY SENCILLO
    - SQL_Server
-- Jenkins   = MAS O MENOS SENCILLO
- Gitlab    = MUY COMPLEJA          Gitlab CI/CD
                                    Repo de artefactos <
    20-30 pods

---

2 cluster de kubernetes

PRODUCCION
    Jenkins
    SonarQube
        CDeployment
    Temis
    GITLAB ->   12 -> 13 <<< Y ESTE EES EL QUE USO
    
PRUEBAS ^
    Actualizacion de los NODOS
    Jenkins
        CI
        CDeployment
            servicios TEMIS Spring -> Instalar en prod automa.
                v1 -> v2
    SonarQube
    Temis
    GITLAB -> 12-> 13

---

HELM

---

Ya dijimos que no creamos pods en kubernetes, sino que creamos: PLANTILLAS DE PODS:
- Deployments       Plantilla de pod + número de replicas
- StatefulSets      Plantilla de pod + Plantilla de PVC + número de replicas
                        BBDD, Indexador, Sistema de mensajería: Cualquier cosa que guarde datos -> STATEFULSET
                        App, Servicio WEB   -> DEPLOYMENT
----------------------------------------------------------------------------
- DaemonSets        NO SOLEMOS CREAR DAEMONSETS NOSOTROS
                    Plantilla de pod. Kubernetes se encarga de montar un pod en base a la plantilla en cada nodo del cluster:
                        - Driver de RED
                        - Sistema de monitorización
                        
Wordpress

    Apache         -> Cluster
                            Los datos -> BBDD
                            Ficheros  -> En el entorno donde está el apache. En este caso, igual que en temis:
                                Si tengo 3 JBOSS o 3 Apache, quiero que cada uno tenga su HDD donde guardar los ficheros? NO
                                Si un fichero se sube desde un JBOSS quiero que esté disponible en todos los JBOSS.
                                En este caso, todos los pods, comparten el volumen de almacenamiento de los ficheros.
                                ESTO SERIA UN DEPLOYMENT
    
    BBDD - Mariadb -> Cluster, pero cada pod tiene que tener su propio volumen de almacenamiento,
                      Cada nodo del cluster de mariab (pod) guarda unos datos diferentes a los del resto de nodos
                      No todos los nodos (pods) guardan la misma información
        
# Asignación de recursos
                                                                                        CPU         RAM
Nodo 1 de Kubernetes (máquinas físicas (podrían ser virtuales... no es frecuente))      8           32

Nodo 2 de Kubernetes (máquinas físicas (podrían ser virtuales... no es frecuente))      16          32

Nodo N de Kubernetes (máquinas físicas (podrían ser virtuales... no es frecuente))      8           32


Y ahora despliego un pod: TEMIS... y quiero 2 pods: 
Esos pods, pueden chuparse toda la RAM de la máquina? NO
Y he de limitarlo.
Dónde?
- El primer sitio en el propio programa: Abre como mucho 4Gbs de RAM ?? Dónde? A quién? JVM -Xmx4g   -Xms4g
                                                                                            (maximo) (inicial)   
                                                                                En la JVM la recomendación es que sean IGUALES
Y ahora quiero desplegar una BBDD, MariaDB / SQLServer
Esos pods, pueden chuparse toda la RAM de la máquina? NO
Y he de limitarlo.
Dónde?
- El primer sitio en el propio programa: Abre como mucho 4Gbs de RAM

En Kubernetes he de establecer límites también... Con 2 objetivos:
- Poder hacer una buena planificación de dónde debo desplegar qué? 
- Para proteger a otros pods en caso de que a uno se le vaya la cabeza.

```yaml
kind:           Pod
apiVersion:     v1 

metadata:
    name:       mi-pod

spec:
    containers:
        -   name: mi-contenedor
            image: nginx:latest
            imagePullPolicy: IfNotPresent # Cuando se debe descargar la imagen del contenedor del registry
            resources:
                requests:   # Es lo que solicito que se me garantice
                    cpu:        500m    # Asigno 500 milicores de cpu... es decir, el equivalemte a medio core
                    memory:     2Gi
                limits:     # Es lo máximo que puedo llegar a usar si hay recursos de sobra
                    cpu:        2       # Como mucho el equivalente a 2 cores. Igual que haber puesto 2000m
                    memory:     4Gi
```
# Cómo impactan esas cifras en Kubernetes

                    TOTAL           USO         COMPROMETIDO
                CPU     RAM     CPU     RAM     CPU     RAM
Nodo 1           4       10      3       3       4      10
    PodTemis 1                   1       1      -2      -4.  ---> Quiere empezar a usar más cores... 2... puede? (2) si... aunque no haya hueco, él tiene garantizados 2 cores. Se lo quito a la BBDD que está usando más de lo que solicitó = LA BBDD IRA MAS LENTO
    BBDD 1                       2       2      -2      -6   ---> Quiere empezar a usar más cores... 3... puede? (1) Si... hay hueco... y no hay limite impuesto
                                                                    MATO LA BBDD.. por lista y coger más RAM De la que solicitó. LA REINICIO
LIBRE:                           1       7       0       0

Nodo 2           4       10                      4.     10
    PodTemis 2                   2       1      -2      -4
    NGINX                                       -1      -1      


                  Request           Limit
              CPU.      RAM.   CPU.     RAM
Pod Temis 1     2        4
Pod Temis 2     2        4
BBDD 1          2        6      -        6
NGINX           1        1      

El request impacta lo primero en el Scheduller: en el planificador

---

# Afinidades

Permiten influenciar al planificador en la decisión de donde colocar un pod:
```yaml
kind:           Pod
apiVersion:     v1 

metadata:
    name:       mi-pod
    labels:     
        mi-etiqueta:    mi-valor
spec:
    containers:
        -   name: mi-contenedor
            image: nginx:latest
            imagePullPolicy: IfNotPresent # Cuando se debe descargar la imagen del contenedor del registry
            resources:
                requests:   # Es lo que solicito que se me garantice
                    cpu:        500m    # Asigno 500 milicores de cpu... es decir, el equivalemte a medio core
                    memory:     2Gi
                limits:     # Es lo máximo que puedo llegar a usar si hay recursos de sobra
                    cpu:        2       # Como mucho el equivalente a 2 cores. Igual que haber puesto 2000m
                    memory:     4Gi
    nodeSelector:
        maquina: en-la-17           # AQUI PONGO UN LABEL QUE HAYA ASOCIADO AL NODE
                                    # NO SE USA PRACTICAMENTE, Salvo caso muy muy raros y especiales
                                    # Normalmente lo uso cuando:
                                    # Tengo 3 máquinas de un cluster de 30 máquinas que tienen algo especial de HW: GPU x 10k
                                    # Y tengo un programa que requiere de GPU (Deep Lerning: Entrenando una red neuronal para...)
    affinity:
        nodeAffinity:
        podAntiAffinity:
        podAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
                - labelSelector:
                    matchExpressions:
                        - key: app
                          operator: In               # In NotIn Exists DoesNotExist Gt Lt
                          values: 
                            - nginx
                  topologyKey: kubernetes.io/hostname
                                    
```

Hay 3 tipos de afinidades que puedo usar en kubernetes:
-  Afinidades a nodos: nodeSelector ( Hay otra sintaxis en kubernetes para lo mismo: nodeAffinity)
-  Afinidades a pods:
-  Antiafinidades a pods: ESTE SE USA SIEMRPE !
                                                                    CLUSTER DE KUBERNETES
                                                           <----------------------------------------->
                                                            MAQUINA 1       MAQUINA 2       MAQUINA 3   < Estan en red (la que has montado de kub)
                                                            pod temis       pod-temis       
                                                                            pod-bbdd        pod-bbdd

bbdd
    Si le configuro afinidad con el pod temis
        requeridas                                           x               x              -               
        preferidas                                           X               X              x
    Si le configuro antiafinidad con el pod temis            -               -              x
    Si le configura afinidad con pods que no sean temis      
        requerido                                            -               X              X
                    
Siempre que hago un despliegue voy a generar antiafinidad preferida conmigo mismo

---

HELM
Docker -> Generar imágenes de contenedor

---

En kubernetes se hacen 3 tipos de pruebas a los pods.

Por defecto, se considera que un pod está corriendo y listo(READY) si el proceso principal de todos sus contenedores está corriendo.
Eso es lo mismo que se hace en Docker.

    MariaDB Cluster
        Pod1
        Pod2            Servicio Cluster (Balanceo de carga)
        Pod3
        
En Kubernetes hay 3 pruebas secuenciales que se hacen:
- Startup   Si se pasa se entiende que el pod ha arrancado bien. Si no, el pod es reiniciado
                En cuanto da OK, el pod pasa a estado INICIALIZADO
                Y en ese momento se comienzan a ejecutar las pruebas de LIVENESS
    Una BBDD Puede tardar tiempo en arrancar... unos minutos... y tengo que esperar a que arranque.
- Liveness  Si se pasa se entiende que el pod ha arrancado bien. Si no, el pod es reiniciado
            Pero se sigue ejecutando a lo largo del tiempo           
    Una vez ha arrancado, no significa que esté lista para que los usuarios accedan a tirar queries
    Eso lleva más tiempo.
    De hecho en algunos momentos, con la BBDD ya en funcionamiento, el POD puede volver a este estado, por ejemplo en un backup
- Readyness Si se pasan se entiende que el pod está listo para prestar servicio.
            Y en ese momento se añade la IP del pod a su servicio asociado (BALANCEO)
            Si no se pasa, el contenedor vuelve a estado Initialized
Y se siguien haciendo estas pruebas para ver en que momento está ready

El hecho de que el proceso JAVA asociado a un JBOSS esté corriendo no significa que el JBOSS Esté en un estado saludable.
Quizás tengo 45 de los 50 workers del pool stuck... o los 50...
Y no estoy atendiendo ninguna petición.
Y neceito mirar más allá de que el proceso esté corriendo.
Quizás quiero probar a hacer un curl (petición HTTP) a ver si contesta
    TEMIS /status


---
                sticky session
cookie <-----    BALANCEADOR      <---- session (RAM)   NODO 1
                                                         ^v
                                                        NODO 2

REDIS / MEMCACHED

---

En el curso hemos montado un cluster desde 0 REAL... 
aunque faltan cosas por montarle:
- metallb
- ingress copntroller
- provisionador de volumenes dinamico

PAra jugar os podeis montar un cluster en vuestro portatil completo, con ingres,
con provisionador de volumenes: MINIKUBE

----

Vosotros deplegareis un servicio en kubernetes... no uno... muchos
Y todos al final igual
Entre unos y otros cambiará: 
- Imagen
- Recursos (ram, cpu)
- end point (ingress)
- volumen / necesidades de almacenamiento o no
- puertos

Además de tener que desplegar varios servicios, los desplegareis en varios entornos
Dentro de un mismo cluster o en varios clusters


Preparar montones de ficheros de despliegue Y mantenerlos es muy costoso.
Y alfinal os interesa hacer vuestro propio chart de HELM para el despliegue de vuestros servicios

Y acabo con 20 ficheritos YAML para cada app/entorno