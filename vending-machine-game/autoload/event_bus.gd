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

## El inodoro pide que el jugador se siente (modo BAÑO): `sit_point` es
## dónde queda sentado y `stand_point` dónde queda al levantarse.
@warning_ignore("unused_signal")
signal toilet_sit_requested(sit_point: Node3D, stand_point: Node3D)

## El inodoro terminó de vaciar la llenura; el jugador se levanta solo.
@warning_ignore("unused_signal")
signal toilet_finished()

# --- Reloj (las emite TimeManager) ---

## Cambió el minuto entero del reloj. `minute` cuenta desde las 00:00 del
## día en curso y pasa de 1440 después de medianoche (ver TimeManager).
@warning_ignore("unused_signal")
signal clock_changed(minute: int)

## Pasaron `minutes` minutos de juego enteros (casi siempre 1). Lo usa la
## digestión pasiva.
@warning_ignore("unused_signal")
signal game_minutes_passed(minutes: int)

## A las 00:00 al personaje le da sueño (true); al empezar el día se le
## quita (false).
@warning_ignore("unused_signal")
signal sleepy_changed(is_sleepy: bool)

## Llegaron las 02:00: el personaje se desmaya. El reloj ya se detuvo;
## quien escuche decide qué pasa (perder efectivo y terminar el día).
@warning_ignore("unused_signal")
signal faint_time_reached()

# --- Dormir y fin del día ---

## La cama pide dormir. DayCycle decide si hace falta confirmar.
@warning_ignore("unused_signal")
signal sleep_requested()

## DayCycle pide confirmar porque es temprano (antes de las 22:00).
@warning_ignore("unused_signal")
signal sleep_confirmation_requested(clock_text: String)

## El jugador respondió la confirmación de dormir.
@warning_ignore("unused_signal")
signal sleep_confirmation_answered(accepted: bool)

## Terminó el día. `summary` trae las cifras para el resumen (ver
## GameState.end_day()). La pantalla de resumen la muestra.
@warning_ignore("unused_signal")
signal day_ended(summary: Dictionary)

## El jugador cerró el resumen del día: empieza el siguiente.
@warning_ignore("unused_signal")
signal day_summary_closed()

## Empezó un día nuevo (08:00).
@warning_ignore("unused_signal")
signal day_started(day: int)

# --- Jugador y estaciones ---

## La mesa pide que el jugador se siente y le pasa su cámara fija y el punto
## donde debe quedar al levantarse. La mesa no toca al jugador: el jugador
## decide cómo cambiar de modo.
@warning_ignore("unused_signal")
signal table_sit_requested(view_camera: Camera3D, stand_point: Node3D)

## Pide colocar al jugador en `point` (posición y hacia dónde mira). Lo usa
## DayCycle para despertar junto a la cama.
@warning_ignore("unused_signal")
signal player_place_requested(point: Node3D)

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
