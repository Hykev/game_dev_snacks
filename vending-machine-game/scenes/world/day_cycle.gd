class_name DayCycle
extends Node
## Coordina el fin del día: dormir, desmayo y la mañana siguiente (GDD 4).
##
## Existe porque nadie más debe decidirlo: TimeManager solo lleva el reloj
## y avisa, GameState guarda el estado pero no toca la UI, y la cama solo
## pide dormir. Este nodo escucha esas señales y decide el orden:
##   1. ¿Se puede dormir? Nunca con la llenura alta (hay que ir al baño).
##      De noche siempre; antes, solo si ya no puede seguir el día (no le
##      alcanza para nada con stock en la máquina). Así nadie duerme días
##      enteros seguidos y pierde de golpe, pero tampoco se queda atorado.
##   2. ¿Es temprano? Pedir confirmación.
##   3. Detener el reloj; si fue desmayo, cobrar la multa.
##   4. Cerrar el día (GameState) y anunciar el resumen.
##   5. Al cerrar el resumen: día siguiente y reloj a las 08:00.
##   6. Autoguardar.

## Desde esta hora es «de noche»: se puede dormir aunque aún pueda comprar.
## Antes, solo si ya no puede comprar nada, y pidiendo confirmación
## (GDD 9: cama).
const NIGHT_START_MINUTE := 22 * 60
## Con más llenura que esto no se puede dormir (la barra ya está naranja).
## No hace falta estar en 0: la llenura que tenga pasa al día siguiente.
const MAX_FULLNESS_TO_SLEEP := 80.0

## Dónde despierta el jugador cada mañana (junto a la cama), también
## después de desmayarse.
@export var wake_point: Node3D


func _ready() -> void:
	EventBus.sleep_requested.connect(_on_sleep_requested)
	EventBus.sleep_confirmation_answered.connect(_on_sleep_confirmation_answered)
	EventBus.faint_time_reached.connect(_end_day.bind(true))
	EventBus.day_summary_closed.connect(_on_day_summary_closed)


func _on_sleep_requested() -> void:
	if GameState.fullness > MAX_FULLNESS_TO_SLEEP:
		EventBus.notification_requested.emit(tr("Estoy demasiado lleno para dormir. Mejor voy al baño."))
	elif TimeManager.get_whole_minute() >= NIGHT_START_MINUTE:
		_end_day(false)
	elif not GameState.can_still_buy_from_machine():
		# Ya no puede seguir el día (máquina vacía o sin dinero para lo que
		# queda): puede dormir temprano, pero se confirma por si aún quería
		# comer lo que trae, vender o ir al baño.
		EventBus.sleep_confirmation_requested.emit(TimeManager.get_clock_text())
	else:
		EventBus.notification_requested.emit(
			tr("Aún no tengo sueño: todavía puedo comprar en la máquina (o espera a las %s)")
			% TimeManager.format_clock(NIGHT_START_MINUTE))


func _on_sleep_confirmation_answered(accepted: bool) -> void:
	if accepted:
		_end_day(false)


func _end_day(fainted: bool) -> void:
	TimeManager.stop()
	if fainted:
		GameState.apply_faint_penalty()
	EventBus.day_ended.emit(GameState.end_day(fainted))


func _on_day_summary_closed() -> void:
	GameState.start_next_day()
	TimeManager.start_day()
	if wake_point != null:
		EventBus.player_place_requested.emit(wake_point)
	# Autoguardado al empezar cada día (GDD 4).
	SaveManager.save_game()
	EventBus.day_started.emit(GameState.day)
