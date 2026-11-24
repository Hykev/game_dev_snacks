extends StaticBody3D
## La cama: «E · Dormir». Solo pide dormir; DayCycle decide qué pasa
## (confirmación si es temprano, resumen, día siguiente).

@onready var _interactable: Interactable = $Interactable


func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)


func _on_interacted(_by: Node) -> void:
	EventBus.sleep_requested.emit()
