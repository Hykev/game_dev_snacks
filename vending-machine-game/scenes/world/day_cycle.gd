class_name DayCycle
extends Node
## Coordina el fin del día: dormir, desmayo y la mañana siguiente (GDD 4).
##
## Existe porque nadie más debe decidirlo: TimeManager solo lleva el reloj
## y avisa, GameState guarda el estado pero no toca la UI, y la cama solo
## pide dormir. Este nodo escucha esas señales y decide el orden:
##   1. ¿Se puede dormir? Desde el mediodía, cuando el jugador quiera (aunque
##      quede stock o dinero: saltarse el día es su decisión, y el prestigio
##      casi no premiará perder a propósito). Nunca con la llenura alta.
##   2. ¿Es temprano? Pedir confirmación (por si fue sin querer).
##   3. Detener el reloj; si fue desmayo, cobrar la multa.
##   4. Cerrar el día (GameState) y anunciar el resumen.
##   5. Al cerrar el resumen: día siguiente y reloj a las 08:00.
##   6. Autoguardar.

## Antes de esta hora no se puede dormir: el día recién empieza.
const EARLIEST_SLEEP_MINUTE := 12 * 60
## Antes de esta hora, dormir pide confirmación (GDD 9: cama).
const CONFIRM_BEFORE_MINUTE := 22 * 60
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
	var minute := TimeManager.get_whole_minute()
	if GameState.fullness > MAX_FULLNESS_TO_SLEEP:
		EventBus.notification_requested.emit(tr("Estoy demasiado lleno para dormir. Mejor voy al baño."))
	elif minute < EARLIEST_SLEEP_MINUTE:
		EventBus.notification_requested.emit(
			tr("Es muy temprano para dormir (desde las %s)") % TimeManager.format_clock(EARLIEST_SLEEP_MINUTE))
	elif minute < CONFIRM_BEFORE_MINUTE:
		EventBus.sleep_confirmation_requested.emit(TimeManager.get_clock_text())
	else:
		_end_day(false)


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
