class_name TazoData
extends Resource
## Ficha de un tazo coleccionable: lo que ES, no si el jugador lo tiene.
##
## Cada tazo es un .tres en res://data/tazos/<serie>/. Database los indexa
## por `id`; la colección del jugador (en GameState) guarda solo ids.

## Rarezas del GDD (5.5). Mágico y Corrupto tienen sistemas propios y se
## usarán más adelante.
enum Rarity { JUNK, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, MAGIC, CORRUPT }

## Colores reservados para rareza (GDD 3). Ningún otro elemento del juego
## debe usarlos. Mágico (arcoíris) y Corrupto (parpadeo) serán shaders.
const RARITY_COLORS: Dictionary = {
	Rarity.JUNK: Color(0.45, 0.45, 0.45),
	Rarity.COMMON: Color(0.95, 0.95, 0.95),
	Rarity.UNCOMMON: Color(0.3, 0.85, 0.35),
	Rarity.RARE: Color(0.25, 0.5, 1.0),
	Rarity.EPIC: Color(0.65, 0.3, 0.9),
	Rarity.LEGENDARY: Color(1.0, 0.55, 0.1),
	Rarity.MAGIC: Color(1.0, 0.4, 0.8),
	Rarity.CORRUPT: Color(0.1, 0.1, 0.1),
}

## Clave única (ej. &"lzy_01"). El guardado usa este id, nunca el nombre.
@export var id: StringName
## Código impreso en el tazo (ej. "LZY-01").
@export var code: String
## Nombre del tazo (en inglés, como en el GDD).
@export var display_name: String
## Serie a la que pertenece (id de SeriesData); vacío para el Tazo Basura.
@export var series_id: StringName
@export var rarity: Rarity = Rarity.COMMON
## Frase del reverso. Pasa por tr() al mostrarse.
@export_multiline var back_text: String


static func get_rarity_color(value: Rarity) -> Color:
	return RARITY_COLORS.get(value, Color.WHITE)
