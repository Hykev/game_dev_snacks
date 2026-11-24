class_name SnackBody
extends RigidBody3D
## Un snack físico sobre la mesa (por ahora, una caja gris con su nombre).
##
## Es el único objeto con física de la mesa (GDD: máx. ~6 a la vez). Los
## bocados no serán objetos: solo un contador de este snack.

## Ficha del snack. Quien lo crea la asigna ANTES de agregarlo al árbol.
var snack: SnackData

@onready var _label: Label3D = $Label3D


func _ready() -> void:
	if snack != null:
		_label.text = snack.display_name
