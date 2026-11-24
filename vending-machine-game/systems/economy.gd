class_name Economy
extends RefCounted
## Precios del juego: cuánto vale vender o reciclar un tazo (GDD 5.8 y 7).
##
## Lógica PURA: solo funciones estáticas, sin nodos ni estado. Recibe los
## datos y devuelve un número, así se puede probar y balancear sin jugar.
##
## Pendiente: variantes (holográfico ×5, mal impreso ×10), bonos de álbum y
## de Corruptos, mejoras de TazoBay y el costo de mejoras C(n) = C·rⁿ.

# TEMPORAL: números de balance que se moverán a un BalanceConfig.tres.
## Múltiplo del precio del snack que vale cada rareza (GDD 5.5).
const SALE_MULTIPLIERS: Dictionary = {
	TazoData.Rarity.JUNK: 0.05,
	TazoData.Rarity.COMMON: 0.6,
	TazoData.Rarity.UNCOMMON: 1.5,
	TazoData.Rarity.RARE: 4.0,
	TazoData.Rarity.EPIC: 15.0,
	TazoData.Rarity.LEGENDARY: 60.0,
	TazoData.Rarity.CORRUPT: 30.0,
}
## Brillos que da reciclar cada rareza (GDD 5.8).
const RECYCLE_SHINES: Dictionary = {
	TazoData.Rarity.JUNK: 1,
	TazoData.Rarity.COMMON: 1,
	TazoData.Rarity.UNCOMMON: 3,
	TazoData.Rarity.RARE: 10,
	TazoData.Rarity.EPIC: 40,
	TazoData.Rarity.LEGENDARY: 150,
	TazoData.Rarity.CORRUPT: 100,
}
## Comisión inicial de TazoBay (la baja la mejora «Vendedor Verificado»).
const BASE_COMMISSION := 0.20


## Precio de venta: P = precio del snack × valor de rareza × bonos × (1 − comisión).
## Se redondea a pesos enteros (un Basura de un snack barato puede valer $0).
static func get_sale_price(tazo: TazoData, snack_price: int,
		commission: float = BASE_COMMISSION, bonus: float = 1.0) -> int:
	var multiplier: float = SALE_MULTIPLIERS.get(tazo.rarity, 0.0)
	return roundi(snack_price * multiplier * bonus * (1.0 - commission))


## Brillos que da reciclar este tazo.
static func get_recycle_shines(tazo: TazoData) -> int:
	return RECYCLE_SHINES.get(tazo.rarity, 0)
