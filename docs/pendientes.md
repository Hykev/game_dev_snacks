# Pendientes del desarrollo

Lista viva de lo que falta o quedó temporal. Se actualiza al cerrar cada paso.
Lo marcado **TEMPORAL** en el código (comentarios `TEMPORAL:`) está explicado aquí.

## Estado actual (prototipo gris)

Hecho: pasos 1–6, 7a y 7b (proyecto, jugador, Interactable, máquina con panel 2D, mesa con zonas, agarrar/abrir/comer, tazos con LootSystem, carta con coleccionar/vender/reciclar, llenura y baño, reloj del día con digestión y sueño, cama con confirmación, desmayo a las 02:00, resumen del día y día siguiente).
El loop comprar → comer → tazo → vender → baño → dormir funciona en `scenes/world/test_room.tscn`. El fin del día lo coordina `DayCycle` (scenes/world/day_cycle.gd).

## Siguiente: paso 7c y 7d

- **7c `SaveManager`:** JSON en `user://` con número de versión, 3 ranuras, `meta.json` aparte para Ecos. Solo ids y números (GameState: dinero, Brillos, día, llenura, inventario, colección, tazos en mesa, stock, casillas activas, semilla del RNG). Autoguardado al cerrar el resumen del día (en `DayCycle`). Al guardar a mitad del día, lo que hay en la mesa vuelve al inventario.
- **7d Repartidor:** la venta deja de pagar al instante; los tazos van a la caja de envío y el repartidor paga cada 2 h de juego (GDD 5.8). Hoy `GameState.sell_table_tazo()` paga al instante (TEMPORAL).
- Decisiones tomadas que el GDD no define: sueño a las 00:00 = 70 % de velocidad; dormir conserva la llenura; al despertar (también tras desmayo) el jugador aparece junto a la cama (`Bed/WakePoint`); en el baño con el estómago vacío se queda sentado hasta Q.

## Después del paso 7

- **Máquina 3D (GDD 5.1):** reemplaza el panel 2D. Snacks visibles por casilla, hover con outline, clic izq/der al carrito, pantalla con la lista, pago con objetos (ranura/lector), bandeja que se vacía con E. Comprar ya no exigirá espacio en el inventario (los snacks esperan en la bandeja).
- **Outline real** compartido por mesa y máquina (hoy el snack señalado solo pone su nombre amarillo).
- **Sensación de la mesa:** agarrar la bolsa desde arriba y que cuelgue con física (péndulo) + mecánica de **agitar** (GDD 5.3).

## Tazos y colección

- Revelación animada del tazo (vuela a la cámara, gira, destello por rareza; GDD 3 Juice).
- Teclas C / V / R con el cursor sobre la ficha (requiere acciones nuevas en el Input Map).
- Más de 8 tazos en la mesa: pila al borde que se abre como lista (hoy no se ven los que pasan de 8).
- Contenido: series completas de 15 tazos (hoy 5 por serie, nombres provisionales).
- Sistemas pendientes de LootSystem: anti-mala-racha, holográfico, mal impreso, fragmentos mágicos, Corruptos y el Error 67.
- Álbumes en la repisa (la colección ya existe en `GameState`).

## UI y audio

- Notificaciones tipo toast: mesa llena, inventario lleno al recoger, lleno para comer, venta realizada.
- Gruñido del estómago al pasar de 80 de llenura (AudioManager).
- Periódico del baño (decorativo, GDD 5.4).

## Balance y datos

- Mover las constantes marcadas TEMPORAL a un `BalanceConfig.tres` (GameState, LootSystem, Economy, EatingStation).
- `Stats`: calcular límites desde mejoras (espacios de inventario, pila, snacks abiertos, velocidad, duración del baño, llenura máxima).
- Revisar el redondeo de precios en snacks baratos (un Común de Lazy's vale $2,40 y se paga $2).

## Técnico

- Mover `.gitattributes` a la raíz del repo (quita los avisos LF/CRLF de `CLAUDE.md` y `docs/`).
- Instalar GUT y convertir `tests/loot_simulation.gd` en pruebas automáticas de LootSystem y Economy.
- `main.tscn` con el mundo en un SubViewport de 640×360 (filtro nearest) y la UI encima.
- Medir rendimiento con el renderizador Mobile frente a Forward+ (objetivo: 60 FPS en gráfica integrada).
- Rendimiento: ya no hay límite de snacks colocados en la mesa (tirarlos es parte del chiste). El GDD presupuesta ~6 cuerpos con física; medir con muchos snacks (los quietos duermen y casi no cuestan).
- Baño: ajustar `SitPoint` y la altura de cámara sentada cuando exista el modelo final del inodoro.
