class_name Interactable
extends Area3D
## Componente reutilizable: convierte cualquier objeto en algo que se usa con E.
##
## Se agrega como hijo del objeto (máquina, cama, baño, TV…) junto con su
## propio CollisionShape3D. Este componente NO decide qué pasa al usarlo:
## solo avisa con la señal `interacted`, y el script del objeto padre
## responde. Así todas las zonas del apartamento comparten la misma pieza y
## agregar una nueva es configurar datos, no programar un sistema.

## Se emite cuando el jugador lo usa. `by` es quien lo usó (el jugador).
signal interacted(by: Node)

## Texto de la acción que se muestra en pantalla ("Sentarse", "Dormir").
## Pasa por tr() en el HUD, así que también sirve como clave de traducción.
@export var prompt_text: String = "Usar"

## Si el rayo del jugador atraviesa varios Interactable a la vez (un snack
## caído dentro del área de la mesa), gana el de prioridad más alta.
## Objetos chicos y puntuales (snacks) deben tener más que zonas grandes.
@export var interact_priority: int = 0

## Si es false, el rayo del jugador no lo detecta (no muestra «E · …»).
## Sirve para objetos que solo a veces se pueden usar, como un snack que
## solo se "recoge" cuando está en el piso.
@export var enabled: bool = true:
	set(value):
		enabled = value
		if is_node_ready():
			_apply_enabled()

# Capas de colisión originales: apagarlas (0) lo hace invisible al rayo.
var _original_layer: int = 0


func _ready() -> void:
	_original_layer = collision_layer
	_apply_enabled()


func _apply_enabled() -> void:
	collision_layer = _original_layer if enabled else 0


## El jugador lo llama al presionar la acción "interact" mientras lo mira.
func interact(by: Node) -> void:
	interacted.emit(by)
