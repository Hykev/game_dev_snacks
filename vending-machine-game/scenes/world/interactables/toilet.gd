extends StaticBody3D
## El inodoro: vacía la llenura (GDD 5.4).
##
## Al usarlo pide por EventBus que el jugador se siente (modo BAÑO). Mientras
## el jugador siga sentado, le PIDE a GameState que baje la llenura poco a
## poco hasta vaciarla en `empty_duration` segundos. Si el jugador se
## levanta antes (Q), se detiene y la llenura queda donde iba.

## Segundos para vaciar la barra completa, sin importar cuánta haya.
## La mejora «Tripas Express» lo bajará (vía Stats) hasta 1 s.
@export var empty_duration: float = 8.0

@onready var _interactable: Interactable = $Interactable

# true entre que se pidió sentarse y que el jugador entró al modo BAÑO.
var _waiting_for_player := false
# Llenura que se resta por segundo en este uso del baño.
var _drain_per_second := 0.0


func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)
	EventBus.player_mode_changed.connect(_on_player_mode_changed)
	# Solo trabaja cada frame mientras alguien está sentado.
	set_process(false)


func _on_interacted(_by: Node) -> void:
	_waiting_for_player = true
	EventBus.toilet_sit_requested.emit()


func _on_player_mode_changed(mode: int) -> void:
	if mode == Player.Mode.BATHROOM and _waiting_for_player:
		_waiting_for_player = false
		# Velocidad fija para este uso: toda la barra en empty_duration.
		_drain_per_second = GameState.fullness / empty_duration
		set_process(true)
		if is_zero_approx(GameState.fullness):
			_finish()
	elif mode != Player.Mode.BATHROOM:
		# Se levantó (o nunca se sentó): dejar de vaciar.
		_waiting_for_player = false
		set_process(false)


func _process(delta: float) -> void:
	GameState.reduce_fullness(_drain_per_second * delta)
	if is_zero_approx(GameState.fullness):
		_finish()


func _finish() -> void:
	set_process(false)
	EventBus.toilet_finished.emit()
