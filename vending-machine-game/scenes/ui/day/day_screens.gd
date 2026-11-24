extends CanvasLayer
## Pantallas del fin del día: confirmar dormir temprano y el resumen.
##
## Solo muestra y responde: DayCycle decide cuándo pedir confirmación y
## cuándo terminó el día; esta UI avisa lo que eligió el jugador por
## EventBus. Mientras alguna está visible, el jugador queda quieto con el
## ratón libre (modal_ui_changed).
##
## El resumen será un «recibo de tienda» con sonido de impresora (GDD 11);
## por ahora es texto simple.

@onready var _confirm_panel: Control = %ConfirmPanel
@onready var _confirm_label: Label = %ConfirmLabel
@onready var _yes_button: Button = %YesButton
@onready var _no_button: Button = %NoButton
@onready var _summary_panel: Control = %SummaryPanel
@onready var _summary_label: Label = %SummaryLabel
@onready var _continue_button: Button = %ContinueButton


func _ready() -> void:
	_confirm_panel.hide()
	_summary_panel.hide()
	EventBus.sleep_confirmation_requested.connect(_on_sleep_confirmation_requested)
	EventBus.day_ended.connect(_on_day_ended)
	_yes_button.pressed.connect(_answer_confirmation.bind(true))
	_no_button.pressed.connect(_answer_confirmation.bind(false))
	_continue_button.pressed.connect(_on_continue_pressed)


func _on_sleep_confirmation_requested(clock_text: String) -> void:
	_confirm_label.text = tr("Son las %s. ¿Dormir ya y terminar el día?") % clock_text
	_confirm_panel.show()
	EventBus.modal_ui_changed.emit(true)


func _answer_confirmation(accepted: bool) -> void:
	_confirm_panel.hide()
	# Si dijo que no, vuelve a caminar. Si dijo que sí, sigue "modal" porque
	# enseguida aparece el resumen.
	if not accepted:
		EventBus.modal_ui_changed.emit(false)
	EventBus.sleep_confirmation_answered.emit(accepted)


func _on_day_ended(summary: Dictionary) -> void:
	var lines: PackedStringArray = []
	lines.append(tr("RESUMEN DEL DÍA %d") % summary["day"])
	if summary["fainted"]:
		lines.append(tr("Te desmayaste a las 02:00…"))
	lines.append("")
	lines.append(tr("Snacks comidos: %d") % summary["snacks_eaten"])
	lines.append(tr("Tazos encontrados: %d") % summary["tazos_found"])
	lines.append(tr("Ganado: $%d") % summary["money_earned"])
	lines.append(tr("Gastado: $%d") % summary["money_spent"])
	if summary["money_lost"] > 0:
		lines.append(tr("Pizza pedida dormido: −$%d") % summary["money_lost"])
	_summary_label.text = "\n".join(lines)
	_summary_panel.show()
	EventBus.modal_ui_changed.emit(true)


func _on_continue_pressed() -> void:
	_summary_panel.hide()
	EventBus.modal_ui_changed.emit(false)
	EventBus.day_summary_closed.emit()
