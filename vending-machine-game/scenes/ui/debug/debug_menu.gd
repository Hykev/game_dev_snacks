extends CanvasLayer
## Menú de depuración (F1, acción "debug_menu"). GDD 7 y 14: dar dinero y
## Brillos, mover el tiempo, guardar/cargar y empezar de cero para probar el
## juego rápido.
##
## Solo existe en versiones de desarrollo: en el juego exportado se borra
## solo al iniciar (OS.is_debug_build() es false).
##
## Es la ÚNICA pieza que llama "a la fuerza" a los autoloads para cambiar
## estado; usa sus operaciones públicas, así que todo lo demás (HUD, mesa,
## repartidor) reacciona como si hubiera pasado en el juego.
##
## Pendiente: simular N snacks e imprimir estadísticas, forzar rareza.

const ACTION := &"debug_menu"

@onready var _root: Control = %Root
@onready var _buttons: VBoxContainer = %Buttons
@onready var _status_label: Label = %StatusLabel


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	_root.hide()
	_build_buttons()
	if not InputMap.has_action(ACTION):
		push_warning("Menú de depuración: falta la acción '%s' en el Input Map (F1)" % ACTION)


func _unhandled_input(event: InputEvent) -> void:
	if InputMap.has_action(ACTION) and event.is_action_pressed(ACTION):
		_set_open(not _root.visible)
		get_viewport().set_input_as_handled()
	elif _root.visible and event.is_action_pressed("ui_cancel"):
		_set_open(false)
		get_viewport().set_input_as_handled()


func _set_open(open: bool) -> void:
	_root.visible = open
	# Igual que los demás paneles: el jugador queda quieto y con el ratón.
	EventBus.modal_ui_changed.emit(open)
	_refresh_status()


# Cada botón es (texto, acción). Agregar una herramienta = una línea aquí.
func _build_buttons() -> void:
	var tools: Array = [
		["Dinero +$100", func() -> void: GameState.add_money(100)],
		["Dinero +$1000", func() -> void: GameState.add_money(1000)],
		["Brillos +50", func() -> void: GameState.add_shines(50)],
		["Llenura al tope", func() -> void: GameState.add_fullness(GameState.MAX_FULLNESS)],
		["Vaciar llenura", func() -> void: GameState.reduce_fullness(GameState.MAX_FULLNESS)],
		["Reponer la máquina", func() -> void: GameState.restock_machine()],
		["Reloj: pausar / reanudar", func() -> void: TimeManager.set_paused(not TimeManager.is_paused())],
		["Reloj ×1", func() -> void: TimeManager.time_scale = 1.0],
		["Reloj ×10", func() -> void: TimeManager.time_scale = 10.0],
		["Reloj ×60", func() -> void: TimeManager.time_scale = 60.0],
		["Adelantar 1 hora", func() -> void: TimeManager.advance_minutes(60)],
		["Saltar a las 23:55", _skip_to_late_night],
		["Guardar ahora", func() -> void: SaveManager.save_game()],
		["Volver al último guardado", func() -> void: SaveManager.reload_saved_game()],
		["Nueva partida (borra el guardado)", func() -> void: SaveManager.new_game()],
		["Borrar TODOS los guardados y cerrar", func() -> void: SaveManager.delete_all_saves_and_quit()],
	]
	for tool: Array in tools:
		var button := Button.new()
		button.text = tool[0]
		var action: Callable = tool[1]
		button.pressed.connect(func() -> void:
			action.call()
			_refresh_status())
		_buttons.add_child(button)


func _skip_to_late_night() -> void:
	var target := 23 * 60 + 55
	var minutes := target - TimeManager.get_whole_minute()
	if minutes > 0:
		TimeManager.advance_minutes(minutes)


func _refresh_status() -> void:
	if not is_instance_valid(_status_label):
		return
	_status_label.text = "Día %d · %s · reloj ×%d%s\n$%d · ✦%d · llenura %d\nGuardado: %s" % [
		GameState.day, TimeManager.get_clock_text(), int(TimeManager.time_scale),
		" (pausado)" if TimeManager.is_paused() else "",
		GameState.money, GameState.shines, int(GameState.fullness),
		"sí" if SaveManager.has_save(SaveManager.current_slot) else "no",
	]
