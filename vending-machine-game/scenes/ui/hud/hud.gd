extends CanvasLayer
## HUD al caminar: punto de mira, texto de interacción, dinero (arriba a la
## derecha), inventario (abajo al centro) y llenura (abajo a la izquierda),
## como en la sección 11 del GDD.
##
## Nunca pregunta nada en _process: solo reacciona a señales del EventBus,
## así no sabe ni le importa quién las emite.

# GDD 11: la barra de llenura cambia de color al pasar de 80.
const FULLNESS_WARNING := 80.0
const FULLNESS_COLOR_OK := Color(0.4, 0.85, 0.4)
const FULLNESS_COLOR_WARNING := Color(1.0, 0.6, 0.15)
const FULLNESS_COLOR_FULL := Color(0.9, 0.2, 0.2)

@onready var _crosshair: Label = %Crosshair
@onready var _prompt_label: Label = %PromptLabel
@onready var _money_label: Label = %MoneyLabel
@onready var _inventory_label: Label = %InventoryLabel
@onready var _fullness_bar: ProgressBar = %FullnessBar
@onready var _hint_label: Label = %HintLabel

# Nombres de las teclas de "interact" y "stand_up" (ej. "E", "Q"). Se leen
# del Input Map en vez de escribirlas fijas, para respetar si se reasignan.
var _interact_key_name := ""
var _stand_up_key_name := ""


func _ready() -> void:
	_interact_key_name = _get_action_key_name("interact")
	_stand_up_key_name = _get_action_key_name("stand_up")
	_prompt_label.hide()
	_hint_label.hide()
	EventBus.fullness_changed.connect(_on_fullness_changed)
	_on_fullness_changed(GameState.fullness, GameState.MAX_FULLNESS)
	EventBus.interaction_prompt_changed.connect(_on_interaction_prompt_changed)
	# Dinero y Brillos van en la misma etiqueta: cualquiera de las dos
	# señales la redibuja (unbind quita el argumento que no usamos).
	EventBus.money_changed.connect(_refresh_currencies.unbind(1))
	EventBus.shines_changed.connect(_refresh_currencies.unbind(1))
	EventBus.inventory_changed.connect(_on_inventory_changed)
	EventBus.player_mode_changed.connect(_on_player_mode_changed)
	# Valores iniciales: leemos una vez al arrancar; después, solo señales.
	_refresh_currencies()
	_on_inventory_changed()


## El punto de mira solo tiene sentido al caminar (GDD 11: en la mesa no
## hay). Sentado (mesa o baño) se recuerda cómo levantarse.
func _on_player_mode_changed(mode: int) -> void:
	_crosshair.visible = mode == Player.Mode.WALK
	var seated := mode == Player.Mode.TABLE or mode == Player.Mode.BATHROOM
	_hint_label.text = "%s · %s" % [_stand_up_key_name, tr("Levantarse")]
	_hint_label.visible = seated


## Barra de llenura: verde, naranja desde 80 y roja al tope.
## (El gruñido del estómago llegará con el AudioManager.)
func _on_fullness_changed(current: float, maximum: float) -> void:
	_fullness_bar.max_value = maximum
	_fullness_bar.value = current
	var color := FULLNESS_COLOR_OK
	if current >= maximum:
		color = FULLNESS_COLOR_FULL
	elif current >= FULLNESS_WARNING:
		color = FULLNESS_COLOR_WARNING
	_fullness_bar.modulate = color


## Arriba a la derecha: «$25   ✦ 4» (GDD 11).
func _refresh_currencies() -> void:
	_money_label.text = "$%d   ✦ %d" % [GameState.money, GameState.shines]


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
			if slot.has("bites_left"):
				# Abierto: ocupa el espacio solo; mostramos sus bocados.
				parts.append("%d: %s (%d/%d)" % [i + 1, snack.display_name, slot["bites_left"], snack.bites])
			else:
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
