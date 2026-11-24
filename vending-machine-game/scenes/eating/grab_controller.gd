class_name GrabController
extends Node3D
## Convierte el cursor de la pantalla en un punto sobre la mesa.
##
## Es el ÚNICO lugar de la mesa que lee el ratón: todo lo demás pide la
## "posición de cursor" aquí. Cuando haya soporte de control, solo este
## script cambia (un cursor virtual movido con el stick) y la mesa sigue
## igual (GDD 10).
##
## El nodo se coloca en la escena justo a la altura de la superficie de la
## mesa: su posición y su eje Y definen el plano donde "cae" el cursor.
##
## En el paso 5c sumará agarrar y mover snacks.

## Cámara fija de la mesa, desde donde sale el rayo del cursor.
@export var camera: Camera3D


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
