class_name SeriesData
extends Resource
## Una serie de tazos (una por snack): sus tazos y, más adelante, el bono
## por completar su álbum (GDD 5.8).

@export var id: StringName
## Nombre de la serie (ej. "Couch Potatoes").
@export var display_name: String
## Tazos de la serie. En el juego final son 15 (5 Comunes, 4 Poco comunes,
## 3 Raros, 2 Épicos, 1 Legendario) más su Mal impreso y su Corrupto.
@export var tazos: Array[TazoData] = []


## Tazos de la serie con esa rareza (para que LootSystem elija uno).
func get_tazos_of_rarity(rarity: TazoData.Rarity) -> Array[TazoData]:
	var result: Array[TazoData] = []
	for tazo in tazos:
		if tazo.rarity == rarity:
			result.append(tazo)
	return result
