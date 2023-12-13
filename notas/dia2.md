
# Entorno de producción

Qué características tiene un entorno de producción que lo diferencian de el resto de entornos (desarrollo, test, etc)?

- Alta disponibilidad: 

    Capacidad del sistema de seguir funcionando a pesar de fallos en los componentes del sistema.
    Normalmente decimos que vamos a TRATAR de garantizar que el sistema estará funcionando un determinado porcentaje del tiempo que debería estar funcionando.... esto habitualmente se mide en 9s (nueves)

     |   Disponibilidad del 90% RUINA: 36.5 días al año OFFLINE... Blog de mis andanzas por la universidad                        €
     |   Disponibilidad del 99% RUINA: 3.65 días al año OFFLINE... Peluquería de barrio y tengo una web de reservas               €€
     |       1 ordenador (pc gamer de mi hijo)
     |   Disponibilidad del 99.9%:     8.76 horas al año OFFLINE... Cabot (TEMIS)                                                 €€€€€
     |       El sistema instalado al menos en 2 ordenadores... Y quizás a cada ordenador le pongo 2 fuentes de alimentación... 
     |       y 2 tarjetas de  red...
     |   Disponibilidad del 99.99%:    52.56 minutos al año OFFLINE... Hospital
     |       Ese sistema con 2 ordenadores guays... le tengo además replicado en otra ubicación física, con 2 proveedores de     €€€€€€€€€€€€€€
     |       internet diferentes, y 2 proveedores de electricidad diferentes...(o generadores de electricidad propios)
     v      
    €€€€€€

    Como conseguimos esto? REPLICA, REPLICA, REPLICA

    Esas réplicas forman lo que llamamos un cluster(grupo): 
    - Servidores
    - Procesos
    Podemos tener esos cluster configurados en modo:
    - Activo/Pasivo:    (1 servidor activo, el resto pasivos a la espera de que el activo se pegue el castañazo)
        ^^^ VIPA (IP Virtual que hacemos saltar de un servidor a otro)
    - Activo/Activo:    (Todos los servidores activos, y repartiendo la carga entre ellos)
        ^^^ Balanceador de carga ( nginx, haproxy, httpd, etc) 

    Para que los clientes puedan acceder... necesito darles una IP / fqdn (que apuntará a una IP) .... ¡necesito una VIPA o un balanceador de carga!

    Y si un HDD se me jode? Necesito tener lo datos guardados en varios sitios...al menos en 3 sitios diferentes... (3 copias)

- Tolerancia a fallos

    Que entra un capullo y se carga una tabla de la bbdd por una mala query (noche)... Necesito backups x2 (al menos)... tendré no se cuantos backups (15 días atrás)

    Vete sumando Mbs.... el almacenamiento en producción es una pasta!

- Escalabilidad
  
  Capacidad para ajustar el consumo de infra en función de la demanda en cada momento.

    App1: App de un hospital para gestionar los informes de los pacientes... 100 despachos... y 350 médicos.. y los pacientes que entren...
        día 1:      100 usuarios
        día 100:    100 usuarios        NO NECESITO ESCALAR
        día 1000:   100 usuarios

    App2: 
        día 1:      100 usuarios
        día 100:    1000 usuarios       Escalabilidad VERTICAL : MAS MAQUINA !
        día 1000:   10000 usuarios      
    
    App3: ESTE ES EL ESCENARIO MAS COMUN HOY EN DIA (INTERNET)
        hora n:      100 usuarios
        hora n+1:    1000000 usuarios
        hora n+2:    1000 usuarios      Escalabilidad HORIZONTAL : MAS o MAQUINAS ! Cluster Activo/Activo
        hora n+3:    10000000 usuarios

        Web telepi:         6am? 0      9am?0      13pm? 1020      14pm? 2500      5pm? 10      9:00? Maadrid / Barça... Nos vamooooos!

# Kubernetes

Orquestrador de contenedores (vaya mierda de definición)
Kubernetes es un gestor de gestores de contenedores, pensado para la gestión de un entorno de producción.
Lo crea Google en 2014, y lo dona a la CNCF (Cloud Native Computing Foundation) en 2015.
Para sus entornos de producción.

Kubernetes: Va a hablar con los gestores de contenedores (Docker, Crio, Containerd, etc) para gestionarlos.
            Yo diré a Kubernetes que quiero 3 contenedores de nginx en el cluster.
            Kubernetes va a decidir en que máquinas los va a poner, y va a solicitar a los gestores de contenedores que los pongan en marcha.
            Y a partir de ese momento, Kubernetes velará por que esos contenedores estén funcionando, y si alguno se cae, lo volverá a levantar.
                "lo volverá a levantar"... realmente lo que hace es crujir ese contenedor... y crear uno nuevo... en la misma máquina o en otra.

Cluster de máquinas
- Máquina 1             (Máster)        Sistema de almacenamiento en RED/CLOUD (persistencia)
    Crio/Containerd
        JBOSS-temis1
- Máquina 2
    Crio/Containerd
        JBOSS-temis2
- ...
- Máquina N
    Crio/Containerd
        JBOSS-temis3

        Necesitaré un BC... que le pediré a kubernetes que monte por mi... y que me lo gestione.
        Necesitaré un proxy reverso, para proteger mis aplicaciones... y le diré al kubernetes que me lo monte y me lo gestione.
        Necesitaré configurar reglas en ese proxy reverso... y le diré al kubernetes que me lo monte y me lo gestione.
        Necesitaré certificados para mis apps... 
        Necesitaré controlar quién tiene acceso a que recursos de red: Reglas de firewall de red-... y le diré al kubernetes que me lo monte y me lo gestione.
        Necesitaré en un momento dado 3 copias más de mi app... y le diré al kubernetes que lo gestione.

El kubernetes va a matar contenedores como si no hubiera un mañana!
Necesito los datos de esos contenedores a salvo.... Y cuando trabajo con kubernetes TODOS LOS DATOS se almacenan en VOLUMENES externos al cluster

En kubernetes no trabajamos con CONTENEDORES... trabajamos con PODS

## Qué es un POD?

Un pod es un conjunto de contenedores que:
- Comparten configuración de red... y por ende IP... y por ende se hablan a través de la red de loopback (localhost)
- Pueden compartir volúmenes de almacenamiento LOCALES (en la misma máquina)
- Se despliegan en la misma máquina
- Escalan juntos

TEMIS: 
 - SQL Server
 - Jboss

Preguntas: 
- ¿1 contenedor o 2 contenedores?
  - SIEMPRE 2 contenedores. Cada herramienta va en su contenedor.... No tiene sentido juntarlos bajo ningún punto de vista.
- ¿1 pod o 2?
  - SIEMPRE pods por separado para el SQL Server y el JBoss:
    x Comparten configuración de red... y por ende IP... y por ende se hablan a través de la red de loopback (localhost)
    x Pueden compartir volúmenes de almacenamiento LOCALES (en la misma máquina)
    x Se despliegan en la misma máquina
    X Escalan juntos
- Por tanto... para una instalación de desarrollo, cuántos pods voy a crear dentro de kubernetes? NINGUNO. Crearé 2 plantillas de pods
  Por tanto... para una instalación de producción, cuántos pods voy a crear dentro de kubernetes? NINGUNO. Crearé 2 plantillas de pods

  Yo no creo pods en kubernetes. Puedo hacerlo.... NO LO HAGO NUNCA bajo pena de que me corten las uñas muy cortitas y me metan la mano en un vaso llenos de zumo de limón!!!!

  Kubernetes crea pods en su cluster... Es su responsabilidad.
  Nosotros lo que vamos es a nutrir a kubernetes con PLANTILLAS de pods... y le diremos cuántas réplicas de esa plantilla queremos:
    - Desarrollo: 1
    - Producción: 3-10  <<<< Autoescalador de pods

Cuando creamos un cluster de kubernetes... y empezamos a configurar cosas en ese cluster....
Las cosas las vamos a meter en NAMESPACES (espacios de nombres)
Un namespace es una agrupación LOGICA de recursos dentro de un cluster de kubernetes. Para qué sirve:
- Para tener distintos entornos en el mismo cluster (desarrollo, test, producción)
- Para tener distintos clientes en el mismo cluster
- Para tener distintas apps en el mismo cluster
- A veces mezclamos todos esos conceptos:
  - NS1: temis-prod
  - NS2: temis-test
  - NS3: temis-dev
  - NS4: temos-prod
  - NS5: temos-test