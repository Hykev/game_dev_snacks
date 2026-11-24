extends StaticBody3D
## TEMPORAL, solo para probar el componente Interactable en test_room.
## Ejemplo del patrón que usarán la máquina, la cama, etc.: el objeto
## escucha la señal `interacted` de su hijo Interactable y decide qué hacer.

# Colores entre los que alterna el cubo cada vez que se usa.
const COLOR_A := Color(0.6, 0.6, 0.6)
const COLOR_B := Color(0.9, 0.75, 0.2)

@onready var _interactable: Interactable = $Interactable
@onready var _mesh: MeshInstance3D = $MeshInstance3D

# Material propio creado aquí (no con load()) para poder cambiarle el color
# sin afectar a otros cubos que comparten la misma malla.
var _material := StandardMaterial3D.new()
var _toggled := false


func _ready() -> void:
	_material.albedo_color = COLOR_A
	_mesh.material_override = _material
	_interactable.interacted.connect(_on_interacted)


func _on_interacted(by: Node) -> void:
	_toggled = not _toggled
	_material.albedo_color = COLOR_B if _toggled else COLOR_A
	print("Interactable usado por %s" % by.name)
