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
@onready var _clock_label: Label = %ClockLabel
@onready var _shipping_label: Label = %ShippingLabel
@onready var _toast_label: Label = %ToastLabel

# Segundos que se ve un aviso (toast) antes de desaparecer.
const TOAST_SECONDS := 3.0
# Animación del aviso actual: un aviso nuevo corta al anterior.
var _toast_tween: Tween

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
	EventBus.clock_changed.connect(_refresh_clock.unbind(1))
	_refresh_clock()
	EventBus.shipping_changed.connect(_refresh_shipping)
	_refresh_shipping()
	EventBus.notification_requested.connect(_show_toast)
	_toast_label.hide()
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


## Debajo del dinero: qué hay en la caja de envío y qué espera en la puerta.
## Se oculta si no hay nada.
func _refresh_shipping() -> void:
	var parts: PackedStringArray = []
	if GameState.get_shipping_box_count() > 0:
		parts.append(tr("Caja: %d ($%d)") % [GameState.get_shipping_box_count(), GameState.get_shipping_box_total()])
	if GameState.get_door_box_count() > 0:
		parts.append(tr("En la puerta: %d ($%d)") % [GameState.get_door_box_count(), GameState.get_door_box_total()])
	_shipping_label.text = "\n".join(parts)
	_shipping_label.visible = not parts.is_empty()


## Aviso corto a la derecha (GDD 11: notificaciones tipo toast). Aparece,
## espera TOAST_SECONDS y se desvanece.
func _show_toast(text: String) -> void:
	if _toast_tween != null and _toast_tween.is_valid():
		_toast_tween.kill()
	_toast_label.text = text
	_toast_label.modulate.a = 1.0
	_toast_label.show()
	_toast_tween = create_tween()
	_toast_tween.tween_interval(TOAST_SECONDS)
	_toast_tween.tween_property(_toast_label, "modulate:a", 0.0, 0.4)
	_toast_tween.tween_callback(_toast_label.hide)


## El punto de mira solo tiene sentido al caminar (GDD 11: en la mesa no
## hay). Sentado (mesa o baño) se recuerda cómo levantarse.
func _on_player_mode_changed(mode: int) -> void:
	_crosshair.visible = mode == Player.Mode.WALK
	var seated := mode == Player.Mode.TABLE or mode == Player.Mode.BATHROOM
	_hint_label.text = "%s · %s" % [_stand_up_key_name, tr("Levantarse")]
	_hint_label.visible = seated


## Arriba a la izquierda: «Día 4 · 15:30» (GDD 11). Los días para el
## próximo pago se agregarán con la deuda.
func _refresh_clock() -> void:
	_clock_label.text = tr("Día %d · %s") % [GameState.day, TimeManager.get_clock_text()]


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
