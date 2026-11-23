extends Node
## Database: el catálogo de todo el contenido del juego.
##
## Al iniciar carga una sola vez todos los .tres (snacks, tazos, series,
## mejoras, bebidas, capítulos) y los indexa por id, para pedirlos así:
## Database.get_snack("dor"). Así nadie hace load() a mitad del juego.
##
## No hace: modificar datos. Los .tres son de solo lectura en el juego;
## lo que el jugador TIENE vive en GameState.

# La carga e indexado se agregan cuando exista el primer Resource (SnackData).
