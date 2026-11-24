extends StaticBody3D
## La máquina expendedora en el mundo 3D (por ahora, un bloque gris).
##
## No sabe nada del panel de compra ni del dinero: al usarla solo anuncia
## por EventBus que se abrió, y la UI responde. Así el mundo 3D no depende
## de la interfaz (señales hacia arriba).

@onready var _interactable: Interactable = $Interactable


func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)


func _on_interacted(_by: Node) -> void:
	EventBus.vending_machine_opened.emit()
