Maquina 1: SonarQube
Maquina 2: Jenkins
Maquina 3: Gitlab


Cluster Kubernetes
1 Maestro
2 Trabajadores

Máquinas 4 cores i7 x 2 hilos: 8 nucleos
16Gbs de RAM

Cluster
    - Calico
    - Dashboard
    - Metric Server (capturar metricas de uso de cpu y ram)
    - Metallb
    - Nginx ingress controller
    - Cert-Manager (Cargar certificados ssl)
    - Provisionar dinámico de volumenes - VMWARE (Volumen que exportas por nfs)
            - provisionador dinámico nfs
            - provisionador dínámico de vmware vsphere (MAS RENDIMIENTO)
    
Namespace:
    - sonarqube
    - jenkins      -> Los pipelines usais contenedores? Tendreis que actualizarlos a Kubernetes (es más fácil)
                        Podeis dejarlos con docker... por ahora
                        Kubernetes, al trabajar con Pod (que llevan muchos contenedores dentro) me facilita la vida mucho.
    - gitlab
    
        TODAS ESAS APPS de normal tendrán la CPU al 0%
            El problema es que cuando entran COMEN QUE TE CAGAS y si lo monto en máquinas con otreas apps .. me las pueden ralentizar mucho
            
    sonarqube
        resources:
            required:
                cpu: 100m
            limits: 
                cpu: 8
        
    jenkins
        resources:
            required:
                cpu: 100m
            limits: 
                cpu: 8
    gitlab
        resources:
            required:
                cpu: 100m
            limits: 
                cpu: 8
    
    TEMIS
        Servicios? Rest (5-10) ISTIO / Linkerd
    Lo primero es generar imagen Dockerfile: 
        O creandome mi propio dockerfile
        O mediante maven
            https://medium.com/@ramanamuttana/build-a-docker-image-using-maven-and-spring-boot-418e24c00776
        
            mvn compile
            mvn test-compile
            mvn test
            mvn package
            mvn docker::image ???
        Pruebo la imagen de contenedor (sobre todo las primeras veces) a manita
            En cuanto funciona -> Jenkins
            docker push -> A publicarla -> Necesitais un registry para dejarla -> gitlab
                En gitlab teneis registris en paralelo para: (dentro de cada repo)
                    - artefactos (jar, war)
                    - imagenes de contenedor
        Crear un archivo de despliegue en Kubernetes usando vuestra imagen
            Probar a mano a cargarlos en kubernetes
                Cuando carguen a Jenkins
            PROBLEMA! 
                Para cada entorno en que desplegueis, necesitais un fichero de despliegue
                Y acabais con 20 ficheros de esos... que cada vez que haya un cambio, y los habrá sobre todo en primeras versiones, lo flipais con el mnto
                Y es el momento en que me planteo montar mi propio chart de helm, que genere automaticamente esos ficheros para cada entorno/servicio
        
Sonarqube
    sonar
    base de datos - sql server -> Llevarla al cluster de kubernetes o no
        contenedor sql-server
            volumen copiado de los archivos de la BD del sql server que teneis ahora

Para hacer migraciones y llevaros datos que tengais de otras instalaciones:
- PASO 1, crear una pvc en kubernetes
- En autom, dado que habreis montado un provisionador dinámico (nfs.. vmware) se habrá creado un volumen real.
- PASO 2: A ese volumen os copiais los datos del antiguo
    - SQL Server (Me copio los ficheros de la BBDD)
    - Jenkins (carpeta /var/lib/jenkins)        
    - Sonarqube (carpeta /opt/sonarqube/data)   
- PASO 3: Hago el despliegue con helm apuntando a vuestras pvc

Migrar es un follón de cojones cuando hay versiones viejas!
    Nextcloud 17 -> 24
              17-> ultima 17
              ultima 17-> primera 18
              primera 18 -> ultima 18
              ultima
              
Copio los datos que tengo ahora mismo en el volumen de kubernetes: VERSION DESACTUALIZADA
Esa misma versión del software es la que monto en kubernetes
Y en kubernetes voy actualizando... que los procedimientos están más automatizados

Descargo la versión del char correspondiente a la versión de la app que me interesa (la que tengo desactualizada)
Hago una copia del fichero values.yaml -> mis-values.yaml
Le borro lo que no cambio ! IMPORTANTISIMO
Cambio lo que me interesa
    $ helm install mi-sonar sonarqube -f mis-values.yaml -n sonar --create-namespace
Esto ya instala la versión vieja
A partir de ahí, miro el roadmap de actualizaciones válido según fabricante
Me bajo el chart de helm correspondiente a la maxima versión a la que pueda actualizar la que tengo
1.22.4 -> 1.4.0
1.4.0 -> 2.0.0 
2.0.0 -> 2.3.7 que es que hay ahora
Le pòngo el mismo fichero mis-values.yaml que tengo (cruzo los dedos que no haya cambiado la estructura del yaml, que a veces ocurre... y me toca adaptarlo)
    $ helm upgrade mi-sonar sonarqube -f mis-values.yaml -n sonar --create-namespace
                            ^ Esta carpeta apuntaría a la versión nueva del chart de helm ... no a la vieja

----

Mas adelante:

El cluster le amplias en máquinas:

    Maquina 1
    Maquina 2
    Maquina 3
    ---
    Maquina 4 -> Taint produccion
    Maquina 5 -> Taint produccion
    Maquina 6 -> Taint produccion

Despliegues que lleven una toleración al taint producción
    tolerations: 
      - key: "entorno"
        operator: "Equal"
        value: "produccion"
        effect: "NoSchedule"
    affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 1
            preference:
              matchExpressions:
              - key: another-node-label-key
                operator: In
                values:
                - another-node-label-value
                
----
Pod que se vayan creando y borrando a cascoporro según carga de trabajo
Para eso, deben ser pequeños:
    1 Pod para temis de 32GbRAM y 8 cores
        5 pods de temis de 6Gbs de RAM y 2 Cores
        
---

En el mundo de los contenedores, el log de un contenedor es la salida estandar del proceso 1 que arranca el contenedor

En caso que esté con algo así como un jboss, tomcat... o similar, lo que hacemos es 
en el fichero de configuración del jboss... 
poner como fichero de log /dev/stdout


---
                en que en base al fichero, le pone una etiqueta
                
                            proxy         tranformer
filebeat  ---> kafka < --- logstash ---> logstash ---> ES < --- kibana
                                    ---> logstash
    que vaya leyendo cada fichero

---

Imagen de contenedor que la misma usas para desarollo/test/producción
    volume: /configuracion
        ---> application.properties (NOTA... pasaros a YAML)
             
        dentro de la imagen /app/application.properties -> /configuracion/application.properties
    carpeta donde se guardan archivos
        /var/lib/temis/files -> volumen
        /var/lib/temis/logs  -> volumen
    
        ---> .jar
            Injectar el .jar < - shared library en jboss
    
    O application properties o ENV
    
    
    
    Cuando tengais todo en Kub:

        temis -> 5 servicios 
        
        En kubernetes la URL es la misma en todos los entornos... lo que discrimina es el ns
            ns: produccion
            nd: desarrollo
            
            servicio-validacion-datos.produccion
            servicio-validacion-datos.desarrollo
            
            Y desde temis llamo a:
                servicio-validacion-datos y si temis está corriendo en el ns producción -> autom. -> servicio-validacion-datos.produccion
                servicio-validacion-datos y si temis está corriendo en el ns desarrollo -> autom. -> servicio-validacion-datos.desarrollo

---
definir los Probes -> endpoints
    1 endpoint os sirve:
        ReadinessProbe
            /temis/status -> 200
                     ^
                     Mínimo chequeo
                        Query "selec 1" a la BBDD
---

Los pods llevan contenedores.
Si un contenedor de un pod se cae, deja de correr, kubernetes entra en pánico!
Y empieza a reiniciar el pod como si no hubiera mañana!

Los contenedores de los pods están pensados para ejecutar demonios, que queden corriendo.
Como se me ocurra poner un contenedor que solo ejecute un comando/script que termine, el kubernetes lo flipa !

En ocasiones necesitamos contenedores que jecuten tareas sencillas (Script): Backup de la BBDD... y lo quiero programar que se haga cada 3 días
Quiero lanzar una ETL por las noches para mover datos de un sitio a otro.

JOBS:
Un Job es similar a un POD, pero sus contenedores están pensados para ejecutar scripts
DEBEN TERMINAR
Si no terminan, kubernetes entra en pánico! Y después de un rato, los cruje y otra vez

Kubernetes tiene un objeto llamado CRONJOB, que es algo así como lo que es un deployment a los pods
En un Depployment defino una plantilla de pod y el número de replicas que quiero de ella
En un CronJob defino unn JOB y cada cuanto quiero que se ejecute (SINTAXIS CRON)

---
Dentro de los pods se pueden definir un tipo especial de contenedores: initContainers

Los init container son como los contenedores de los Jobs.... deben ejecutar scripts
Los usamos para realizar configuraciones que necesito tener listas antes de ejecutar los pods
Por ejemplo:
- Temis
    Pod
        Volumen:
            - name: configuracion
              emptyDir: {} 
        initContainer: Configurador
            Programa que saca de git un fichero de confioguración (el ultimo que haya para un entorno producción)
            Y lo deja en el volumen /configuracion/configuracionActual.yaml
            Volumen: 
                - name: configuracion
                  mountPath: /configuracion
        Contenedor: jboss
            Volumen: 
                - name: configuracion
                  mountPath: /jboss/temis/configuracion
            
Si dentro de un POD tengo varios contenedores, kubernetes lanza su ejecución en paralelo.
Si dentro de un POD tengo 10 initContainers, se van ejecutando secuencialmente... y cuando todos acaba, 
    es cuando comienzan a ejecutarse los contenedores normales

En ocasiones, vereis que hay gente que crea Pods, sin contenedores, y con solo un initContainer, como si fueran un Job
Esto se hace bastante cuando al desplegar una app, quiero que se hagan unos trabajos de preparación que nunca más en la vida deben ejecuatrse
