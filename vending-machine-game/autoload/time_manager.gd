extends Node
## TimeManager: el reloj del día.
##
## Avanza la hora del juego (1 s real = 3 min de juego), se puede pausar
## (menús y diálogos) y avisa por EventBus cuando pasan minutos y en las
## horas clave: 00:00 (sueño) y 02:00 (desmayo). El día jugable va de
## 08:00 a 02:00: 6 minutos reales (GDD 4).
##
## No hace: decidir qué pasa al dormir o desmayarse. Solo avisa; otros
## sistemas deciden cómo reaccionar.
##
## La hora se guarda como "minuto del día" desde las 00:00 del día actual.
## Después de medianoche sigue contando (24:30 = 1470) para que el día no
## "se reinicie" a las 00:00: el día termina al dormir, no a medianoche.

# TEMPORAL: valores de balance que se moverán a un BalanceConfig.tres.
const GAME_MINUTES_PER_SECOND := 3.0
const DAY_START_MINUTE := 8 * 60      # 08:00
const SLEEPY_MINUTE := 24 * 60        # 00:00 (del día siguiente)
const FAINT_MINUTE := 26 * 60         # 02:00 (del día siguiente)

## Minuto actual del día (decimal: avanza un poco cada frame).
var minute_of_day: float:
	get:
		return _minute_of_day

var _minute_of_day: float = DAY_START_MINUTE
# El reloj avanza solo si está corriendo (hay día en curso) y sin pausa.
var _running := false
var _paused := false


func _ready() -> void:
	# Por ahora la partida empieza directo en el día 1 a las 08:00. Cuando
	# exista el menú principal y el guardado, ellos decidirán cuándo empezar.
	start_day()


## Empieza un día nuevo a las 08:00 y pone el reloj en marcha.
func start_day() -> void:
	_minute_of_day = DAY_START_MINUTE
	_running = true
	EventBus.clock_changed.emit(get_whole_minute())
	EventBus.sleepy_changed.emit(false)


## Detiene el reloj (al dormir o desmayarse) hasta el próximo start_day().
func stop() -> void:
	_running = false


## Pausa o reanuda (menú de pausa, diálogos). El teléfono NO pausa (GDD 4).
func set_paused(paused: bool) -> void:
	_paused = paused


func is_running() -> bool:
	return _running and not _paused


func get_whole_minute() -> int:
	return floori(_minute_of_day)


## Hora legible "HH:MM" (después de medianoche vuelve a 00, 01…).
func get_clock_text() -> String:
	var minute := get_whole_minute()
	return "%02d:%02d" % [(minute / 60) % 24, minute % 60]


func _process(delta: float) -> void:
	if not is_running():
		return
	var previous_minute := get_whole_minute()
	_minute_of_day = minf(_minute_of_day + GAME_MINUTES_PER_SECOND * delta, FAINT_MINUTE)
	var current_minute := get_whole_minute()
	if current_minute == previous_minute:
		return

	# Pasó al menos un minuto entero: avisar cuántos (para la digestión).
	EventBus.game_minutes_passed.emit(current_minute - previous_minute)
	EventBus.clock_changed.emit(current_minute)

	# Horas clave: se revisa si se CRUZÓ el umbral, por si un frame largo se
	# saltó el minuto exacto.
	if previous_minute < SLEEPY_MINUTE and current_minute >= SLEEPY_MINUTE:
		EventBus.sleepy_changed.emit(true)
	if current_minute >= FAINT_MINUTE:
		stop()
		EventBus.faint_time_reached.emit()
