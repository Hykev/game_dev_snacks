extends Node
## TimeManager: el reloj del día.
##
## Avanza la hora del juego (1 s real = 3 min de juego), se pausa en menús
## y diálogos, y avisa por EventBus en las horas clave (08:00, 00:00, 02:00).
##
## No hace: decidir qué pasa al dormir o desmayarse. Solo avisa; otros
## sistemas deciden cómo reaccionar.

# El reloj se programa en el paso de dormir y guardado.
