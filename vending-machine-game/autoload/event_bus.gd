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

## Cambió el stock de alguna casilla de la máquina (compra o reabastecido).
@warning_ignore("unused_signal")
signal machine_stock_changed()

# --- Interacción y UI ---

## El jugador usó la máquina expendedora; el panel de compra se abre.
@warning_ignore("unused_signal")
signal vending_machine_opened()

## Se abrió (true) o cerró (false) un panel que necesita el ratón (máquina,
## y después teléfono, álbum…). El jugador lo usa para dejar de moverse y
## soltar o capturar el ratón.
@warning_ignore("unused_signal")
signal modal_ui_changed(is_open: bool)

# --- Comer (las emite la mesa) ---

## Se abrió un snack sobre la mesa (lo usarán el tutorial y el audio).
@warning_ignore("unused_signal")
signal snack_opened(snack_id: StringName)

## Se dio un bocado. `bites_left` = bocados que quedan en ese snack.
## La llenura (paso 6) escuchará esta señal.
@warning_ignore("unused_signal")
signal snack_bitten(snack_id: StringName, bites_left: int)

## Se terminó un snack (el premio lo tira GameState.resolve_finished_snack).
@warning_ignore("unused_signal")
signal snack_finished(snack_id: StringName)

# --- Tazos (las emite GameState) ---

## Salió un tazo al terminar un snack. Lo usarán la revelación, el audio y
## el tutorial.
@warning_ignore("unused_signal")
signal tazo_found(tazo_id: StringName)

## Cambiaron los tazos que esperan sobre la mesa; la mesa redibuja sus fichas.
@warning_ignore("unused_signal")
signal table_tazos_changed()

## Se guardó un tazo en la colección (los álbumes lo usarán).
@warning_ignore("unused_signal")
signal collection_changed()

## Los Brillos cambiaron; `amount` es el total nuevo.
@warning_ignore("unused_signal")
signal shines_changed(amount: int)

## La mesa pide mostrar la carta del tazo en la posición `index` de los
## tazos sobre la mesa. La carta (UI) responde.
@warning_ignore("unused_signal")
signal tazo_card_requested(index: int)

## La carta del tazo se cerró; la mesa vuelve a aceptar entrada.
@warning_ignore("unused_signal")
signal tazo_card_closed()

# --- Llenura y baño ---

## La llenura cambió (la emite GameState). El HUD dibuja la barra y el
## jugador camina más lento si está llena.
@warning_ignore("unused_signal")
signal fullness_changed(current: float, maximum: float)

## El inodoro pide que el jugador se siente (modo BAÑO).
@warning_ignore("unused_signal")
signal toilet_sit_requested()

## El inodoro terminó de vaciar la llenura; el jugador se levanta solo.
@warning_ignore("unused_signal")
signal toilet_finished()

# --- Jugador y estaciones ---

## La mesa pide que el jugador se siente y le pasa su cámara fija. La mesa
## no toca al jugador: el jugador decide cómo cambiar de modo.
@warning_ignore("unused_signal")
signal table_sit_requested(view_camera: Camera3D)

## El jugador cambió de modo. `mode` es un valor de Player.Mode (WALK,
## TABLE, PANEL…). El HUD lo usa para ocultar el punto de mira y la mesa
## para saber cuándo está activa.
@warning_ignore("unused_signal")
signal player_mode_changed(mode: int)

## El jugador empezó a mirar algo usable (prompt_text = "Sentarse", "Dormir"…)
## o dejó de mirarlo (prompt_text vacío). El HUD la usa para mostrar u ocultar
## la ayuda del centro de la pantalla.
@warning_ignore("unused_signal")
signal interaction_prompt_changed(prompt_text: String)
