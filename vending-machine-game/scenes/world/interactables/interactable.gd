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


## El jugador lo llama al presionar la acción "interact" mientras lo mira.
func interact(by: Node) -> void:
	interacted.emit(by)
