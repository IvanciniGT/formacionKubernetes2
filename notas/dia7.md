# Creación de imágenes de contenedor

Crear un contenedor desde una imagen base de contenedor
En ese contenedor vamos a instalar las cosas que necesitemos instalar
Y es contenedor lo pasamos a una imagen de contenedor. Lo congemos en el tiempo.

Básicamente hay 2 formas de hacer esto: 
- de manera manual. El problemón es que vamos a hacerlo cada 2x3. Cada versión. Y es mucho curro
- de manera automática <<<<<
    Dockerfile

Un Dockerfile es un fichero que define un script de creación de una imágen de contenedor.
Y nos hace falta aprender 10 o 12 palabras... nada más

# En estos ficheros puedo poner comentarios, con el cuadradito... pero
# El comentario debe aparecer desde el principio de la linea.
# No es como otras sintaxis que me entiende a mitad de una linea el # e ignora el resto

# Indica la imagen BASE de la que partimos apra generar el nuevo contenedor 
# que posteriormente plancharemos como una nueva IMAGEN
# Normalmente partimos de imágenes BASE, es decir, imágenes que están preparadas para ser extendidas
# dando lugar a nuevas imágenes de contenedor personalizadas.
FROM maven:3-openjdk-17

https://github.com/IvanciniGT/webappTest