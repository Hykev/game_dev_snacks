extends StaticBody3D
## El inodoro: vacía la llenura (GDD 5.4).
##
## Al usarlo pide por EventBus que el jugador se siente (modo BAÑO). Mientras
## el jugador siga sentado, le PIDE a GameState que baje la llenura a
## velocidad CONSTANTE: con menos llenura se termina antes. Si el jugador
## se levanta antes (Q), se detiene y la llenura queda donde iba.

## Segundos para vaciar la barra de lleno (100) a vacío (0). Con 50 tarda
## la mitad. La mejora «Tripas Express» lo bajará (vía Stats).
@export var full_empty_duration: float = 15.0

@onready var _interactable: Interactable = $Interactable
# Dónde queda el jugador sentado y dónde al levantarse (puntos fijos).
@onready var _sit_point: Marker3D = $SitPoint
@onready var _stand_point: Marker3D = $StandPoint

# true entre que se pidió sentarse y que el jugador entró al modo BAÑO.
var _waiting_for_player := false


func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)
	EventBus.player_mode_changed.connect(_on_player_mode_changed)
	# Solo trabaja cada frame mientras alguien está sentado.
	set_process(false)


func _on_interacted(_by: Node) -> void:
	_waiting_for_player = true
	EventBus.toilet_sit_requested.emit(_sit_point, _stand_point)


func _on_player_mode_changed(mode: int) -> void:
	if mode == Player.Mode.BATHROOM and _waiting_for_player:
		_waiting_for_player = false
		# Con el estómago vacío no hay nada que vaciar: se queda sentado
		# hasta que el jugador se levante con Q (no lo levanta al instante).
		set_process(not is_zero_approx(GameState.fullness))
	elif mode != Player.Mode.BATHROOM:
		# Se levantó (o nunca se sentó): dejar de vaciar.
		_waiting_for_player = false
		set_process(false)


func _process(delta: float) -> void:
	# Velocidad constante: la barra completa en full_empty_duration segundos.
	var drain_per_second := GameState.MAX_FULLNESS / full_empty_duration
	GameState.reduce_fullness(drain_per_second * delta)
	if is_zero_approx(GameState.fullness):
		_finish()


func _finish() -> void:
	set_process(false)
	EventBus.toilet_finished.emit()
