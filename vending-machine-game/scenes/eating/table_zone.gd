class_name TableZone
extends MeshInstance3D
## Un recuadro sobre la mesa (zona de comer o de tazos) que brilla al pasar
## el cursor encima (GDD 5.3).
##
## Usa un PlaneMesh: su tamaño en el Inspector define el área de la zona.
## No usa física: para saber si el cursor está encima basta comparar el
## punto con el tamaño del plano.

enum Kind { EAT, TAZO }

## Qué tipo de zona es: la mesa decide qué permitir en cada una.
@export var kind: Kind = Kind.EAT
## Color normal (semitransparente) y al pasar el cursor.
@export var base_color := Color(1, 1, 1, 0.12)
@export var highlight_color := Color(1, 1, 1, 0.35)

# Material propio, creado aquí para que cada zona brille por separado.
var _material := StandardMaterial3D.new()


func _ready() -> void:
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.albedo_color = base_color
	material_override = _material


func set_highlighted(highlighted: bool) -> void:
	_material.albedo_color = highlight_color if highlighted else base_color


## ¿El punto global cae dentro del recuadro? Se pasa a coordenadas locales
## para que funcione aunque la mesa esté girada.
func contains_global_point(point: Vector3) -> bool:
	var local := to_local(point)
	var half := (mesh as PlaneMesh).size * 0.5
	return absf(local.x) <= half.x and absf(local.z) <= half.y


## Posición global de la casilla `index` en una cuadrícula de
## `columns` × `rows` sobre la zona. La casilla 0 es la más cercana a la
## cámara y a la izquierda; se llena por filas hacia el fondo.
func get_slot_position(index: int, columns: int, rows: int) -> Vector3:
	var size := (mesh as PlaneMesh).size
	var cell := Vector2(size.x / columns, size.y / rows)
	var column := index % columns
	var row := index / columns
	var local := Vector3(
		-size.x * 0.5 + (column + 0.5) * cell.x,
		0.0,
		size.y * 0.5 - (row + 0.5) * cell.y)
	return to_global(local)


## Un punto al azar sobre la zona, a `height` metros de altura: desde ahí se
## sueltan los snacks para que caigan con física.
func get_drop_point(height: float) -> Vector3:
	var half := (mesh as PlaneMesh).size * 0.5 * 0.6  # 0.6: lejos de los bordes
	var local := Vector3(randf_range(-half.x, half.x), height, randf_range(-half.y, half.y))
	return to_global(local)
