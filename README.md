# Grupo

- Alonso García, Mar (mar.alonso)
- Castro Rampersad, Sebastián Alfredo (s.castro.rampersad)
- Castro Vilar, Adrián (adrian.castrov)
- Fanjul Sánchez, Adolfo (a.fsanchez1)
- Gayoso Salvado, David (david.gsalvado)
- Rodríguez Estévez, Carla (carla.rodriguez1)

# Breve presentación del proyecto

Principalmente la descripción de la propuesta, y cualquier otro
aspecto destacable como presentación del proyecto.


# Install

Primero se tendrá que editar el fichero **config.ex** en **lib/emailservice**, sustituyendo todos los *** por
la ip correspondiente.

Se ejecuta  ``` ./script.sh [your IP] ``` desde **practica-final-davidgsalvado**.
Este script generará once ventanas en la terminal, cada una de ella ejecutará un nodo.

A continuación se tendrán que inicializar desde la terminal todos los elementos que forman parte del sistema.
1. En Users database [u_db]: ``` MXConfig.init_db_users ```
2. En Messages database [m_db]: ``` MXConfig.init_db_message ```
3. En Message Service 2 [s_m2]: ``` MXConfig.init_sv_message ```
4. En Message Service 1 [s_m1]: ``` MXConfig.init_sv_message ```
5. En User Service 1 [s_u1]: ``` MXConfig.init_sv_user ```
6. En Message Load Balancer 2 [lb_m2]: ``` MXConfig.init_lb_message ```
7. En Message Load Balancer 1 [lb_m1]: ``` MXConfig.init_lb_message ```
8. En User Load Balancer 1 [lb_u1]: ``` MXConfig.init_lb_users ```
9. En Directory [dir]: ``` MXConfig.init_dir ```
10. En Client 2 [c_2]: ``` Ui.init_ui(:"dir@[your IP]") ```
11. En Client 1 [c_2]: ``` Ui.init_ui(:"dir@[your IP]") ```

Comando ``` help ```  en la UI para ver las funcionalidades disponibles.

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
