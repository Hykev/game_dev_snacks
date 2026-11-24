class_name Player
extends CharacterBody3D
## El protagonista en primera persona: camina, corre y mira con el ratón.
##
## Por ahora solo existe el modo "caminar". Los demás modos del GDD (mesa,
## teléfono, baño…) se agregarán cuando existan esas estaciones, para no
## programar algo que todavía no se usa.
##
## Toda la entrada pasa por acciones del Input Map (move_*, sprint), nunca
## por teclas fijas, para poder reasignar teclas y soportar control después.

@export_group("Movimiento")
## Velocidad al caminar en metros por segundo. Más adelante la calculará
## Stats a partir de mejoras como "Piernas de Gelatina".
@export var walk_speed: float = 3.0
## Cuánto se multiplica la velocidad al mantener la acción "sprint".
@export var sprint_multiplier: float = 1.6
## Qué tan rápido se alcanza la velocidad deseada (m/s²). Un valor alto
## se siente "seco"; uno bajo, como si el piso estuviera resbaloso.
@export var acceleration: float = 20.0

@export_group("Cámara")
## Radianes que gira la cámara por cada píxel que se mueve el ratón.
## Más adelante vendrá del menú de opciones.
@export var mouse_sensitivity: float = 0.002
## Límite para mirar arriba/abajo; evita que la cámara dé la vuelta completa.
@export var max_pitch_degrees: float = 85.0

# La cabeza gira arriba/abajo; el cuerpo entero gira a los lados. Separarlos
# evita que el jugador se incline al mirar al piso.
@onready var _head: Node3D = %Head
# Rayo que sale de la cámara hacia el frente: lo que toque es lo que "miras".
# Su largo (target_position en la escena) es el alcance para usar objetos.
@onready var _interact_ray: RayCast3D = %InteractRay

# El Interactable que el jugador está mirando ahora (null si ninguno).
var _current_interactable: Interactable = null
# False mientras hay un panel abierto (máquina, después teléfono…): el
# jugador no camina, no mira y no interactúa. Es el inicio de los "modos"
# del GDD; cuando haya mesa y baño se volverá un modo con nombre.
var _controls_enabled := true


func _ready() -> void:
	# En primera persona el ratón debe quedar oculto y "atrapado" en la ventana.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# El rayo nace dentro de la cápsula del jugador: lo excluimos para que
	# nunca se detecte a sí mismo.
	_interact_ray.add_exception(self)
	EventBus.modal_ui_changed.connect(_on_modal_ui_changed)


## Un panel se abrió o cerró. El ratón se maneja SOLO aquí, en un lugar,
## para que dos sistemas nunca peleen por capturarlo o soltarlo.
func _on_modal_ui_changed(is_open: bool) -> void:
	_controls_enabled = not is_open
	if is_open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		# Ocultar «E · Comprar» mientras el panel está abierto.
		_set_current_interactable(null)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if not _controls_enabled:
		return

	# Mirar con el ratón: el movimiento del ratón no es una tecla, por eso se
	# lee como evento. Con control se agregarán acciones para el stick.
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion := event as InputEventMouseMotion
		rotate_y(-motion.relative.x * mouse_sensitivity)
		_head.rotate_x(-motion.relative.y * mouse_sensitivity)
		var max_pitch := deg_to_rad(max_pitch_degrees)
		_head.rotation.x = clampf(_head.rotation.x, -max_pitch, max_pitch)

	# Usar lo que estamos mirando. El jugador no sabe QUÉ hace el objeto:
	# solo le avisa, y el objeto decide (llamar hacia abajo).
	elif event.is_action_pressed("interact"):
		if _current_interactable != null:
			_current_interactable.interact(self)

	# TEMPORAL hasta que exista el menú de pausa: Esc (acción integrada
	# "ui_cancel") suelta el ratón, y un clic lo vuelve a capturar.
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.is_pressed() \
			and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	# Gravedad: get_gravity() usa la del proyecto, así no hay números mágicos.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# get_vector combina las 4 acciones en un vector 2D (x = lados,
	# y = adelante/atrás) y ya maneja la diagonal para no ir más rápido.
	var input_dir := Vector2.ZERO
	if _controls_enabled:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# Convertimos ese vector a la orientación actual del jugador: "adelante"
	# es hacia donde mira el cuerpo, no siempre el mismo eje del mundo.
	var direction := transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)

	var speed := walk_speed
	if Input.is_action_pressed("sprint"):
		speed *= sprint_multiplier

	# Solo se acelera en el plano horizontal; la vertical la maneja la gravedad.
	var target_velocity := direction * speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	move_and_slide()
	if _controls_enabled:
		_update_interaction_target()


## Revisa qué toca el rayo y, solo si cambió, lo anuncia por EventBus.
## Avisar únicamente en el cambio evita mandar la misma señal 60 veces por
## segundo; el HUD solo se entera cuando hay algo nuevo que mostrar.
func _update_interaction_target() -> void:
	var target: Interactable = null
	if _interact_ray.is_colliding():
		# Si el rayo toca una pared u otro objeto normal, esto queda en null.
		target = _interact_ray.get_collider() as Interactable
	_set_current_interactable(target)


func _set_current_interactable(target: Interactable) -> void:
	if target == _current_interactable:
		return
	_current_interactable = target
	var prompt: String = target.prompt_text if target != null else ""
	EventBus.interaction_prompt_changed.emit(prompt)
