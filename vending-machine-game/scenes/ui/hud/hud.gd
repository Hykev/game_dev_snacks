extends CanvasLayer
## HUD al caminar: punto de mira, texto de interacción, dinero (arriba a la
## derecha) e inventario (abajo al centro), como en la sección 11 del GDD.
##
## Nunca pregunta nada en _process: solo reacciona a señales del EventBus,
## así no sabe ni le importa quién las emite.

@onready var _crosshair: Label = %Crosshair
@onready var _prompt_label: Label = %PromptLabel
@onready var _money_label: Label = %MoneyLabel
@onready var _inventory_label: Label = %InventoryLabel

# Nombre de la tecla asignada a "interact" (ej. "E"). Se lee del Input Map
# en vez de escribir "E" fijo, para que respete si el jugador la reasigna.
var _interact_key_name := ""


func _ready() -> void:
	_interact_key_name = _get_action_key_name("interact")
	_prompt_label.hide()
	EventBus.interaction_prompt_changed.connect(_on_interaction_prompt_changed)
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.inventory_changed.connect(_on_inventory_changed)
	EventBus.player_mode_changed.connect(_on_player_mode_changed)
	# Valores iniciales: leemos una vez al arrancar; después, solo señales.
	_on_money_changed(GameState.money)
	_on_inventory_changed()


## El punto de mira solo tiene sentido al caminar (GDD 11: en la mesa no hay).
func _on_player_mode_changed(mode: int) -> void:
	_crosshair.visible = mode == Player.Mode.WALK


func _on_money_changed(amount: int) -> void:
	_money_label.text = "$%d" % amount


## Arma el texto de la barra: «1: Lazy's ×2   2: —   3: —».
## Más adelante será una fila de casillas con íconos.
func _on_inventory_changed() -> void:
	var parts: PackedStringArray = []
	var inventory := GameState.get_inventory()
	for i in inventory.size():
		var slot := inventory[i]
		if slot.is_empty():
			parts.append("%d: —" % (i + 1))
		else:
			var snack := Database.get_snack(slot["snack_id"])
			parts.append("%d: %s ×%d" % [i + 1, snack.display_name, slot["count"]])
	_inventory_label.text = "   ".join(parts)


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
