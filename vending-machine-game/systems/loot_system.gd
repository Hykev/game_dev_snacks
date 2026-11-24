class_name LootSystem
extends RefCounted
## Tiradas de botín: qué tazo sale al terminar un snack (GDD 5.5 y 7).
##
## Lógica PURA: solo funciones estáticas, sin nodos ni estado propio. Recibe
## todo lo que necesita (snack, suerte, generador aleatorio) y devuelve un
## resultado. Así se puede probar y simular miles de veces sin abrir el juego.
##
## Pendiente para pasos siguientes: anti-mala-racha, variantes (holográfico,
## mal impreso), fragmentos mágicos, Corruptos y el Error 67.

# TEMPORAL: números de balance que se moverán a un BalanceConfig.tres.
## Probabilidad de que un snack traiga premio. Sin premio sale Basura.
const BASE_PRIZE_CHANCE := 0.65
## Pesos base de cada rareza (GDD 5.5).
const BASE_WEIGHTS: Dictionary = {
	TazoData.Rarity.COMMON: 60.0,
	TazoData.Rarity.UNCOMMON: 25.0,
	TazoData.Rarity.RARE: 10.0,
	TazoData.Rarity.EPIC: 4.0,
	TazoData.Rarity.LEGENDARY: 1.0,
}
## Factor k de la fórmula de suerte: cuánto aprovecha cada rareza la suerte.
## Común no mejora con suerte (k = 0); Legendario es el que más (k = 3).
const LUCK_FACTORS: Dictionary = {
	TazoData.Rarity.COMMON: 0.0,
	TazoData.Rarity.UNCOMMON: 0.5,
	TazoData.Rarity.RARE: 1.0,
	TazoData.Rarity.EPIC: 2.0,
	TazoData.Rarity.LEGENDARY: 3.0,
}


## Pesos con suerte aplicada: w' = w · (1 + L · k). Con L = 0.5 (50 %),
## un Legendario pesa 2.5 veces más; un Común pesa igual.
static func get_rarity_weights(luck: float) -> Dictionary:
	var weights := {}
	for rarity: TazoData.Rarity in BASE_WEIGHTS:
		weights[rarity] = BASE_WEIGHTS[rarity] * (1.0 + luck * LUCK_FACTORS[rarity])
	return weights


## Elige una rareza según los pesos: como una ruleta donde cada rareza
## ocupa un pedazo proporcional a su peso.
static func roll_rarity(luck: float, rng: RandomNumberGenerator) -> TazoData.Rarity:
	var weights := get_rarity_weights(luck)
	var total := 0.0
	for weight: float in weights.values():
		total += weight
	var pick := rng.randf() * total
	for rarity: TazoData.Rarity in weights:
		pick -= weights[rarity]
		if pick < 0.0:
			return rarity
	return TazoData.Rarity.COMMON  # Solo por errores de redondeo.


## Tirada completa al terminar un snack: ¿hay premio? Si no, Basura. Si sí,
## una rareza y un tazo de esa rareza de la serie del snack.
static func roll_tazo(snack: SnackData, luck: float, rng: RandomNumberGenerator,
		junk_tazo: TazoData) -> TazoData:
	if snack.series == null or rng.randf() >= BASE_PRIZE_CHANCE:
		return junk_tazo
	var rarity := roll_rarity(luck, rng)
	var candidates := _find_candidates(snack.series, rarity)
	if candidates.is_empty():
		return junk_tazo
	return candidates[rng.randi_range(0, candidates.size() - 1)]


# Si la serie no tiene tazos de esa rareza (datos incompletos), baja de
# rareza hasta encontrar alguno, en vez de fallar.
static func _find_candidates(series: SeriesData, rarity: TazoData.Rarity) -> Array[TazoData]:
	var current := rarity
	while current >= TazoData.Rarity.COMMON:
		var candidates := series.get_tazos_of_rarity(current)
		if not candidates.is_empty():
			return candidates
		current = (current - 1) as TazoData.Rarity
	return []
