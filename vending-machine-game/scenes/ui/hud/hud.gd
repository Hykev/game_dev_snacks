extends CanvasLayer
## HUD al caminar. Por ahora: punto de mira y texto de interacción.
##
## Nunca pregunta nada en _process: solo reacciona a señales del EventBus,
## así no sabe ni le importa quién las emite.

@onready var _prompt_label: Label = %PromptLabel

# Nombre de la tecla asignada a "interact" (ej. "E"). Se lee del Input Map
# en vez de escribir "E" fijo, para que respete si el jugador la reasigna.
var _interact_key_name := ""


func _ready() -> void:
	_interact_key_name = _get_action_key_name("interact")
	_prompt_label.hide()
	EventBus.interaction_prompt_changed.connect(_on_interaction_prompt_changed)


func _on_interaction_prompt_changed(prompt_text: String) -> void:
	if prompt_text.is_empty():
		_prompt_label.hide()
		return
	# Formato del GDD: «E · Sentarse». tr() permite traducirlo después.
	_prompt_label.text = "%s · %s" % [_interact_key_name, tr(prompt_text)]
	_prompt_label.show()


## Devuelve el nombre legible de la primera tecla de una acción.
## Si la acción usa "physical keycode" (posición de la tecla), lo convierte
## a la letra real según la distribución del teclado del jugador.
func _get_action_key_name(action: StringName) -> String:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var key_event := event as InputEventKey
			var keycode := key_event.keycode
			if keycode == KEY_NONE:
				keycode = DisplayServer.keyboard_get_keycode_from_physical(key_event.physical_keycode)
			# Respaldo: si no se pudo traducir, usar la posición física tal cual.
			if keycode == KEY_NONE:
				keycode = key_event.physical_keycode
			return OS.get_keycode_string(keycode)
	return "?"
