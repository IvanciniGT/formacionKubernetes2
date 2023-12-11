
# Contenedor

Un contenedor es un entorno aislado dentro de un SO que rueda un Kernel Linux donde ejecutar procesos.
Aislado:
- Ese entorno tiene su propia conf. de red -> IP propia
- Tiene su propio sistema de ficheros
- Tiene sus propias variables de entorno
- Puede tener limitaciones de recursos (CPU, RAM, etc.). ESTO NO LO HACEMOS NUNCA CON DOCKER.... pero ya os contaré por qué!

## Para qué sirve un contenedor?

### Formas de instalar/ejecutar software en un entorno

#### Forma más tradicional: Instalaciones a hierro

        App1 + App2 + App3              Problemas de esta forma de instalar:
    ----------------------------            - Problema con que una app requiera un determinado SO, que no es el que tengo montado
        Sistema Operativo                   - Dios no lo quiera! Y seguro que no ocurre... no pasa nunca, lo sabemos... una app tiene un bug.
    ----------------------------                A lo mejor debido a ese bug, se pone la cpu para freir huevos!
              HIERRO                                App1 -> 100% CPU ---> OFFLINE... App2 y App3 -> OFFLINE
    ----------------------------            - Incompatibilidades con dependencias o configuraciones
                                            - Seguridad: Una app lea los archivos de otra... o la RAM... o controle las pulsaciones de teclado (VIRUS)

#### Basada en Máquinas virtuales

        App1  |   App2 + App3            Esto es genial. Nos resuelve todos los problemas de la instalación a hierro.
    ----------------------------         El problema es que esta forma de trabajar nos trae nuevos problemas:
       SO 1   |      SO 2                   - Desperdicio de recursos
    ----------------------------            - Merma en el rendimiento
       MV 1   |      MV 2                   - La configuración / mantenimiento se me complica
    ----------------------------        
        Hipervisor:
        Citrix, VMWare, HyperV          
    ----------------------------        
        Sistema Operativo               
    ----------------------------        
              HIERRO                    
    ----------------------------        

### Basada en contenedores

       App1   |   App2 + App3           Esto resuelve casi los mismos problemas que las MV, pero sin los problemas de las MV
    ----------------------------        Hoy en día la forma estándar de ejecutar cualquier software empresarial es mediante contenedores.
       C 1    |      C 2                
    ----------------------------        
       Gestor de contenedores:
       Docker, ContainerD, 
       Podman, CRIO
    ----------------------------        
      Sistema Operativo (Linux)         
    ----------------------------        
              HIERRO                    
    ----------------------------        

Dentro de un contenedor no tengo un SO. Es imposible!
Kernel de SO más usado del mundo

## Despliegue de software mediante contenedores

Al trabajar con esas formas más tradicionales, lo que hacemos es instalar un software.
Quiero en mi máquina un SQL Server de MS:
- Descargo el instalador
- Ejecuto el instalador... lo cuál puede ser más o menos complejo.
  -> c:\archivos de programa\microsoft\sqlserver  ----> ZIP ---> EMAIL (os funciona?) = IMAGEN DE CONTENEDOR
- Ejecuto el programa SQL Server

### Imágen de contenedor

Un triste fichero comprimido (.tar) que contiene:
- Una estructura de carpetas compatible con la especificación POSIX (no es obligatorio pero si habitual... todo el mundo lo hace)
    bin/        Comandos ejecutables
    lib/
    opt/        Software de terceros
    var/        Datos de las apps (logs, ficheros de una bbdd, etc.)
    usr/
    tmp/        Ficheros temporales, que se pierden tras un reinicio
    home/       Directorio de usuario
    etc/        Configuración
- Un programa o varios ya instalados de antemano por alguien

Cuando trabajamos con contenedores NO INSTALAMOS SOFTWARE... Lo desplegamos... = Descomprimimos un fichero comprimido.

El que instala el software suele ser el fabricante del software, que sabe de instalar ese software 500 veces más que yo.

Las imágenes de contenedor las encontramos en REGISTROS de REPOSITORIOS de IMAGENES DE CONTENEDOR:
- Docker Hub
- RedHat Quay.io
- Amazon ECR
- Las empresas suelen montar su propio registro de repos de imágenes de contenedor: Artifactory, Nexus, etc.  Gitlab, Github, etc.

Adicionalmente, en una imagen de contenedor, viene otra información (METADATOS):
- Cuál es el comando que debe ejecutarse en un contenedor creado desde una imagen de contenedor concreta cuando se arranque ese contenedor.
- Qué puertos usa el software que ahí viene instalado
- En qué carpetas se guardan los datos de la app
- Qué variables de entorno se deben configurar para que la app funcione correctamente

Todas las empresas que fabrican software (empresarial) a día de hoy, generan imágenes de contenedor de sus productos.

Esas imágenes de contenedor las descargamos y descomprimimos con la ayuda de un GESTOR DE CONTENEDORES: docker, podman, containerd, etc.
Y a través de esos gestores de contenedores hago operaciones sobre los contenedores: 
    - Arrancarlos
    - Pararlos
    - Reiniciarlos
    - Eliminarlos
    - Muestra sus logs

Algunos gestores más avanzados me permiten incluso crear mis propias imágenes de contenedor.... con mi software instalado.

Las imágenes de contenedor siguen un estándar: OCI (Open Container Initiative) https://opencontainers.org/
Todos los gestores de contenedores siguen ese estándar.... y por ende una imagen de contenedor creada con un gestor de contenedores, puede ser usada por otro gestor de contenedores.... ESTO NO OCURRE CON LAS MIERDA-MAQUINAS-VIRTUALES (Citrix -> VMWare -> HyperV)

Además, las imágenes de contenedor son PORTABLES. Puedo usarlas en un SO u otro, por un gestor de contenedores u otro, de un registro de imágenes de contenedor u otro, etc. sin problemas.
Además estandarizan no solo la forma de desplegar el software, sino también la forma de configurarlo/utilizarlo.

Qué comando es el que tengo que ejecutar para arrancar un servidor nginx? NPI... pero si está dentro de un contenedor, me vale con solicitar el arranque del contenedor.

Y me da igual que ese contenedor tenga Nginx, SQL Server, Jenkins.... todos se arrancan igual.
Todos se paran igual.
A todos les puedo ver los logs igual.

Los contenedores se han comido a las MV... salvo muy gloriosas excepciones donde las MV siguen teniendo su hueco.
Hoy en día SOLO uso MV cuando tengo un Megaservidor con 4TB de RAM y 96 cores... y quiero crear unas cuantas MV ahí dentro ... más chiquititas.

# Qué era Unix?

Unix era un Sistema Operativo, creado por la gente de los lab Bell de AT&T en los 70.
Se dejó de fabricar en los 90.
En un momento dado había más de 400 versiones de Unix.
Antiguamente los SO se licenciaban de otra forma. AT&T Entregaba el código del SO a los fabricantes de HW, y estos lo completaban y recompilaban y lo vendían con su HW.
Cuando se creaba un software funcionaba en algunos Unix y en otros no.
Hubo que poner un poco de cordura en el mundo Unix, y se crearon 2 estándares:

# Qué es Unix?

Unix es un conjunto de estándares (2: POSIX + SUS) que definen cómo montar un Sistema Operativo.
Hoy en día, muchos fabricantes de HW montan sus propios SO cumpliendo con estas especificaciones.

IBM: AIX -> UNIX®
HP: HP-UX -> UNIX®
Oracle: Solaris -> UNIX®
Apple: MacOS -> UNIX®

## Sistemas operativos tipo UNIX

Hubo gente y sigue habiéndola que quiso montar un SO basándose en las especificaciones de Unix... pero sin certificarlo (que cuesta una pasta).
- 386BSD: Universidad de Berkeley en California. No vió la luz. AT&T les demandó por decir que tenían un SO Unix.
- GNU: GNU is Not Unix. Richard Stallman. RUINA! Montarón casi todo lo que hace falta para un SO: GNOME, gedit, gcc, chess, etc. Pero no el Kernel.
- Linus Torvalds: Crea Linux. Que es un kernel ... supuestamente compatible con las especificaciones de Unix.... aunque no lo sabremos nunca, ya que no está certificado.... ni nos los planteamos.
- GNU + Linux = GNU/Linux: Sistema operativo que se ofrece mediante compendios de software:
  - RedHat: RHEL
  - SUSE: SLES
  - Debian: Debian
  - Canonical: Ubuntu

El kernel de SO más usado del mundo es Linux. Y hay un SO que él solo hace que sea así: Android: Es Linux + Librerías de Google
De hecho, a día de hoy, de forma estándar en Windows, podemos levantar dentro del SO Windows (10, 11... server) un kernel linux, paralelo al kernel NT, que es el propio de Windows. Esto se llama WSL (Windows Subsystem for Linux)

# Docker Inc.

Docker es una empresa, que fabrica software relacionado con el mundo de los contenedores.
Hacen muchos productos:
- Docker Engine: Esto es a lo que nos referimos normalmente cuando hablamos de Docker: GESTOR DE CONTENEDORES
- Docker Hub: Repositorio de imágenes de contenedor
- Docker Swarm: Orquestador de contenedores (que nombre más feo)

## Docker Engine

Tiene una arquitectura cliente-servidor:
- Cliente: docker
- Servidor: dockerd

                          Es el que me permite realizar operaciones básicas con contenedores: arrancarlos, pararlos, reiniciarlos, eliminarlos, ver sus logs, etc.
Cliente para                        
comunicarme con dockerd   Además, me permite hacer operaciones básicas con imágenes de contenedor: descargarlas, listarlas, eliminarlas, etc.
 v                        v
docker -> dockerd -> containerd -> runc
            ^                        ^
            ^                        Éste ejecuta un contenedor. Para cada contenedor, se ejecuta un runc
            ^
            Me sirva para comunicarme con containerd
            Pero además, tiene otras funciones adicionales: crear imágenes de contenedor, subirlas a un registro, etc.

Antiguamente, containerd era parte del código de docker. La gente de docker, decidió separarlo, y donarlo a la CNCF (Cloud Native Computing Foundation) para que lo mantuviera la comunidad.

# Sintaxis del cliente de docker:

$ docker <TIPO DE OBJETO> <VERBO> <args>

TIPO DE OBJETO:
- container
- image
- network
- volume

VERBO: No todos los verbos se pueden aplicar a todos los tipos de objetos.
- create
- start (solo para contenedores)
- stop
- restart
- rm
- ls (containers, images, networks, volumes)
- inspect
- logs
- pull (solo para imágenes)
- push (solo para imágenes)

# Ver las imágenes de contenedor que tengo en mi máquina

$ docker image ls

# Ver los contenedores que tengo en mi máquina en ejecución

$ docker image ls

## Todos los contenedores independientemente de su estado

$ docker container ls -a | --all


Una cosita que tiene docker, que al principio nos despista es que casi todos los comandos tienen un alias:

Sintaxis tradicional                 Alias
docker image ls         =            docker images
docker container ls     =            docker ps

---

# Ejemplo 1

Montar un contenedor con nginx, para usarlo como un servidor web.

Nginx es un proxy reverso... que con el tiempo ganó funcionalidades de servidor web.

Al contrario que el Apache httpd server... que se originó como servidor web y con el tiempo ganó funcionalidades de proxy reverso.

Nginx es una herramienta que usaremos intensivamente en el curso (kubernetes)


                                                           Servidor:
    Cliente ->http-> Proxy -http->  Proxy reverso -http->  Aplicación Web 

        El proxy intercepta las peticiones que hace el cliente. Y deja en espera al cliente... siendo él quién hace la petición al servidor.
        De esta forma protegemos al cliente... su identidad no queda expuesta al servidor.

        El proxy reverso intercepta las peticiones que hace el servidor. Y deja en espera al cliente... siendo él quién hace la petición al servidor.... de forma que el servidor queda protegido.

Imágenes disponibles de nginx:

latest
stable
stable-alpine
1.25.3-alpine3.18-perl
1.25.3-alpine3.18
alpine3.18

Las imágenes de contenedor se identifican por un TAG.
Cuando a docker no le suministramos un tag, por defecto se busca el tag latest.... que cuidado, es otro tag más... no es ninguna palabra mágica.

Hay 2 tipos de tags:
- Fijos: 
  - 1.25.3-alpine3.18: Dentro de esta imagen está instalada la versión 1.25.3 de nginx, sobre una imagen de contenedor alpine3.18
  - 1.25.3-alpine3.18-perl: Dentro de esta imagen está instalada la versión 1.25.3 de nginx, sobre una imagen de contenedor alpine3.18, y además tiene instalado perl.

- Variables
  - latest: Suele corresponder con la última versión del software
  - stable: Suele corresponder con la última versión estable del software
  - 1.25-alpine3.18: Dentro de esta imagen está instalada la última versión 1.25 de nginx, sobre una imagen de contenedor alpine3.18
  - 1-alpine3.18: Dentro de esta imagen está instalada la última versión 1 de nginx, sobre una imagen de contenedor alpine3.18
  - alpine3.18: Dentro de esta imagen está instalada la última versión de nginx, sobre una imagen de contenedor alpine3.18

Pregunta...
Qué imagen creeis que nos interesa descargar (pensando en un entorno de producción)?
  - latest
  - alpine3.18              *** MALA DECISION
  - 1-alpine3.18            *** MALA DECISION
  - 1.25-alpine3.18         *** ESTA ES LA GUAY !
  - 1.25.3-alpine3.18       *** MALA DECISION

---

# Versiones de software

1.25.3

                Cuándo se incrementan?
1:  Major       Breaking change:
                    Quito cosas (con reemplazo similar o no)
                    + Adicionalmente puede traer arreglo de bugs
                    + Adicionalmente puede traer nueva funcionalidad
                    + Adicionalmente puede traer nuevas cosas obsoletas
25: Minor       Nueva funcionalidad
                o funcionalidad marcada como deprecated (obsoleta)
                    + Adicionalmente puede traer arreglo de bugs
3:  Patch       Cuando se arregla un bug

Los desarrolladores requieren de una determinada versión de un software para poder trabajar.... que tiene la funcionalidad que necesitan.
La funcionalidad la marca el Major.Minor

En producción quiero esa versión (a priori)... ya que es la que tiene la funcionalidad que necesito.... pero me gustaría tener el último patch... es decir, que según se arreglen bugs, los vaya aplicando.

No querría pasar (a priori) a la versión 1.26... ya que trae cosas que no necesito... y puede traer nuevos bugs.
Digo a priori... porque luego hay que tener en cuenta otros factores: seguridad, etc. que se hayan mejorado en una versión concreta

La ruta (identificador) completo de la image de contenedor es:
    docker.io/library/nginx:1.25-alpine3.18
    <----------------><---> <------------->
        registro      repo   tag

Habitualmente solo escribimos: nginx:1.25-alpine3.18
Y es el gestor de contenedores el que busca ese repo y su tag... dentro de los registros que tenga dados de alta en mi máquina.

---

Dentro de la imagen nginx, me viene una estructura de carpetas posix:
    bin/        Comandos ejecutables
        chmod       ** De donde se han sacado estos comandos? De la imagen de contenedor... pero como han llegado allí? De la imagen ALPINE LINUX
        cp
        mkdir
        cat
        sh
        pwd
    lib/
    opt/        Software de terceros
        nginx/
            nginx       <<<< binario
    var/        Datos de las apps (logs, ficheros de una bbdd, etc.)
        nginx/
            logs/       <<<< Logs de nginx
            html/       <<<< DocumentRoot de nginx
                 index.html
                 ....
    usr/
    tmp/        Ficheros temporales, que se pierden tras un reinicio
    home/       Directorio de usuario
    etc/        Configuración
        nginx/
            nginx.conf  <<<< Configuración de nginx

En el host, que también tiene una estructura POSIX de carpetas (al fin y al cabo hemos dicho que estamos en un host rodando LINUX)
    /bin/
        ls
    /lib
    /opt
    /var
        lib/
            docker/
                containers/
                    mi-contenedor/
                        var/        Datos de las apps (logs, ficheros de una bbdd, etc.)
                            nginx/
                                logs/       <<<< Logs de nginx

                    mi-contenedor-2/
                        var/        Datos de las apps (logs, ficheros de una bbdd, etc.)
                            nginx/
                                logs/       <<<< Logs de nginx
                images/ ESTAS CARPETAS DE AQUI ABAJO SON INMUTABLES... NO SE PUEDE CAMBIAR SU CONTENIDO
                    nginx:1.25.3-alpine3.18/    Docker (el contenedor) hace que esta carpeta se tome por el contenedor como el Root del FS /
                                                Esto no es nada nuevo... me refiero al engañar a un proceso y hacerle creer que una carpeta del fs del host es su root... lo hacemos desde hace 40 años en linux/unix: chroot
                        bin/        Comandos ejecutables
                            ls
                        lib/
                        opt/        Software de terceros
                            nginx/
                                nginx       <<<< binario
                        var/        Datos de las apps (logs, ficheros de una bbdd, etc.)
                            nginx/
                                logs/       <<<< Logs de nginx
                                html/       <<<< DocumentRoot de nginx
                                    index.html
                                    ....
                        usr/
                        tmp/        Ficheros temporales, que se pierden tras un reinicio
                        home/       Directorio de usuario
                        etc/        Configuración
                            nginx/
                                nginx.conf  <<<< Configuración de nginx
    /usr
    /tmp
    /home
    /etc

---

## Cuántas NIC tiene un computador cualquiera... vuestro portátil por ejemplo?

NIC? Tarjeta física de RED
- NIC cableada
- NIC wifi

## Cuántas interfaces de red tiene un computador cualquiera... vuestro portátil por ejemplo?

Una interfaz de red es una abstracción de una NIC.Es la forma en la que el SO conecta con una red... que puede ser a través de una NIC o no

- Interfaz de red cableada -> NIC cableada
    192.168.0.0/16 : IP 192.168.3.78
- Interfaz de red wifi -> NIC wifi
    192.168.0.0/16 : IP 192.168.5.84
- Interfaz de red loopback -> No tiene NIC asociada
    127.0.0.0/16 : IP 127.0.0.1 -> localhost

    La red de loopback es una red virtual que se usa para comunicar procesos dentro de una misma máquina.

# Redes en Docker

Cuando instalamos docker en nuestra máquina, docker genera por defecto una red virtual similar a la de loopback, pero que no es la de loopback.

Es una red que trabaja en el pool de direcciones 172.17.0.0/16
La máquina (el host) consigue en esa red la IP: 172.17.0.1
Y a partir de ahí, docker va asignando IPs a los contenedores que va creando en esa red.
---

# Imágenes base de contenedor

Son imágenes de las que partimos cuando queremos generar una imagen de contenedor propia, que lleve mi software.
La gente de nginx, generan su imagen partiendo de la imagen alpine... que trae 4 comandos linux pelaos.... que me pueden ser de utilidad.

En un alpine linux... no hay por ejemplo un instalador de paquetes, como el que viene en fedora (yum, dnf) o en debian/ubuntu(apt)

Si a mi me interesa tener además de los 4 copmandos linux pelaos... un instalador de paquetes... habría partido de la imagen de fedora... o de ubuntu...


La imagen de alpine trae:
- Los 4 comandos pelaos de Linux

La imagen de ubuntu trae:
- Los 4 comandos pelaos de Linux
- + bash
- + apt

La imagen de fedora trae:
- Los 4 comandos pelaos de Linux
- + bash
- + yum
- + dnf

