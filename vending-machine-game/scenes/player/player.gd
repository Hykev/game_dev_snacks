class_name Player
extends CharacterBody3D
## El protagonista en primera persona.
##
## Tiene un MODO activo (caminar, mesa, panel…). Solo el modo activo
## procesa entrada, y cambiar de modo cambia la cámara y la captura del
## ratón en UN solo lugar: _set_mode(). Así nunca hay dos sistemas peleando
## por el ratón o por cuál cámara está activa.
##
## Toda la entrada pasa por acciones del Input Map (move_*, sprint,
## interact, stand_up), nunca por teclas fijas.

## Modos del jugador. Se irán sumando TELÉFONO, MÁQUINA, DORMIR…
enum Mode {
	WALK,      ## Caminar por el apartamento.
	TABLE,     ## Sentado a la mesa: cámara fija, ratón libre.
	PANEL,     ## Un panel 2D abierto (temporal: el de la máquina).
	BATHROOM,  ## Sentado en el baño: no camina, pero puede mirar alrededor.
}

# Cuántos Interactable superpuestos revisa el rayo como máximo por frame.
const MAX_STACKED_INTERACTABLES := 4
# GDD 5.4: con la llenura al tope se camina a la mitad de velocidad.
const FULL_SPEED_MULTIPLIER := 0.5
# Altura de los ojos sentado (en el baño) y duración de la animación al
# sentarse o pararse. La altura de pie se lee de la escena al iniciar.
const SEATED_HEAD_HEIGHT := 1.1
const SIT_ANIMATION_TIME := 0.3

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
@onready var _camera: Camera3D = %Camera3D
# Rayo que sale de la cámara hacia el frente: lo que toque es lo que "miras".
# Su largo (target_position en la escena) es el alcance para usar objetos.
@onready var _interact_ray: RayCast3D = %InteractRay

var _mode: Mode = Mode.WALK
# El Interactable que el jugador está mirando ahora (null si ninguno).
var _current_interactable: Interactable = null
# Multiplicador de velocidad por llenura. Se actualiza solo cuando llega la
# señal fullness_changed, no se pregunta a GameState cada frame.
var _fullness_speed_multiplier := 1.0
# Altura de la cabeza de pie (la de la escena) y animación en curso.
var _standing_head_height := 0.0
var _head_tween: Tween


func _ready() -> void:
	# El rayo nace dentro de la cápsula del jugador: lo excluimos para que
	# nunca se detecte a sí mismo.
	_interact_ray.add_exception(self)
	_standing_head_height = _head.position.y
	EventBus.modal_ui_changed.connect(_on_modal_ui_changed)
	EventBus.table_sit_requested.connect(_on_table_sit_requested)
	EventBus.toilet_sit_requested.connect(_set_mode.bind(Mode.BATHROOM))
	EventBus.toilet_finished.connect(_on_toilet_finished)
	EventBus.fullness_changed.connect(_on_fullness_changed)
	_set_mode(Mode.WALK)


func _on_fullness_changed(current: float, maximum: float) -> void:
	_fullness_speed_multiplier = FULL_SPEED_MULTIPLIER if current >= maximum else 1.0


## El baño terminó solo: el jugador se levanta (si seguía sentado).
func _on_toilet_finished() -> void:
	if _mode == Mode.BATHROOM:
		_set_mode(Mode.WALK)


## Único lugar donde se cambia de modo: decide cámara, ratón y avisa.
## `view_camera` es la cámara fija de la estación (solo para MESA).
func _set_mode(new_mode: Mode, view_camera: Camera3D = null) -> void:
	_mode = new_mode
	match new_mode:
		Mode.WALK:
			_camera.make_current()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		Mode.TABLE:
			view_camera.make_current()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Mode.PANEL:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Mode.BATHROOM:
			# Misma cámara: solo se queda quieto mirando el "periódico".
			_camera.make_current()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# En el baño la cabeza baja como si estuviera sentado; en los demás modos
	# vuelve a la altura de pie.
	_animate_head_height(SEATED_HEAD_HEIGHT if new_mode == Mode.BATHROOM else _standing_head_height)
	# Fuera de CAMINAR no se interactúa con el mundo: ocultar «E · …».
	if new_mode != Mode.WALK:
		_set_current_interactable(null)
	EventBus.player_mode_changed.emit(new_mode)


## Mueve la cabeza (y con ella la cámara) a otra altura con una animación
## corta. Si ya está ahí, no hace nada.
func _animate_head_height(target_height: float) -> void:
	if is_equal_approx(_head.position.y, target_height):
		return
	# Cortar una animación anterior para que no peleen entre sí.
	if _head_tween != null and _head_tween.is_valid():
		_head_tween.kill()
	_head_tween = create_tween()
	_head_tween.tween_property(_head, "position:y", target_height, SIT_ANIMATION_TIME) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_modal_ui_changed(is_open: bool) -> void:
	_set_mode(Mode.PANEL if is_open else Mode.WALK)


## Una estación (la mesa) pidió que el jugador se siente y le pasó su cámara.
func _on_table_sit_requested(view_camera: Camera3D) -> void:
	_set_mode(Mode.TABLE, view_camera)


func _unhandled_input(event: InputEvent) -> void:
	match _mode:
		Mode.WALK:
			_handle_walk_input(event)
		Mode.TABLE:
			if event.is_action_pressed("stand_up"):
				_set_mode(Mode.WALK)
		Mode.PANEL:
			pass  # El panel maneja su propia entrada.
		Mode.BATHROOM:
			# Se puede mirar alrededor; Q se levanta antes de terminar.
			if event.is_action_pressed("stand_up"):
				_set_mode(Mode.WALK)
			else:
				_handle_look(event)


## Mirar con el ratón: el movimiento del ratón no es una tecla, por eso se
## lee como evento. Con control se agregarán acciones para el stick.
## Devuelve true si el evento era de mirar (ya se usó).
func _handle_look(event: InputEvent) -> bool:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion := event as InputEventMouseMotion
		rotate_y(-motion.relative.x * mouse_sensitivity)
		_head.rotate_x(-motion.relative.y * mouse_sensitivity)
		var max_pitch := deg_to_rad(max_pitch_degrees)
		_head.rotation.x = clampf(_head.rotation.x, -max_pitch, max_pitch)
		return true
	return false


func _handle_walk_input(event: InputEvent) -> void:
	if _handle_look(event):
		return

	# Usar lo que estamos mirando. El jugador no sabe QUÉ hace el objeto:
	# solo le avisa, y el objeto decide (llamar hacia abajo).
	if event.is_action_pressed("interact"):
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
	# Fuera de CAMINAR el vector queda en cero y el jugador frena solo.
	var input_dir := Vector2.ZERO
	if _mode == Mode.WALK:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# Convertimos ese vector a la orientación actual del jugador: "adelante"
	# es hacia donde mira el cuerpo, no siempre el mismo eje del mundo.
	var direction := transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)

	var speed := walk_speed * _fullness_speed_multiplier
	if Input.is_action_pressed("sprint"):
		speed *= sprint_multiplier

	# Solo se acelera en el plano horizontal; la vertical la maneja la gravedad.
	var target_velocity := direction * speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	move_and_slide()
	if _mode == Mode.WALK:
		_update_interaction_target()


## Revisa qué toca el rayo y, solo si cambió, lo anuncia por EventBus.
## Avisar únicamente en el cambio evita mandar la misma señal 60 veces por
## segundo; el HUD solo se entera cuando hay algo nuevo que mostrar.
func _update_interaction_target() -> void:
	# El rayo puede atravesar varios Interactable (son áreas, no paredes):
	# por ejemplo, un snack caído dentro del área grande de la mesa. Los
	# recorremos y nos quedamos con el de mayor prioridad. Un objeto sólido
	# (pared, mueble) detiene la búsqueda, como lo haría la vista.
	var best: Interactable = null
	var skipped: Array[CollisionObject3D] = []
	for i in MAX_STACKED_INTERACTABLES:
		if not _interact_ray.is_colliding():
			break
		var hit := _interact_ray.get_collider() as Interactable
		if hit == null:
			break
		if best == null or hit.interact_priority > best.interact_priority:
			best = hit
		# Ignorar este y volver a lanzar el rayo para ver qué hay detrás.
		_interact_ray.add_exception(hit)
		skipped.append(hit)
		_interact_ray.force_raycast_update()
	# Dejar el rayo como estaba para el próximo frame.
	for area in skipped:
		_interact_ray.remove_exception(area)
	_set_current_interactable(best)


func _set_current_interactable(target: Interactable) -> void:
	if target == _current_interactable:
		return
	_current_interactable = target
	var prompt: String = target.prompt_text if target != null else ""
	EventBus.interaction_prompt_changed.emit(prompt)
