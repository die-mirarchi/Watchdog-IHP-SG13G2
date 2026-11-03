# Instalación local — 10 de octubre de 2026

Proyecto clonado desde https://github.com/die-mirarchi/Watchdog-IHP-SG13G2
en `/home/eamtastudent/tesis/Watchdog-IHP-SG13G2`, Ubuntu-24.04 WSL2,
usuario `eamtastudent`. Commit de origen: `be621afab1b7d6543a6ced4b01700c73591176f5`.

## Versiones

- Imagen: `docker.io/hpretl/iic-osic-tools@sha256:7d70547f5f3691e5cf2abe14280dbb5b040baa2a3df425cc9a75edb6b8e4f6c8`.
- IHP Open PDK main: `5e6d592e4002946a4616f798c357f0f3c06cf3b6`, commit del 1 de septiembre de 2026.
- Xschem 3.4.8RC, ngspice 47, KLayout 0.30.11.
- PDK local en `.local/pdks/IHP-Open-PDK`, excluido de Git.
- Submódulos oficiales inicializados; seis modelos compilados con OpenVAF-Reloaded.

## Comprobaciones

El diagnóstico cargó los símbolos IHP en Xschem, simuló el punto de operación
de un NMOS (Vd=Vg=1.2 V, W=1 um, L=0.13 um, Id=400.5261 uA),
y cargó la tecnología y las PCells SG13_dev de KLayout.
Las reglas DRC/LVS están presentes. Magic, Netgen y CACE están disponibles.
Resultados y logs: `build/environment-check/`.

Esto verifica la instalación. El repositorio todavía no contiene el diseño
del watchdog; no se ejecutó DRC/LVS de un circuito ni su verificación funcional.

## Uso

Abrir `Tesis.bat` del escritorio. En la terminal: `xschem &` o `klayout -e &`.
Desde Ubuntu anfitrión: `bash scripts/eda.sh check`, `xschem`, `klayout` o `shell`.
Para reinstalar el entorno fijado: `bash setup.sh`.

El BAT anterior está conservado como `Tesis.bat.backup-20261010` en el escritorio.
Los cambios de configuración están locales, sin commit ni push.
Los proyectos EAMTA, sus diseños y su contenedor no se modificaron.

Referencias: [curso EAMTA](https://github.com/Fundacion-Fulgor/EAMTA2026-VLSI),
[instalación oficial IHP](https://ihp-open-pdk-docs.readthedocs.io/en/latest/install/installation.html).
