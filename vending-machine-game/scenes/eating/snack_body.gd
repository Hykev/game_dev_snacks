class_name SnackBody
extends RigidBody3D
## Un snack físico sobre la mesa (por ahora, una caja gris con su nombre).
##
## Es el único objeto con física de la mesa (GDD: máx. ~6 a la vez). Los
## bocados no son objetos: solo un contador en este snack.
## No decide nada por su cuenta: la mesa le pide abrirse, dar un bocado o
## volver a la mesa.

## Lo usaron con «E · Recoger» estando fuera de la mesa. La mesa escucha
## esta señal y lo guarda en el inventario (vía GameState).
signal pickup_requested

const CLOSED_COLOR := Color(0.6, 0.6, 0.6)
const OPEN_COLOR := Color(0.95, 0.85, 0.55)
const LABEL_COLOR := Color(1, 1, 1)
const LABEL_HOVER_COLOR := Color(1, 0.9, 0.2)

## Ficha del snack. Quien lo crea la asigna ANTES de agregarlo al árbol.
var snack: SnackData
var is_open := false
var bites_left := 0
## ¿Está sobre la mesa? Nace ahí (cae desde arriba de la zona de comer); la
## mesa lo actualiza cuando sale o entra de su superficie.
var is_on_table := true

@onready var _mesh: MeshInstance3D = $MeshInstance3D
@onready var _label: Label3D = $Label3D
@onready var _pickup_interactable: Interactable = $PickupInteractable

# Material propio para cambiar el color al abrirlo sin afectar a otros.
var _material := StandardMaterial3D.new()


func _ready() -> void:
	_material.albedo_color = CLOSED_COLOR
	_mesh.material_override = _material
	_update_label()
	# Nace sobre la mesa: no se puede "recoger" hasta que caiga fuera.
	_pickup_interactable.enabled = false
	_pickup_interactable.interacted.connect(_on_pickup_interacted)


## Abre el snack. `remaining_bites` = -1 para uno recién abierto (todos sus
## bocados); un número para uno que se guardó abierto en el inventario.
func open(remaining_bites: int = -1) -> void:
	is_open = true
	bites_left = snack.bites if remaining_bites < 0 else remaining_bites
	_material.albedo_color = OPEN_COLOR
	_update_label()


## Da un bocado. Devuelve true si con este bocado se terminó el snack.
func take_bite() -> bool:
	bites_left -= 1
	_update_label()
	return bites_left <= 0


## Resaltado simple mientras el cursor lo señala. El outline real llega
## junto con la máquina 3D.
func set_hovered(hovered: bool) -> void:
	_label.modulate = LABEL_HOVER_COLOR if hovered else LABEL_COLOR


## La mesa avisa si el snack está sobre ella. Fuera de la mesa se puede
## recoger caminando.
func set_on_table(on_table: bool) -> void:
	is_on_table = on_table
	_pickup_interactable.enabled = not on_table


func _on_pickup_interacted(_by: Node) -> void:
	pickup_requested.emit()


func _update_label() -> void:
	if snack == null:
		return
	if is_open:
		_label.text = "%s  %d/%d" % [snack.display_name, bites_left, snack.bites]
	else:
		_label.text = snack.display_name
