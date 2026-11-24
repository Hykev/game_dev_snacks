class_name SnackData
extends Resource
## Ficha de un snack de la máquina: lo que ES, no lo que el jugador TIENE.
##
## Cada snack es un archivo .tres en res://data/snacks/ que se edita en el
## Inspector. Agregar un snack nuevo = crear otro .tres; no se toca código.
## Database los carga todos al iniciar y los indexa por `id`.
##
## Campos que llegarán después, cuando existan sus sistemas: la serie de
## tazos (SeriesData) y la escena 3D del envase.

## Los 5 tipos de envase del GDD. Cada uno tendrá su animación de abrir.
enum PackageType { BAG, TUBE, WRAPPER, BOX, EGG }

@export_group("Identidad")
## Clave única y corta (ej. &"lzy"). El guardado usa este id, nunca el nombre,
## así se puede renombrar o traducir un snack sin romper partidas guardadas.
@export var id: StringName
## Nombre visible. Las marcas parodia no se traducen (ver GDD sección 6).
@export var display_name: String
## Casilla fija en la máquina (A1…D4).
@export var slot_code: String
## Capítulo en el que aparece (1–5).
@export_range(1, 5) var chapter: int = 1

@export_group("Comer")
## Precio en pesos del juego ($).
@export var price: int = 5
## Cuántos bocados tiene el snack antes de terminarse.
@export_range(1, 50) var bites: int = 8
## Cuánto sube la barra de llenura (0–100) con cada bocado.
@export_range(0, 20) var fullness_per_bite: int = 2
## Tipo de envase: define la animación de abrir.
@export var package_type: PackageType = PackageType.BAG
