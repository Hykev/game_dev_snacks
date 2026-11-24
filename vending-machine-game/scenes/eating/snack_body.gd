class_name SnackBody
extends RigidBody3D
## Un snack físico sobre la mesa (por ahora, una caja gris con su nombre).
##
## Es el único objeto con física de la mesa (GDD: máx. ~6 a la vez). Los
## bocados no son objetos: solo un contador en este snack.
## No decide nada por su cuenta: la mesa le pide abrirse, dar un bocado o
## volver a la mesa.

## Lo usaron con «E · Recoger» estando fuera de la mesa. La mesa escucha
## esta señal y lo devuelve a la zona de comer.
signal pickup_requested

const CLOSED_COLOR := Color(0.6, 0.6, 0.6)
const OPEN_COLOR := Color(0.95, 0.85, 0.55)
const LABEL_COLOR := Color(1, 1, 1)
const LABEL_HOVER_COLOR := Color(1, 0.9, 0.2)

## Ficha del snack. Quien lo crea la asigna ANTES de agregarlo al árbol.
var snack: SnackData
var is_open := false
var bites_left := 0

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


func open() -> void:
	is_open = true
	bites_left = snack.bites
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
	_pickup_interactable.enabled = not on_table


## Lo deja quieto en `point` (para devolverlo a la mesa). Se resetean las
## velocidades para que no conserve la inercia de la caída.
func reset_at(point: Vector3) -> void:
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_position = point
	rotation = Vector3(0.0, randf() * TAU, 0.0)


func _on_pickup_interacted(_by: Node) -> void:
	pickup_requested.emit()


func _update_label() -> void:
	if snack == null:
		return
	if is_open:
		_label.text = "%s  %d/%d" % [snack.display_name, bites_left, snack.bites]
	else:
		_label.text = snack.display_name
