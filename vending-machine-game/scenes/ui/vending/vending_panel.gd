extends CanvasLayer
## Panel de compra de la máquina expendedora.
##
## Los botones se crean a partir de Database (uno por snack), así un snack
## nuevo aparece aquí sin tocar esta escena. Se actualiza solo al recibir
## señales de dinero, inventario o stock; nunca consulta en _process.
## Para comprar le PIDE a GameState; nunca cambia el dinero por su cuenta.

@onready var _root: Control = %Root
@onready var _grid: GridContainer = %SlotGrid
@onready var _money_label: Label = %MoneyLabel
@onready var _message_label: Label = %MessageLabel
@onready var _close_button: Button = %CloseButton

# Botón de cada snack, por id, para actualizarlo sin buscarlo en el árbol.
var _buttons: Dictionary[StringName, Button] = {}


func _ready() -> void:
	_root.hide()
	_build_buttons()
	_close_button.pressed.connect(close)
	EventBus.vending_machine_opened.connect(open)
	EventBus.money_changed.connect(_on_state_changed.unbind(1))
	EventBus.inventory_changed.connect(_on_state_changed)
	EventBus.machine_stock_changed.connect(_on_state_changed)
	# Si el día termina (desmayo a las 02:00) con el panel abierto, se oculta
	# sin avisar: la pantalla del resumen toma el control del ratón.
	EventBus.day_ended.connect(func(_summary: Dictionary) -> void: _root.hide())


func open() -> void:
	_message_label.text = ""
	_refresh()
	_root.show()
	EventBus.modal_ui_changed.emit(true)


func close() -> void:
	_root.hide()
	EventBus.modal_ui_changed.emit(false)


func _unhandled_input(event: InputEvent) -> void:
	# Esc cierra el panel. Marcamos el evento como usado para que el
	# jugador no lo reciba también.
	if _root.visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _build_buttons() -> void:
	for snack in Database.get_all_snacks():
		var button := Button.new()
		button.custom_minimum_size = Vector2(150, 96)
		# bind() le pasa el id al callback: cada botón sabe qué snack compra.
		button.pressed.connect(_on_slot_pressed.bind(snack.id))
		_grid.add_child(button)
		_buttons[snack.id] = button


func _on_state_changed() -> void:
	# Si está cerrado no vale la pena redibujar; open() refresca al abrir.
	if _root.visible:
		_refresh()


func _refresh() -> void:
	_money_label.text = tr("Dinero: $%d") % GameState.money
	for snack_id in _buttons:
		var snack := Database.get_snack(snack_id)
		var button := _buttons[snack_id]
		var status: String
		if not GameState.is_snack_unlocked(snack_id):
			status = tr("Bloqueado")
		else:
			var stock := GameState.get_stock(snack_id)
			status = tr("Agotado") if stock == 0 else tr("Quedan %d") % stock
		button.text = "%s · %s\n$%d\n%s" % [snack.slot_code, snack.display_name, snack.price, status]
		# Solo se deshabilita lo que nunca se puede comprar ahora mismo; si
		# falta dinero o espacio, el botón sigue activo y explica el motivo.
		button.disabled = not GameState.is_snack_unlocked(snack_id) or GameState.get_stock(snack_id) == 0


func _on_slot_pressed(snack_id: StringName) -> void:
	var snack := Database.get_snack(snack_id)
	match GameState.buy_snack(snack_id):
		GameState.BuyResult.OK:
			_message_label.text = tr("¡Compraste %s!") % snack.display_name
		GameState.BuyResult.NO_MONEY:
			_message_label.text = tr("No te alcanza.")
		GameState.BuyResult.NO_ROOM:
			_message_label.text = tr("Tu inventario está lleno.")
		GameState.BuyResult.SOLD_OUT:
			_message_label.text = tr("Agotado por hoy.")
		GameState.BuyResult.LOCKED:
			_message_label.text = tr("Casilla bloqueada.")
		_:
			_message_label.text = tr("Algo salió mal.")
