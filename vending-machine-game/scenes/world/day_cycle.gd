class_name DayCycle
extends Node
## Coordina el fin del día: dormir, desmayo y la mañana siguiente (GDD 4).
##
## Existe porque nadie más debe decidirlo: TimeManager solo lleva el reloj
## y avisa, GameState guarda el estado pero no toca la UI, y la cama solo
## pide dormir. Este nodo escucha esas señales y decide el orden:
##   1. ¿Se puede dormir? De noche siempre; antes, solo con la máquina vacía
##      (para que nadie duerma días enteros seguidos y pierda de golpe).
##   2. ¿Es temprano? Pedir confirmación.
##   3. Detener el reloj; si fue desmayo, cobrar la multa.
##   4. Cerrar el día (GameState) y anunciar el resumen.
##   5. Al cerrar el resumen: día siguiente y reloj a las 08:00.
##   6. Autoguardar.

## Desde esta hora es «de noche»: se puede dormir aunque la máquina tenga
## snacks. Antes, solo con la máquina vacía y pidiendo confirmación
## (GDD 9: cama).
const NIGHT_START_MINUTE := 22 * 60

## Dónde despierta el jugador cada mañana (junto a la cama), también
## después de desmayarse.
@export var wake_point: Node3D


func _ready() -> void:
	EventBus.sleep_requested.connect(_on_sleep_requested)
	EventBus.sleep_confirmation_answered.connect(_on_sleep_confirmation_answered)
	EventBus.faint_time_reached.connect(_end_day.bind(true))
	EventBus.day_summary_closed.connect(_on_day_summary_closed)


func _on_sleep_requested() -> void:
	if TimeManager.get_whole_minute() >= NIGHT_START_MINUTE:
		_end_day(false)
	elif GameState.is_machine_empty():
		# Ya se acabó lo del día: puede dormir temprano, pero se confirma por
		# si aún quería comer, vender o ir al baño.
		EventBus.sleep_confirmation_requested.emit(TimeManager.get_clock_text())
	else:
		EventBus.notification_requested.emit(
			tr("Aún no tengo sueño: la máquina todavía tiene snacks (o espera a las %s)") % _format_minute(NIGHT_START_MINUTE))


func _format_minute(minute: int) -> String:
	return "%02d:%02d" % [floori(minute / 60.0), minute % 60]


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
