# Solución de problemas

- **Estoy dentro de Distrobox:** abrir la terminal Ubuntu con `bash --noprofile
  --norc` como indica el README. El lanzador necesita el Podman del anfitrión.
- **No aparece una ventana:** comprobar `echo "$DISPLAY"` y `/tmp/.X11-unix` en
  Ubuntu. En Windows actualizar WSL con `wsl --update` si WSLg no funciona.
  El diagnóstico sin pantalla puede pasar aunque WSLg no esté disponible.
- **Permisos de Podman:** ejecutar como usuario normal. Comprobar rangos del
  usuario en `/etc/subuid` y `/etc/subgid` y ejecutar `podman info`.
- **Falló el diagnóstico:** leer `build/environment-check/report.json` y el log
  indicado. No cambiar el PDK ni mezclar versiones para silenciar un error.
- **Configuraciones viejas:** este entorno guarda sus preferencias en `.local/`
  y no utiliza las de los proyectos anteriores. Respaldar `.local/` antes de
  restablecer preferencias; nunca borrar `design/` para solucionar instalación.
- **Nuevos símbolos propios:** los directorios `schematic/` de cada bloque ya
  forman parte de la búsqueda de Xschem. Abrir siempre con el lanzador.
- **Espacios en rutas:** están soportados por el lanzador, pero es preferible
  clonar dentro del sistema Linux (por ejemplo `~/tesis`) por rendimiento.

Las herramientas adicionales Magic, Netgen y CACE se detectan, pero sus flujos
de proyecto no están configurados ni validados. DRC/LVS se prepararán cuando
exista un layout y se definan las condiciones de extracción y comparación.
