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