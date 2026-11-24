# snack_game — instrucciones para Claude

Juego incremental en primera persona, 3D low poly con texturas pixel art, hecho en **Godot 4.7 (GDScript)**, solo PC (Windows, Linux, Steam Deck).
El protagonista come snacks de una máquina expendedora mágica para encontrar tazos, coleccionarlos, venderlos o reciclarlos, y pagar una deuda semanal.
El GDD completo está en `docs/GDD.md`; este archivo resume lo que importa para programar.

## Cómo trabajamos

- El desarrollador está aprendiendo Godot. **Antes de cada cambio, explica qué vas a hacer y por qué.** Después, resume qué cambió.
- Cambios pequeños, uno por vez. Nada de generar sistemas enteros de golpe.
- **Todo el código lleva comentarios en español** que expliquen la intención, no solo lo que hace la línea.
- Revisa cada cambio contra los principios de arquitectura de abajo. Si algo no encaja, dilo antes de programarlo.
- Commits pequeños con mensajes claros en español.
- El GDD (`docs/GDD.md`, ~28k tokens) se consulta antes de programar cada sistema, pero **nunca se lee entero**: busca con Grep la sección que necesitas y lee solo esas líneas.

## Principios de arquitectura (no romper)

1. **Datos fuera del código.** Snacks, tazos, series, mejoras, bebidas y capítulos son Resources (`.tres`) editables en el Inspector. Agregar contenido no debe requerir tocar código.
2. **Un solo dueño del estado.** Dinero, Brillos, Ecos, inventario, colección, mejoras, día y deuda viven en `GameState`. Las escenas leen y piden cambios; nunca guardan su propia copia.
3. **Llamar hacia abajo, señales hacia arriba.** Las señales globales se declaran en `EventBus`.
4. **La UI no consulta en `_process`.** Se actualiza al recibir señales.
5. **Lógica pura aparte.** `LootSystem`, `Economy`, `Stats` son funciones estáticas sin nodos, fáciles de probar.
6. **Tipado estático siempre**, nombres de código en inglés, comentarios en español, una clase por archivo, `class_name` en lo reutilizable.
7. **Entrada solo por acciones del Input Map** (nunca teclas fijas en código). La mesa lee una "posición de cursor", no el ratón directo, para poder soportar control/Steam Deck.
8. Referencias a nodos con `@onready` o `%NombreUnico`; nunca `get_node()` dentro de bucles. Nada de `load()` a mitad del juego.

## Autoloads (6)

| Autoload | Tarea | No hace |
| --- | --- | --- |
| `EventBus` | Solo declara señales globales | Lógica o datos |
| `Database` | Carga e indexa todos los `.tres` por id | Modificar datos |
| `GameState` | Estado del jugador y operaciones válidas; emite señales | Tocar escenas o UI |
| `TimeManager` | Reloj del día, pausa, eventos de hora | Decidir qué pasa al dormir |
| `SaveManager` | JSON en `user://` con versión; 3 ranuras; `meta.json` aparte para Ecos | Guardar nodos o posiciones físicas |
| `AudioManager` | Música por capas, pool de efectos, buses | Decidir cuándo sonar |

## Rendimiento

- Mundo 3D dentro de un `SubViewport` de 640×360 escalado sin suavizado (nearest); UI encima a resolución completa.
- Física solo en los snacks de la mesa (máx. ~6 `RigidBody3D`). Los tazos **no** usan física: se acomodan en casillas de la zona de tazos.
- Los bocados no son objetos: contador + partículas + sonido.
- Pools para objetos que aparecen seguido (números flotantes, partículas).
- Objetivo: 60 FPS en una PC modesta con gráfica integrada.

## Estructura de carpetas

```
res://
  autoload/        event_bus.gd, database.gd, game_state.gd, time_manager.gd, save_manager.gd, audio_manager.gd
  systems/         loot_system.gd, economy.gd, stats.gd, objective_system.gd
  data/
    resources/     definiciones de clase (snack_data.gd, tazo_data.gd, upgrade_data.gd…)
    snacks/  tazos/  upgrades/  chapters/   (*.tres)
  scenes/
    main/  world/  world/interactables/  player/  eating/  ui/
  assets/          models/  textures/  audio/music/  audio/sfx/  fonts/
  dialogue/        *.dialogue (plugin Dialogue Manager)
  localization/    strings.csv (todo texto visible pasa por tr())
  tests/           pruebas GUT de LootSystem y Economy
```

## Fase actual: prototipo gris

Meta: el loop completo con cubos grises (comprar → comer → tazo → vender → baño → dormir → guardar).
Orden sugerido: 1) proyecto y autoloads vacíos, 2) jugador que camina, 3) componente `Interactable` con E, 4) máquina expendedora (panel 2D temporal), 5) mesa con dos zonas (comer a la derecha, tazos a la izquierda), 5d) máquina 3D sin ventanas 2D (carrito, pago y bandeja; GDD 5.1), reutilizando el cursor y el outline de la mesa, 6) baño y llenura, 7) dormir y guardado.
