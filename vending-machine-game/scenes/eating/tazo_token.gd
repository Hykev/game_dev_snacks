class_name TazoToken
extends Node3D
## La ficha de un tazo en la zona de tazos de la mesa (por ahora, un disco
## del color de su rareza con su código encima).
##
## No usa física (GDD): solo se muestra en su casilla. La mesa tiene un
## grupo fijo (pool) de fichas y las reutiliza mostrando u ocultando,
## en vez de crear y destruir nodos cada vez que sale un tazo.

@onready var _mesh: MeshInstance3D = $MeshInstance3D
@onready var _label: Label3D = $Label3D

# Material propio para pintar cada ficha de su color de rareza.
var _material := StandardMaterial3D.new()


func _ready() -> void:
	_mesh.material_override = _material


func show_tazo(tazo: TazoData) -> void:
	_material.albedo_color = TazoData.get_rarity_color(tazo.rarity)
	_label.text = tazo.code
	show()
