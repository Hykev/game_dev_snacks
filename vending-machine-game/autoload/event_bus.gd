extends Node
## EventBus: el "tablero de anuncios" del juego.
##
## Aquí solo se DECLARAN las señales globales (ej. snack_bought, tazo_found,
## day_ended). Cualquier sistema puede emitirlas y cualquier escena puede
## escucharlas, sin que tengan que conocerse entre sí.
##
## No hace: lógica ni guarda datos. Si te dan ganas de poner una variable
## o una función aquí, probablemente pertenece a GameState u otro sistema.

# Las señales se irán agregando conforme se programe cada sistema.

# --- Economía e inventario (las emite GameState) ---

## El efectivo del jugador cambió; `amount` es el total nuevo, no la diferencia.
@warning_ignore("unused_signal")
signal money_changed(amount: int)

## Algo cambió en el inventario (se agregó o quitó un snack). Quien escuche
## pide a GameState el estado actual en vez de recibir una copia aquí.
@warning_ignore("unused_signal")
signal inventory_changed()

# --- Interacción ---

## El jugador empezó a mirar algo usable (prompt_text = "Sentarse", "Dormir"…)
## o dejó de mirarlo (prompt_text vacío). El HUD la usa para mostrar u ocultar
## la ayuda del centro de la pantalla.
@warning_ignore("unused_signal")
signal interaction_prompt_changed(prompt_text: String)
