# Grupo

- Alonso García, Mar (mar.alonso)
- Castro Rampersad, Sebastián Alfredo (s.castro.rampersad)
- Castro Vilar, Adrián (adrian.castrov)
- Fanjul Sánchez, Adolfo (a.fsanchez1)
- Gayoso Salvado, David (david.gsalvado)
- Rodríguez Estévez, Carla (carla.rodriguez1)

# Breve presentación del proyecto

En este proyecto hemos implementado un servicio de mail basado en una arquitectura cliente servidor 
distribuida. Esto significa que tanto el servidor como el cliente se encuentran en nodos diferentes.
El sistema permite registrarse, loguearse, enviar mensajes a los usuarios registrados,
listar los mensajes nuevos, listar el histórico de mensajes, borrar los mensajes leídos y listar los
usuarios registrados.


# Install

Se ejecuta  ``` ./script.sh [your IP] ``` desde **practica-final-davidgsalvado**.
Este script generará una serie de ventanas en la terminal, cada una de ellas ejecutará un nodo.

>Es importante destacar que el script solo funciona para sistemas UNIX que empleen GNOME como sistema de ventanas. En caso de no contar con un sistema de estas características, será
necesario inicializar estos nodos en diferentes ventanas manualmente.
>Tip: Copiar los comandos del script.

- Una vez desplegados los nodos aparecerá un nodo especial con el nombre de ```config@[your IP]```.
- En la terminal interactiva del nodo escribir el comando ```MXConfig.init_config("[your IP]")```. 
>Es importante pasar ```your IP``` como un ```string```.

- Una vez hecho esto, todos los nodos estarán configurados siguiendo la estructura del diagrama que aparece abajo.

- Ahora, pasar a una de las ventanas que alojan cualquiera de los nodos cliente ```c_1@[your IP]```, por ejemplo.

- Ejecutar el comando ```Ui.init_ui("[your IP]")``` en la terminal interactiva.
>Es importante pasar ```[your IP]``` como un ```string```.

- Se iniciará la interfaz por línea de comandos. Con el comando ```register [your_name] [your_password]``` te podrás registrar y acceder al sistema.

- Una vez registrado o logueado, escribir comando ``` help ```  en la UI para ver las funcionalidades disponibles.

Resultado de la ejecución de las funciones anteriores:

                        +------------+       +------------+
                        |  CLIENT 1  |       |  CLIENT 2  |
                        +------------+       +------------+
                              |                    |
                              |                    |
                              |                    |
                              |                    |
                              |                    |
                          +-----------------------------+
                          |          DIRECTORY          |
                          |-----------------------------|
                          |   NM LB USR  |  NM LB MSS   |
                          +-----------------------------+
                             /               \          \
                            /                 \          \
                           /                   \          \
                          /                     \          \
                +------------+      +------------+    +------------+
                |  LB USR 1  |      |  LB MSS 1  |    |  LB MSS 2  |
                |------------|      |------------|    |------------|
                | NM SER USR |      | NM SER MSS |    | NM SER MSS |
                +------------+      +------------+    +------------+
               /                      /     \         /   \
              /                      /       \       /     \
             /                      /       __\_____|       \
            |                      |       |   \             |
            |                      |       |    \_______     |
            |                      |       |            |    |
           +-----------+          +-----------+       +-----------+
           | SER USR 1 |          | SER MSS 1 |       | SER MSS 2 |
           |-----------|          |-----------|       |-----------|
           |  NM DB M  | \        |  NM DB M  |       |  NM DB M  |
           |-----------|  \       +-----------+       +-----------+
           |  NM DB U  |   \                |           |
           +-----------+    \               |           |
                 |           \              |           |
                 |            \_________    |           |
                 |                      |   |           |
                 |                      |   |           |
           +-----------+               +-------------------+
           |  DB USR   |               |       DB MSS      |
           +-----------+               +-------------------+

- Para ejecutar los tests habrá que lanzar ``` ./script.sh [your IP] ``` desde **practica-final-davidgsalvado**.
- Una vez ejecutado el script desde **practica-final-davidgsalvado** se ejecutará en la terminal el comando ```iex --name test@[your IP] -S mix test```.
> Es importante lanzar los tests como un nodo para que puedan realizarse contra el sistema distribuido desplegado con el script.

# Estructura del repositorio
- ```lib```: Contiene el código y la guía de estilo
- ```presentación```: Contiene las instrucciones de la exposición
- ```test```: Contiene el código de los tests
