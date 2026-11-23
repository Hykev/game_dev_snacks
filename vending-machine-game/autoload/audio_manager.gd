extends Node
## AudioManager: reproduce música y efectos.
##
## Música por capas (caminar, mesa, racha de suerte), un pool de
## reproductores para efectos que suenan seguido (bocados) y buses de
## volumen para el menú de opciones.
##
## No hace: decidir CUÁNDO sonar. Responde a llamadas o señales de otros.

# Se llena cuando existan los primeros sonidos.
