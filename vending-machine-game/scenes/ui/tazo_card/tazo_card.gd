extends CanvasLayer
## Carta de un tazo de la mesa: muestra sus datos y deja Coleccionar,
## Vender o Reciclar (GDD 5.8 y 11).
##
## La abre la señal tazo_card_requested (la emite la mesa). Para actuar le
## PIDE a GameState; nunca toca dinero, Brillos ni colección por su cuenta.
## Al cerrarse avisa con tazo_card_closed para que la mesa vuelva a
## aceptar entrada.
##
## Pendiente: teclas C / V / R (acciones del Input Map) y la animación de
## revelación del tazo.

## Nombre visible de cada rareza (pasa por tr() al mostrarse).
const RARITY_NAMES: Dictionary = {
	TazoData.Rarity.JUNK: "Basura",
	TazoData.Rarity.COMMON: "Común",
	TazoData.Rarity.UNCOMMON: "Poco común",
	TazoData.Rarity.RARE: "Raro",
	TazoData.Rarity.EPIC: "Épico",
	TazoData.Rarity.LEGENDARY: "Legendario",
	TazoData.Rarity.MAGIC: "Mágico",
	TazoData.Rarity.CORRUPT: "Corrupto",
}

@onready var _root: Control = %Root
@onready var _dimmer: ColorRect = %Dimmer
@onready var _code_label: Label = %CodeLabel
@onready var _name_label: Label = %NameLabel
@onready var _rarity_label: Label = %RarityLabel
@onready var _back_label: Label = %BackLabel
@onready var _status_label: Label = %StatusLabel
@onready var _collect_button: Button = %CollectButton
@onready var _sell_button: Button = %SellButton
@onready var _recycle_button: Button = %RecycleButton
@onready var _close_button: Button = %CloseButton

# Índice del tazo (en la lista de la mesa) que muestra la carta.
var _index := -1


func _ready() -> void:
	_root.hide()
	EventBus.tazo_card_requested.connect(open)
	_collect_button.pressed.connect(_on_collect_pressed)
	_sell_button.pressed.connect(_on_sell_pressed)
	_recycle_button.pressed.connect(_on_recycle_pressed)
	_close_button.pressed.connect(close)
	# Si el día termina (desmayo) con la carta abierta, se cierra.
	EventBus.day_ended.connect(func(_summary: Dictionary) -> void:
		if _root.visible:
			close())
	# Clic fuera de la carta (sobre el fondo oscuro) también la cierra.
	_dimmer.gui_input.connect(_on_dimmer_gui_input)


func open(index: int) -> void:
	var table_tazos := GameState.get_table_tazos()
	if index < 0 or index >= table_tazos.size():
		EventBus.tazo_card_closed.emit()
		return
	_index = index
	var tazo := Database.get_tazo(table_tazos[index]["tazo_id"])
	_code_label.text = tazo.code
	_name_label.text = tazo.display_name
	_rarity_label.text = tr(RARITY_NAMES[tazo.rarity])
	_rarity_label.modulate = TazoData.get_rarity_color(tazo.rarity)
	_back_label.text = "«%s»" % tr(tazo.back_text)

	# Estado de colección: el Basura no tiene álbum; los repetidos se marcan.
	var can_collect := GameState.can_collect_table_tazo(index)
	if tazo.rarity == TazoData.Rarity.JUNK:
		_status_label.text = tr("No va en ningún álbum")
	elif GameState.has_in_collection(tazo.id):
		_status_label.text = tr("Ya lo tienes")
	else:
		_status_label.text = tr("¡Nuevo para tu colección!")
	# GDD 5.8: si no se puede coleccionar, el botón queda en gris.
	_collect_button.disabled = not can_collect

	_sell_button.text = tr("Vender ($%d)") % GameState.get_table_tazo_sale_price(index)
	_recycle_button.text = tr("Reciclar (✦%d)") % Economy.get_recycle_shines(tazo)
	_root.show()


func close() -> void:
	_root.hide()
	_index = -1
	EventBus.tazo_card_closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if _root.visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _on_dimmer_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		close()


func _on_collect_pressed() -> void:
	GameState.collect_table_tazo(_index)
	close()


func _on_sell_pressed() -> void:
	GameState.sell_table_tazo(_index)
	close()


func _on_recycle_pressed() -> void:
	GameState.recycle_table_tazo(_index)
	close()
