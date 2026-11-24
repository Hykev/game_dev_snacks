# Pendientes del desarrollo

Lista viva de lo que falta o quedó temporal. Se actualiza al cerrar cada paso.
Lo marcado **TEMPORAL** en el código (comentarios `TEMPORAL:`) está explicado aquí.

## Estado actual (prototipo gris)

Hecho: pasos 1–7 (proyecto, jugador, Interactable, máquina con panel 2D, mesa con zonas, agarrar/abrir/comer, tazos con LootSystem, carta con coleccionar/vender/reciclar, llenura y baño, reloj del día con digestión y sueño, cama con confirmación, desmayo a las 02:00, resumen del día y día siguiente, guardado/carga en JSON, caja de envío física (empacar en la mesa → llevarla en el inventario → puerta) con repartidor cada 2 h que deja el dinero en la bandeja, avisos en pantalla y menú de depuración F1 con control del reloj).
El loop completo comprar → comer → tazo → vender → baño → dormir → guardar funciona en `scenes/world/test_room.tscn`. El fin del día lo coordina `DayCycle` (scenes/world/day_cycle.gd).

## Siguiente: máquina 3D (último paso del prototipo gris)

- **Máquina 3D (GDD 5.1):** reemplaza el panel 2D (`scenes/ui/vending/`). Modo MÁQUINA con cámara fija frente a ella; snacks visibles por casilla; hover con **outline** y clic izq/der al carrito; pantalla con la lista; pago con objetos (ranura/lector); bandeja que se vacía con E. Comprar ya no exigirá espacio en el inventario (los snacks esperan en la bandeja). Reutilizar el cursor del `GrabController` de la mesa.
- El **outline** debe servir también para los snacks de la mesa (hoy solo ponen su nombre amarillo).

## Guardado y envíos (pendientes menores)

- `meta.json` para los Ecos (cuando existan) y menú principal con 3 ranuras (hoy siempre ranura 1, se carga sola al iniciar).
- Para empezar de cero: menú de depuración (F1) → «Nueva partida» (ranura actual) o «Borrar TODOS los guardados y cerrar» (todas las ranuras; cierra sin volver a guardar).
- **Menú de pausa (Esc):** aún no existe. Hoy Esc solo suelta el ratón y F1 puede pausar el reloj. Llegará con el menú principal (pausar el árbol de escenas, opciones, guardar y salir).
- Caja de envío: capacidad 5 (`GameState.SHIPPING_BOX_CAPACITY`, TEMPORAL). Futura rama de mejoras para agrandarla.
- Al cargar, el jugador aparece en su posición inicial de la escena (no se guardan posiciones).
- Envíos: falta la bandeja animada de la puerta, publicar desde la app TazoBay del teléfono, las notas del repartidor y las mejoras (Recolección a Domicilio, Repartidor Puntual, Venta Instantánea).
- Menú de depuración: falta simular N snacks con estadísticas y forzar rareza. Abrirlo sentado a la mesa te levanta al cerrarlo (usa el modo PANEL).
- Decisiones tomadas que el GDD no define: sueño a las 00:00 = 70 % de velocidad; dormir conserva la llenura; al despertar (también tras desmayo) el jugador aparece junto a la cama (`Bed/WakePoint`); en el baño con el estómago vacío se queda sentado hasta Q; el repartidor pasa en horas pares desde las 08:00 (10:00, 12:00…); «lleno» dura desde 100 hasta bajar de 90 (`FULL_RELEASE_FULLNESS`); dormir solo desde las 22:00, o antes si la máquina está vacía (con confirmación).

## Después de la máquina 3D

- **Sensación de la mesa:** agarrar la bolsa desde arriba y que cuelgue con física (péndulo) + mecánica de **agitar** (GDD 5.3).

## Tazos y colección

- Revelación animada del tazo (vuela a la cámara, gira, destello por rareza; GDD 3 Juice).
- Teclas C / V / R con el cursor sobre la ficha (requiere acciones nuevas en el Input Map).
- Más de 8 tazos en la mesa: pila al borde que se abre como lista (hoy no se ven los que pasan de 8).
- Contenido: series completas de 15 tazos (hoy 5 por serie, nombres provisionales).
- Sistemas pendientes de LootSystem: anti-mala-racha, holográfico, mal impreso, fragmentos mágicos, Corruptos y el Error 67.
- Álbumes en la repisa (la colección ya existe en `GameState`).

## UI y audio

- Avisos (ya existe `EventBus.notification_requested`): falta usarlo para inventario lleno al recoger snacks del piso.
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
