extends SceneTree
## Simulador de LootSystem: tira muchos snacks y muestra qué salió.
##
## Sirve para revisar el balance sin jugar (GDD 7: "simular 1.000 snacks").
## Se ejecuta sin abrir el juego, desde la carpeta del proyecto:
##   godot --headless -s res://tests/loot_simulation.gd
## Cuando instalemos GUT, sus pruebas automáticas vivirán junto a este archivo.

const ROLLS := 100_000
const LUCK_VALUES: Array[float] = [0.0, 0.5, 1.0]


func _initialize() -> void:
	var snack := load("res://data/snacks/lazys.tres") as SnackData
	var junk := load("res://data/tazos/junk.tres") as TazoData
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345  # Semilla fija: resultados repetibles entre corridas.

	print("Simulando %d snacks de %s" % [ROLLS, snack.display_name])
	for luck in LUCK_VALUES:
		var counts := {}
		# Suma de lo que darían todos los tazos si se vendieran (sin comisión,
		# para comparar con el GDD: valor esperado ≈ 1,5 × precio del snack).
		var total_value := 0.0
		for i in ROLLS:
			var tazo := LootSystem.roll_tazo(snack, luck, rng, junk)
			counts[tazo.rarity] = counts.get(tazo.rarity, 0) + 1
			total_value += Economy.get_sale_price(tazo, snack.price * 100, 0.0) / 100.0
		var line := "suerte %3d%%:" % int(luck * 100)
		for rarity in TazoData.Rarity.values():
			if counts.has(rarity):
				var percent: float = 100.0 * counts[rarity] / ROLLS
				line += "  %s %.2f%%" % [TazoData.Rarity.keys()[rarity], percent]
		print(line)
		var average := total_value / ROLLS
		print("           valor esperado sin comisión: $%.2f = %.2f× el precio" % [average, average / snack.price])
	quit()
