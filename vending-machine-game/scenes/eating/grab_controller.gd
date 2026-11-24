class_name GrabController
extends Node3D
## El cursor de la mesa: qué señala y cómo se mueve lo que se agarra.
##
## Es el ÚNICO lugar de la mesa que lee el ratón: todo lo demás pide la
## "posición de cursor" aquí. Cuando haya soporte de control, solo este
## script cambia (un cursor virtual movido con el stick) y la mesa sigue
## igual (GDD 10).
##
## El nodo se coloca justo a la altura de la superficie de la mesa: su
## posición y su eje Y definen el plano donde "cae" el cursor.

## Cámara fija de la mesa, desde donde sale el rayo del cursor.
@export var camera: Camera3D

@export_group("Agarrar")
## Altura sobre la mesa a la que flota el snack agarrado.
@export var hold_height: float = 0.25
## Qué tan fuerte persigue el snack al cursor. Alto = pegado; bajo = suave.
@export var follow_strength: float = 15.0
## Velocidad máxima (m/s) del snack agarrado: evita que salga disparado.
@export var max_follow_speed: float = 6.0
## Rectángulo (ancho, fondo) alrededor de este nodo donde puede moverse el
## snack agarrado, para que no se pueda arrastrar fuera de la mesa.
@export var bounds_size := Vector2(1.4, 0.75)

# Largo del rayo que busca snacks bajo el cursor.
const PICK_RAY_LENGTH := 5.0

## El snack agarrado ahora (null si ninguno). Solo lectura desde fuera.
var held_body: SnackBody:
	get:
		return _held_body

var _held_body: SnackBody = null


## Posición del cursor en pantalla. Hoy es el ratón; mañana, un cursor
## virtual para control.
func get_cursor_screen_position() -> Vector2:
	return get_viewport().get_mouse_position()


## Punto 3D (global) donde el rayo del cursor cruza el plano de la mesa,
## o null si apunta fuera (por ejemplo, hacia el techo).
func get_cursor_table_point() -> Variant:
	var screen_pos := get_cursor_screen_position()
	var ray_origin := camera.project_ray_origin(screen_pos)
	var ray_dir := camera.project_ray_normal(screen_pos)
	var table_plane := Plane(global_basis.y.normalized(), global_position)
	return table_plane.intersects_ray(ray_origin, ray_dir)


## El snack bajo el cursor, o null. Usa el motor de física, así que solo
## debe llamarse desde _physics_process (ahí el espacio físico es seguro).
func get_snack_under_cursor() -> SnackBody:
	var screen_pos := get_cursor_screen_position()
	var from := camera.project_ray_origin(screen_pos)
	var to := from + camera.project_ray_normal(screen_pos) * PICK_RAY_LENGTH
	var query := PhysicsRayQueryParameters3D.create(from, to)
	# Solo cuerpos: ignoramos áreas como el Interactable de la mesa.
	query.collide_with_areas = false
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return hit.get("collider") as SnackBody


func start_grab(body: SnackBody) -> void:
	_held_body = body


func release() -> void:
	_held_body = null


func _physics_process(_delta: float) -> void:
	if _held_body == null:
		return
	# Si el snack desapareció (se terminó), soltamos la referencia.
	if not is_instance_valid(_held_body):
		_held_body = null
		return
	var point: Variant = get_cursor_table_point()
	if point == null:
		return
	var target: Vector3 = _clamp_to_bounds(point) + global_basis.y * hold_height
	# No teletransportamos el snack: le damos una velocidad hacia el punto.
	# Así sigue chocando con los demás y la física no "explota" (GDD 14).
	var to_target := target - _held_body.global_position
	_held_body.sleeping = false
	_held_body.linear_velocity = (to_target * follow_strength).limit_length(max_follow_speed)
	# Frenar el giro para que no dé vueltas como loco en el aire.
	_held_body.angular_velocity *= 0.8


# Mantiene el punto dentro del rectángulo de la mesa (en coordenadas
# locales de este nodo, por si la mesa está girada).
func _clamp_to_bounds(point: Vector3) -> Vector3:
	var local := to_local(point)
	var half := bounds_size * 0.5
	local.x = clampf(local.x, -half.x, half.x)
	local.z = clampf(local.z, -half.y, half.y)
	return to_global(local)
