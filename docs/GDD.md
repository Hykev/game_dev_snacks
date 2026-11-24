# GDD — InfiniteVM3000 (título provisional)

Documento de diseño de juego · Nov 21, 2026

## 1. Ficha del juego

Un incremental en primera persona donde comes snacks de una máquina expendedora mágica para encontrar tazos, venderlos o coleccionarlos, y pagar una deuda absurda antes de que la suerte te abandone. Meta: 4 h para terminar la historia y 7–9 h para completar todos los álbumes.

| Campo | Definición |
| --- | --- |
| Título provisional | InfiniteVM3000 (nombres en inglés propuestos en la sección 15) |
| Género | Incremental / idle activo con toques de colección y gestión |
| Perspectiva | Primera persona, 3D, un solo escenario (apartamento) |
| Jugadores | Un jugador, sin conexión |
| Plataforma | PC (Windows primero; Linux y Steam Deck con soporte de control) |
| Distribución | Steam, posible itch.io |
| Duración | Historia: \~4 h · 100 % de álbumes: 7–9 h |
| Tono | Humor absurdo, nostalgia de los tazos de los 90, cero realismo |
| Estética | 3D low poly con texturas pixel art y render a baja resolución |
| Motor y herramientas | Godot 4 (GDScript), Blender, FL Studio |
| Equipo | 1 persona |
| Referencias | Cookie Clicker, Scritchy Scratchy, Bills Must Be Paid, Raccoin, CloverPit |

**Pilares de diseño** (toda decisión nueva se mide contra estos cuatro):

1. **Cada bocado es una tirada de dados.** El momento de abrir la bolsa y ver qué sale es el corazón del juego; todo lo demás existe para repetirlo más rápido y con mejores probabilidades.
2. **Fricción que se compra.** Al inicio todo es manual y lento (caminar, cargar, ir al baño). Las mejoras eliminan esa fricción poco a poco hasta automatizar casi todo.
3. **Estímulo constante.** Sonidos, partículas, números que suben y un apartamento que cambia: el jugador siempre ve que progresa.
4. **Simple por dentro.** Un solo escenario, sistemas pequeños comunicados por señales y contenido definido en datos. Si algo no cabe en un sistema existente, se cuestiona antes de construirlo.

**Fuera de alcance** (para proteger el año de desarrollo): multijugador, consolas, mapas fuera del apartamento, NPCs caminando en 3D, voces grabadas, generación procedural de niveles.

## 2. Universo, historia y personajes

La historia es una excusa ligera y graciosa para el loop: deber dinero, comer para encontrar fragmentos de suerte y decidir al final qué hacer con ese poder. Se cuenta casi toda por llamadas, mensajes y la TV, así que no requiere cinemáticas.

### Contexto del universo

- Un mundo igual al nuestro, pero donde las marcas de snacks son parodias y en los 90 hubo una fiebre enorme por los tazos.
- **Crunchicorp**, la mega empresa de botanas, capturó en los 90 a un espíritu de la suerte y lo partió en fragmentos escondidos en tazos como campaña de marketing («¡Encuentra el Tazo Mágico!»). La moda pasó, la campaña se canceló y los fragmentos quedaron olvidados en una bodega.
- Esa bodega se remató. Entre lo vendido había una máquina expendedora vieja con el inventario intacto, que el protagonista compró a crédito en un impulso nocturno. Por eso debe tanto dinero y por eso dice en el tutorial «¿por qué me gasté tanto dinero en una máquina expendedora propia?».

### Personajes

| Personaje | Rol | Cómo aparece |
| --- | --- | --- |
| El protagonista | Treintañero sin trabajo, flojo pero optimista; habla en frases cortas e ingenuas | Primera persona; frases en burbuja de texto |
| El jefe | Lo despide en la primera escena; vuelve al final arrepentido | Solo llamadas |
| El Ente (Azar) | Espíritu de la suerte fragmentado; misterioso, teatral, un poco manipulador. Revela su nombre en el capítulo 3 | Llamadas, mensajes y la máquina (brilla cuando habla) |
| BanCruel | El banco que financió la máquina; cobra con mensajes pasivo-agresivos firmados por «Lic. Cobrano» | App del banco y SMS |
| El repartidor | Recoge los tazos vendidos; nunca se le ve, solo deja notas cada vez más raras | Notas en la puerta |
| El vecino | Golpea la pared si haces ruido de madrugada | Sonido + mensajes bajo la puerta (easter egg) |
| Mascotas de marcas | Personajes de los snacks parodia | Comerciales en la TV y arte de los tazos |

### Arco narrativo en 5 capítulos (1 capítulo = 1 semana de juego)

1. **Despedido** — Intro, tutorial, primer fragmento. El Ente instala las apps. Meta: primer pago al banco.
2. **La máquina despierta** — La máquina sube de nivel; llegan nuevas marcas. El Ente explica la historia de Crunchicorp a medias.
3. **Azar** — El Ente revela su nombre y que estuvo atrapado 30 años. Aparecen los tazos corruptos: Crunchicorp les metió un chip rastreador (defectuoso) para seguir la pista de los fragmentos.
4. **Crunchicorp llama** — Un agente de Crunchicorp ofrece comprar la máquina por una fortuna. Rechazar es la única opción jugable, pero plantea la duda de si confías en Azar.
5. **El último pago** — Pago final de la deuda y últimos fragmentos. Llega la decisión final.

### Finales

- **Final A · Devolver el poder:** Azar recupera su forma, cumple su palabra y te deja una vida llena de suerte. Créditos con el apartamento lujoso.
- **Final B · Quedarte el poder:** Te vuelves el nuevo espíritu atrapado en la máquina. Escena final: un nuevo inquilino despierta con una llamada… y la voz es la tuya.
- **Final C · El Trato (solo con el álbum corrupto completo):** le vendes a Azar a Crunchicorp. Te vuelves el nuevo director de la empresa y la última escena es un comercial de TV con tu cara como mascota.
- **Final secreto · 100 % de álbumes:** El jefe llama rogando que vuelvas a trabajar; puedes colgarle. Se desbloquea un tazo de oro del desarrollador.
- No existe final malo: perder una semana solo la reinicia (sección 4). Tras cualquier final hay **juego libre** para completar mejoras y álbumes.

## 3. Estética, arte y audio

Low poly con texturas pixel art, renderizado a baja resolución y escalado sin suavizado; la UI se dibuja aparte a resolución completa para que el texto se lea nítido. Esto se ve con personalidad y además es muy barato de procesar.

### Reglas visuales

| Elemento | Regla |
| --- | --- |
| Resolución interna 3D | 640×360 escalada ×3 a 1920×1080 con filtro *nearest* (opción en ajustes: 480×270 o 960×540) |
| Densidad de texturas | 32 px por metro en muebles, 64 px por metro en objetos que se ven de cerca (snacks, tazos, teléfono) |
| Polígonos | Objetos de mano < 300 triángulos; muebles < 1.500; apartamento completo < 40.000 |
| Paleta | Una paleta fija de 32–48 colores para todo el juego; los colores de rareza quedan reservados solo para rareza |
| Atlas | Snacks y tazos comparten un atlas de texturas y un solo material para reducir llamadas de dibujo |
| Iluminación | Luz principal horneada (LightmapGI) + 2–3 luces dinámicas sin sombras; la luz de la ventana cambia con la hora del día |
| Cámara | FOV 75 por defecto, ajustable; leve balanceo al caminar desactivable |

**Por qué renderizar a baja resolución si las texturas ya son pixel art.** No es un filtro encima: es dibujar la escena 3D con menos píxeles y agrandarla sin suavizado. Si se renderiza a 1080p, las texturas se ven pixeladas pero los bordes de los modelos, las sombras y la luz se ven en alta definición, y esa mezcla se nota «rara». Con resolución baja todo el cuadro comparte el mismo tamaño de píxel y además cuesta menos procesar. Es la técnica habitual en juegos 3D low poly pixel art. Se probará en el prototipo con y sin ella; si no te convence, basta con texturas *nearest* a resolución completa.

### El apartamento cambia con el progreso

El apartamento es el indicador visual del avance. Cada capítulo oculta grupos de basura y activa objetos nuevos (no se construye nada en tiempo real, solo se muestran u ocultan nodos):

- Cap. 1: basura por todos lados, foco parpadeante, cortinas rotas.
- Cap. 2: menos basura, plantita en la ventana.
- Cap. 3: muebles nuevos comprados con mejoras, luces LED en la máquina.
- Cap. 4: pósters de tazos, repisas llenas, máquina dorada.
- Cap. 5: apartamento lujoso-ridículo (sofá de leopardo, alfombra de tazos gigante).

### Colores de rareza

Gris = Basura · Blanco = Común · Verde = Poco común · Azul = Raro · Morado = Épico · Naranja = Legendario · Arcoíris animado = Mágico · Negro con parpadeo cian/magenta = Corrupto.

### Audio

- **Música:** funk/lo-fi con sabor chiptune noventero. Una pista por capítulo, cada una con capas: base al caminar, se añade percusión al sentarse a comer y una capa brillante cuando la racha de suerte está activa. Pistas aparte: menú, baño (elevador), noche/resumen del día, comerciales de TV y finales.
- **Efectos clave:** crujido de bocado (6–8 variantes con tono aleatorio), bolsa abriéndose, máquina (teclas, motor, caída del producto), revelación de tazo con un acorde que sube según la rareza, caja registradora al vender, estómago gruñendo, descarga del baño.
- **Voces:** sin doblaje. Cada personaje tiene un «balbuceo» de sílabas sintetizadas al estilo Animal Crossing (prota medio, jefe grave y rápido, Ente con eco y reverb).

### Juice (estímulo)

En orden de prioridad, por el impacto que tienen respecto al trabajo que cuestan:

1. Revelación del tazo: el tazo sale volando hacia la cámara, gira y se detiene; destello del color de su rareza; confeti desde Épico; cámara lenta de 0,3 s desde Legendario.
2. Números flotantes de dinero al vender y al depositar.
3. Contadores que suben de golpe en el HUD (dinero, Brillos) con un pequeño rebote.
4. Sacudida de cámara leve al morder, desactivable en ajustes.
5. Luces de la máquina que reaccionan a la suerte del día.

## 4. Core loop y ciclo del día

El juego tiene tres loops anidados: el **bocado** (segundos), el **día** (\~6–8 min) y la **semana/capítulo** (\~45 min). Cada uno alimenta al de arriba.

```
Comprar snacks ──► Abrir y comer ──► Sale un tazo
      ▲                 │ ▲                │
      │      llenura 100▼ │                ▼
Mejoras y deuda      Baño (vacía      Decidir el tazo
      ▲              la llenura)   (álbum, venta o Brillos)
      │                                    │
      └──────── Dinero y Brillos ◄─────────┘
Se repite todo el día (~6 min reales). Dormir: resumen del día y guardado.
```

El centro del loop es comer; el baño es la pausa obligada que las mejoras van acortando.

### Loop del día

1. **Mañana (08:00):** despiertas, la máquina se reabastece, el banco y el Ente pueden mandar mensajes, la TV pasa comerciales de snacks nuevos (de fondo).
2. **Comprar:** en la máquina eliges código (A1, B3…), pagas y recoges. Lo comprado va al inventario (pocos espacios al inicio).
3. **Comer:** en la mesa sacas los snacks, los abres y comes bocado a bocado hasta acabar la bolsa o encontrar el premio.
4. **Decidir cada tazo:** coleccionar (álbum), vender (caja de envío) o reciclar (Brillos).
5. **Baño:** cuando la llenura llega al tope ya no puedes comer; vas al baño y esperas unos segundos.
6. **Vender y mejorar:** desde el teléfono publicas en el mercado, el repartidor recoge y te deposita; compras mejoras o abonas a la deuda.
7. **Noche:** a las 00:00 al personaje le da sueño (camina más lento); a las 02:00 se desmaya y pierde un 10 % del dinero en efectivo en una compra absurda que hizo dormido (al azar: una lámpara de lava con forma de pato, 12 calcetines izquierdos…). Al despertar aparece junto a la cama. Dormir en la cama termina el día: desde las 22:00 siempre; antes, solo si ya no puedes seguir el día (no te alcanza para ningún snack con stock, contando el efectivo, el dinero de la bandeja y los tazos de la caja de envío) y pide confirmación. Con la llenura sobre 80 no se puede dormir (hay que ir al baño); no hace falta estar en 0 y la llenura pasa al día siguiente. Así nadie puede saltarse días enteros durmiendo y perder de golpe, ni quedarse atorado sin dinero.
8. **Resumen del día:** pantalla con lo comido, tazos encontrados, ganado, gastado y días para el próximo pago. Autoguardado.

### Tiempo

- 1 segundo real = 3 minutos de juego. El día jugable (08:00–02:00) dura 6 minutos reales.
- El reloj se pausa en menús, en el teléfono **no** (diseño intencional: el teléfono es parte del juego), en diálogos sí.
- La mejora Insomnio Productivo extiende el día hasta \~9 minutos reales.

### Semana y capítulo

Cada 7 días vence un pago a BanCruel. Si se paga y se tienen los fragmentos del capítulo, el Ente llama, la máquina evoluciona (nuevo nivel, nuevos snacks) y el apartamento cambia.

- **Pago fallado:** se pierde la semana, pero nunca hay final malo. Azar «rebobina el tiempo» y el jugador elige entre repetir la semana o empezar de cero con prestigio. Perder siempre deja Ecos, que hacen más fácil el siguiente intento (detalle abajo).
- **Fragmentos pendientes:** si se paga pero faltan fragmentos, el capítulo sigue abierto; el siguiente pago no vence hasta avanzar. Esto evita bloqueos por mala suerte (ver protección anti-mala-racha en la sección 5).

### Semana perdida y prestigio

Todo jugador llega al final: la única derrota posible es perder una semana, y cada derrota da **Ecos**, una moneda permanente que sobrevive a cualquier reinicio.

Al fallar un pago aparece la pantalla de semana perdida con dos opciones:

1. **Repetir la semana:** vuelve al guardado del día 1 de esa semana con los Ecos ganados. Además recibe la «Compasión de Azar»: +10 % de suerte y +10 % de valor de venta durante esa semana, acumulable si vuelve a fallar (máximo +30 %).
2. **Empezar de cero:** reinicia la partida desde el día 1 con todos los Ecos acumulados ×1,5. Pensado para quien siente que gastó mal sus mejoras. Los diálogos ya vistos se pueden saltar.

Ecos ganados al perder (la raíz cuadrada evita que se disparen en los capítulos finales):

```latex
Ecos = \sqrt{\frac{dinero\ ganado\ en\ la\ semana}{10}} + 5 \cdot fragmentos\ recuperados
```

Ejemplo: perder la semana 1 tras ganar $400 da \~6 Ecos más 5 por cada fragmento. Las mejoras que se compran con Ecos están en la sección 8. Tras terminar la historia, los Ecos también sirven para una **Nueva partida+** opcional.

## 5. Mecánicas detalladas

Diez sistemas cubren todo el juego. Cada uno se describe con lo mínimo para programarlo y con las palancas que las mejoras pueden mover.

### 5.1 Máquina expendedora (InfiniteVM3000)

- Rejilla de **4 columnas × 5 filas = 20 casillas** (A1…E4). Filas A–D: los 16 snacks, cada uno en su casilla fija. Fila E (abajo): las 4 bebidas.
- Al inicio solo están activas A1 y A2. Cada casilla se activa con la mejora «Licencia de Sabor» cuando su capítulo lo permite; las bebidas se activan por capítulo.
- Cada casilla tiene un stock diario que se repone a las 08:00. Las vacías o bloqueadas se ven con el vidrio oscuro y un candado.
- **Compra sobre la máquina 3D, sin ventanas 2D.** Todo ocurre sobre el modelo de la máquina:
  1. **Acercarse:** con E frente a la máquina, la cámara pasa a una vista fija de su frente (modo MÁQUINA) y el cursor queda libre. Q para alejarse.
  2. **Elegir:** cada casilla muestra su snack en 3D detrás del vidrio. Al pasar el cursor encima, el snack se resalta con un *outline* (hover). Clic izquierdo lo agrega al carrito; clic derecho quita uno.
  3. **Carrito:** la pantalla de la máquina muestra la lista escrita (nombre × cantidad y total). No se puede agregar más de lo que hay en stock ni comprar casillas bloqueadas.
  4. **Pagar:** clic en el método de pago, que son objetos de la máquina: ranura de billetes (efectivo) y lector de tarjeta (tarjeta BanCruel, al desbloquearla). Si no alcanza, la pantalla lo dice y no se cobra nada.
  5. **Bandeja:** los snacks pagados caen uno por uno a la bandeja de abajo. Clic en la bandeja la abre; con E se guardan en el inventario de uno en uno. Si el inventario está lleno, el snack se queda en la bandeja hasta que haya lugar (por eso comprar no exige espacio libre).
  - El teclado numérico de la máquina queda decorativo y para el código secreto 0-4-2-0 (sección 13).
  - Técnica: el hover, el outline y el clic usan el mismo cursor que la mesa (`GrabController`, que lee una "posición de cursor" y no el ratón directo), así funciona igual con control. La pantalla del carrito es un `Label3D` o un `SubViewport` sobre el modelo.
  - *Prototipo gris:* mientras tanto se usa un panel 2D con un clic por artículo. Se reemplaza por esta versión justo después de la mesa (paso 5), que construye el cursor y el outline.
- **Casilla dorada:** cada día una casilla al azar brilla y sus snacks tienen +50 % de suerte.
- **Ranura mágica:** en un lateral de la máquina, donde se reciclan tazos a Brillos.
- La máquina sube de nivel con cada capítulo (cambio de modelo/material).

### 5.2 Inventario

- Barra rápida de 3 espacios al inicio, ampliable a 8. Un espacio = una pila del mismo snack (pila máxima 3, ampliable a 10).
- Teclas 1–8 eligen espacio; en la mesa colocan el snack.
- Teléfono y objetos clave no ocupan espacio.

### 5.3 Comer (estación de la mesa)

Al sentarse, la cámara pasa a una vista fija sobre la mesa y el ratón se libera.

- **Dos zonas en la mesa,** marcadas como dos recuadros que brillan al pasar el ratón:
  - **Derecha, zona de comer:** donde se colocan, abren y comen los snacks.
  - **Izquierda, zona de tazos:** cuando sale un tazo, vuela hacia la cámara (la revelación), gira y se acomoda solo en la siguiente casilla libre de esta zona.
- **Colocar:** 1–8 pone el snack en la zona de comer (cae con físicas).
- **Agarrar y mover:** clic izquierdo sostenido; el snack sigue al ratón en el aire con físicas suaves. Soltarlo lo deja caer. Puedes soltar el snack en cualquier momento para revisar tus tazos.
  - *Pendiente (junto con Agitar):* la bolsa se sujeta de la parte de arriba y cuelga con física mientras se sostiene (se balancea como péndulo), en vez de moverse rígida desde su centro.
- **Tirar y recoger:** los snacks se pueden tirar de la mesa. En el piso muestran «E · Recoger» al caminar; al recogerlos vuelven al inventario. Uno cerrado se apila normal; uno abierto ocupa un espacio completo (no se apila) y conserva sus bocados. Si no hay lugar, se queda en el piso. Al volver a colocarlo en la mesa sigue abierto y cuenta para el límite de abiertos.
- **Abrir:** E con el snack agarrado (o señalado). Hay 5 tipos de envase con su animación: bolsa, tubo, envoltura, caja y huevo (sección 6).
- **Comer:** Espacio = un bocado del snack abierto que **sostienes** con clic izquierdo (señalarlo no basta). Cada snack tiene N bocados; el premio está en un bocado al azar. Mantener Espacio come en cadena después de comprar la mejora «Masticación Continua».
- **Agitar:** sacudir el snack abierto con el ratón (movimiento rápido) tiene probabilidad de que el premio salga antes. Es la única mecánica de habilidad y premia jugar activo.
- **Revisar tazos:** clic en un tazo de la zona izquierda abre su carta (nombre, serie, rareza, valor, «ya lo tienes») con los botones Coleccionar / Vender / Reciclar.
- **Capacidad:** 2 snacks abiertos a la vez y 8 casillas de tazos al inicio (mejorables). Si la zona de tazos se llena, los nuevos se apilan en una pila al borde que se puede abrir como lista.

### 5.4 Llenura y baño

- Barra de **Llenura** 0–100. Cada bocado suma según el snack. Al llegar a 100 quedas **lleno**: no puedes comer y caminas a la mitad de velocidad (50 %) hasta que la llenura baje de 90 (el baño lo hace rápido; la digestión tarda unas 5 h de juego).
- Digestión pasiva: baja 1 punto cada 30 minutos de juego (~36 por día completo; mejorable con «Metabolismo de Colibrí»). Dormir no vacía la llenura.
- **Baño:** sentarte vacía la barra a velocidad constante: 15 s de 100 a 0, así que con menos llenura tardas menos (50 → 7,5 s). Levantarte con Q lo interrumpe y al volver sigue al mismo ritmo. «Tripas Express» baja el tiempo total (−1,5 s por nivel, hasta 7,5 s) e «Inodoro Inteligente» lo vuelve instantáneo. Sentado, la cámara baja a la altura de los ojos de alguien sentado. Mientras esperas puedes leer el «periódico»: noticias absurdas y alguna pista de easter egg (decorativo).
- **Bebidas** de la máquina (desbloqueables) dan efectos temporales: digestión rápida, velocidad, suerte.

### 5.5 Premios y rarezas

Cada snack terminado tira primero si trae premio (65 % base) y, si sí, qué rareza. Sin premio sale un **Tazo Basura**.

| Rareza | Peso base | Valor relativo | Notas |
| --- | --- | --- | --- |
| Basura | — | 0,05× | Sale cuando no hay premio; recicla a 1 Brillo |
| Común | 60 | 0,6× |  |
| Poco común | 25 | 1,5× |  |
| Raro | 10 | 4× |  |
| Épico | 4 | 15× |  |
| Legendario | 1 | 60× |  |
| Mágico | aparte | no se vende | Fragmentos de Azar, sistema propio (5.6) |
| Corrupto | aparte, 1 por serie, desde cap. 3 | 30× | Riesgo y recompensa, sistema propio (5.10) |

*Valor relativo = múltiplo del precio del snack del que salió.* Variantes que se aplican encima: **Holográfico** (3 %, ×5 de valor; no ocupa casilla propia: vuelve brillante la casilla del álbum y cuenta para el logro Platino) y **Mal impreso** (0,5 %, ×10, uno por serie con casilla propia en el álbum).

### 5.6 Fragmentos mágicos (progreso de historia)

- 12 fragmentos en total: 1 en el tutorial (garantizado) y 2–3 por capítulo.
- Probabilidad por snack = base 0,5 % + 0,5 % por cada snack comido desde el último fragmento. Garantizado a los 60 snacks sin uno.
- Solo pueden salir los fragmentos del capítulo actual, así la historia avanza a un ritmo controlado.

### 5.7 Suerte

- Estadística visible (trébol en el HUD). Empieza en 0 %.
- La suerte multiplica los pesos de las rarezas altas, no los de Común (fórmula en la sección 7).
- Fuentes: mejoras, álbumes completos, casilla dorada, bebidas, fragmentos recuperados (+2 % cada uno) y tazos Corruptos (5.10).
- **Protección anti-mala-racha:** cada snack sin un tazo nuevo para la colección sube un 2 % la probabilidad de que el siguiente sea uno que no tienes. Se reinicia al conseguir uno nuevo.

### 5.8 Colección, venta y reciclaje

Cada tazo que sale se acomoda en la zona de tazos (izquierda de la mesa). Al hacer clic en uno se abre su carta con tres botones (también con teclas, con el ratón encima):

- **C · Coleccionar:** solo si no lo tienes. Va al álbum de su serie en la repisa (animación corta). Los repetidos muestran el botón en gris.
- **V · Vender (Empacar):** va a la caja de envío, que empieza junto a la mesa. La caja tiene capacidad limitada (5 tazos al inicio; la subirá una rama de mejoras).
- **R · Reciclar:** se convierte en Brillos (Común 1, Poco común 3, Raro 10, Épico 40, Legendario 150). Reciclar un Corrupto lo repara y da 100.

**Álbumes:** uno por serie (16) en las repisas junto a la mesa, cada uno con 15 casillas + 1 Mal impreso + 1 Corrupto. Además, un álbum de Fragmentos (12) y uno de **Secretos** con 12 casillas «???» para los tazos de los easter eggs. Completar una página da +1 % de suerte; completar un álbum da un bono permanente propio de esa serie (ej. +10 % al valor de venta de esa marca). Es la razón para coleccionar en vez de vender.

**Venta:**

1. Al inicio hay que llevar la caja a la puerta: se recoge con E (ocupa un espacio del inventario) y se deja con E junto a la puerta. De vuelta, la primera E en la mesa deja la caja en su lugar y la segunda te sienta. Más adelante también se publicará desde la app del mercado.
2. Dejar la caja con tazos en la puerta es «pedir» el envío (como si lo empacado fuera un pedido vendido en línea): el repartidor llega **1 hora de juego después** y, mientras tanto, la caja no se puede levantar ni cambiar. Se lleva los tazos y deja el dinero en la bandeja de la puerta, con una notificación; la caja vacía se queda en la puerta. Si el pedido sigue pendiente al dormir, llega durante la noche.
3. Mejoras: recolección desde la mesa, repartidor más rápido, venta instantánea.

**Mercado (simple):** cada tazo tiene un precio fijo (rareza × precio del snack × variante × bonos) menos la comisión de TazoBay. Sin demanda diaria, sin saturación y sin pedidos: vender siempre da lo mismo, así la decisión es solo coleccionar, vender o reciclar.

### 5.9 Deuda (BanCruel)

- Deuda inicial por la máquina, pagos semanales fijos (tabla en sección 7).
- Se puede abonar antes en cualquier momento desde la app; abonar de más reduce el siguiente pago.
- Desde el cap. 2 el banco ofrece **préstamos rápidos** con 40 % de interés: un riesgo opcional para acelerar mejoras.

### 5.10 Tazos Corruptos y el Error 67

La mecánica de riesgo del juego, inspirada en el riesgo acumulado de CloverPit. Los Corruptos (*Glitched* en inglés) son tazos con un chip rastreador de Crunchicorp que falla: te hacen ganar mucho más, pero cada uno aumenta la probabilidad de perder casi todo tu efectivo. Quedarte con ellos es apostar a tu suerte.

- **16 Corruptos,** uno por serie, desde el cap. 3. Sprite y borde con parpadeo glitch (píxeles desplazados, cian/magenta); la música se entrecorta al salir. Se coleccionan como cualquier tazo: tienen su casilla en el álbum de su serie.
- **La recompensa:** cada Corrupto que tengas (en la mesa o en el álbum) da +25 % al valor de venta de todos los tazos y +5 % de suerte.
- **El riesgo:** por cada snack que comes hay una probabilidad de **Error 67** igual a 0,67 % × Corruptos que tengas. Si sale, la máquina se congela con una pantalla azul de error, suena el «ding» de sistema caído y el «soporte técnico» de Crunchicorp se lleva el 67 % de tu efectivo y uno de tus Corruptos.
- **Cómo protegerte:** el dinero en la cuenta de ahorro de BanCruel no se toca; mejoras como Caja Fuerte, Antivirus Casero y Parche de Azar reducen el golpe o la probabilidad (sección 8).
- **Salir del riesgo:** reciclar un Corrupto lo repara (pierde su efecto) y da 100 Brillos; venderlo da 30× (×2 con Cazador de Glitches).
- **El álbum corrupto:** tener los 16 a la vez deja la probabilidad en 10,72 % por snack, pero da +400 % al valor de venta y +80 % de suerte, y desbloquea una tercera opción en la decisión final: el **Final del Trato** (sección 2).

## 6. Catálogo de snacks y coleccionables

16 snacks (3 por capítulo y 4 en el último) y 4 bebidas llenan las 20 casillas de la máquina. Cada snack trae su serie de 15 tazos, para un total de **296 casillas de álbum**: 240 normales, 16 Mal impresos, 16 Corruptos, 12 Fragmentos y 12 Secretos. Las 240 versiones holográficas son un reto opcional (logro Platino) sin arte extra, porque se hacen con un shader.

**Nombres que funcionan en inglés y español.** El chiste vive en una palabra en inglés que muchos hispanohablantes ya conocen (cringe, fake, cheat, meh, more), así que el nombre no se traduce: solo se traducen las descripciones. Cada parodia cambia nombre, logo y colores lo suficiente para no confundirse con la marca real.

| Cap. | Casilla | Snack (parodia de) | El chiste | Envase | Precio | Bocados | Llenura por bocado | Serie de tazos |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | A1 | **Lazy's** (Lay's) | *Lazy* = flojo: papas que no hacen nada | Bolsa | $5 | 8 | 2 | Couch Potatoes: papas tiradas en el sofá |
| 1 | A2 | **Dorkitos** (Doritos) | *Dork* = ñoño: triángulos nerds | Bolsa | $8 | 8 | 2 | Nerd Triangles |
| 1 | A3 | **Meh&Meh's** (M&M's) | *Meh*: los dulces que están… bien | Bolsa chica | $12 | 12 | 1 | Mid Candies: dulces con trabajos aburridos |
| 2 | A4 | **Cringles** (Pringles) | *Cringe*: el bigotón hace cosas vergonzosas | Tubo | $25 | 12 | 2 | Awkward Mustaches |
| 2 | B1 | **Fakis Fuego** (Takis) | *Fake*: picante de mentira… ¿o no? | Bolsa | $35 | 10 | 3 | Fake Lucha Libre |
| 2 | B2 | **Gooseito** (Gansito) | *Goose* + -ito: el ganso bilingüe | Envoltura | $45 | 3 | 8 | Mutant Farm |
| 3 | B3 | **Cheatos** (Cheetos) | *Cheat*: el gato tramposo | Bolsa | $120 | 10 | 3 | Cheating Cats |
| 3 | B4 | **Moreos** (Oreo) | *More*: nunca es solo una | Caja (paquete) | $150 | 6 | 4 | Space Cookies |
| 3 | C1 | **Snitchers** (Snickers) | *Snitch*: la barra chismosa | Envoltura (barra) | $180 | 4 | 6 | Gossip Gang |
| 4 | C2 | **Struggles Family Size** (Ruffles) | *Struggle*: la bolsa que nunca se abre bien | Bolsa grande | $700 | 20 | 1 | Extreme Sports Fails |
| 4 | C3 | **QuitKats** (KitKat) | *Quit*: «date un break… y renuncia» | Envoltura (barra) | $900 | 4 | 5 | Office Escape |
| 4 | C4 | **Flop-Tarts** (Pop-Tarts) | *Flop* = fracaso | Caja | $1.100 | 6 | 4 | Epic Fails |
| 5 | D1 | **Skittish** (Skittles) | *Skittish* = asustadizo: los dulces huyen por la mesa | Bolsa chica | $3.000 | 15 | 1 | Scaredy Candies |
| 5 | D2 | **Missin' Noodles** (Cup Noodles) | *Missin'*: siempre les falta algo | Tubo (vaso) | $4.000 | 8 | 3 | Lost & Found |
| 5 | D3 | **Kinda Surprise** (Kinder Sorpresa) | *Kinda*: sorpresa… más o menos | Huevo | $5.000 | 2 | 5 | Meh Toys: juguetes decepcionantes |
| 5 | D4 | **Crunchicorp '97 Magic Edition** (ficticio, la campaña original) | La caja de la historia de Azar | Caja (misteriosa) | $8.000 | 10 | 3 | Retro 97: tazos que cuentan la historia |

Precios en «pesos del juego» ($); primera propuesta para el balance (sección 7). **5 tipos de envase** cubren los 16 snacks, cada uno con una sola animación reutilizada a distinta escala: bolsa, tubo, envoltura, caja y huevo.

### Bebidas (fila E de la máquina)

| Casilla | Bebida (parodia de) | El chiste | Efecto | Duración | Desbloqueo |
| --- | --- | --- | --- | --- | --- |
| E1 | **Coma-Cola** (Coca-Cola) | *Coma* = comer en español y estado de coma en inglés | Digestión ×3 | 2 h de juego | Cap. 1 |
| E2 | **Red Bully** (Red Bull) | *Bully* = abusón | +30 % velocidad de movimiento y de comer | 2 h | Cap. 2 |
| E3 | **Gut Punch** (ponche de fibra) | *Gut punch* = golpe al estómago | El siguiente baño es instantáneo | 1 uso | Cap. 3 |
| E4 | **Luckamin Water** (Vitaminwater) | Vitaminas de suerte | +15 % suerte | 1 h | Cap. 4 |

### Estructura de cada serie

15 tazos: 5 Comunes, 4 Poco comunes, 3 Raros, 2 Épicos y 1 Legendario, más su Mal impreso y su Corrupto. Cada tazo es un **sprite de 16×16** sobre un marco común que cambia de color según la rareza; en la carta se muestra ampliado ×8 sin suavizado. Cada uno tiene: código (ej. «DRK-07»), nombre y una frase corta en el reverso (en inglés y español).

Ejemplos para dar el tono:

- **LZY-01 · Couch Potato** (Común): «Hasn't moved since 1997 / No se ha movido desde 1997».
- **CRG-15 · The Mustache That Ate Itself** (Legendario): «No comment / Sin comentarios».
- **FAK-08 · El Enmascarado Falso** (Raro): «Even his mask is fake / Hasta su máscara es falsa».
- **MEH-05 · Red, Accountant** (Poco común): «This meeting could've been an email / Esta reunión pudo ser un correo».
- **C97-15 · The Warehouse** (Legendario): el lugar donde guardaron a Azar; el reverso trae una pista del final.

## 7. Economía y ritmo

Dos monedas con usos separados: **Dinero ($)** para snacks, deuda y mejoras «terrenales» (cuerpo, casa, mercado), y **Brillos (✦)** para mejoras «mágicas» (máquina y suerte). Los Brillos solo salen de reciclar tazos, así los repetidos siempre tienen uso y cada tazo es una decisión: coleccionar, vender o reciclar.

Una tercera moneda, los **Ecos**, solo se gana al perder una semana y nunca se pierde; es el prestigio del juego (secciones 4 y 8).

### Fórmulas base

Pesos de rareza con suerte *L* (0,5 = 50 %). *k* vale 0 para Común, 0,5 Poco común, 1 Raro, 2 Épico y 3 Legendario:

```latex
w'_i = w_i \cdot (1 + L \cdot k_i)
```

Precio de venta de un tazo:

```latex
P_{venta} = P_{snack} \cdot V_{rareza} \cdot M_{variante} \cdot B_{bonos} \cdot (1 - comisión)
```

Costo de una mejora en su nivel *n* (r = 1,15 para mejoras baratas y repetibles, hasta 1,8 para las muy poderosas):

```latex
C(n) = C_{base} \cdot r^{n}
```

Con los pesos base, el valor esperado de un snack es \~1,5× su precio. Ese margen es pequeño al inicio y crece con suerte y bonos; la mitad del valor esperado viene de Épicos y Legendarios, lo que genera picos de emoción.

### Plan de pagos de BanCruel

El protagonista compró la máquina en $310.000 con un «plan de pagos creciente» (abusivo a propósito, es el chiste). Cada pago se diseña para costar \~60 % de lo que un jugador promedio gana esa semana, dejando el resto para mejoras.

| Cap. | Días | Snacks nuevos | Pago semanal | Fragmentos | Tiempo real aprox. |
| --- | --- | --- | --- | --- | --- |
| 1 | 1–7 | Lazy's, Dorkitos, Meh&Meh's | $150 | 3 (1 del tutorial) | 50 min (incl. 10 de tutorial) |
| 2 | 8–14 | Cringles, Fakis Fuego, Gooseito | $1.500 | 2 | 45 min |
| 3 | 15–21 | Cheatos, Moreos, Snitchers | $8.000 | 3 | 50 min |
| 4 | 22–28 | Struggles, QuitKats, Flop-Tarts | $50.000 | 2 | 50 min |
| 5 | 29–35 | Skittish, Missin' Noodles, Kinda Surprise, Crunchicorp '97 | $250.000 | 2 | 50 min |

Total: \~4 h para la historia. Completar los 296 tazos del álbum pide unos 2.000 snacks en total con la protección anti-mala-racha: la historia cubre \~1.500, así que quedan 3–5 h de juego libre con la automatización. El Platino holográfico es para fanáticos.

### Reglas para balancear

- Todo el balance vive en una hoja de cálculo y en archivos de datos del juego (nunca en el código), para ajustar sin programar.
- Objetivo de ritmo: comprar algo nuevo cada 1–3 minutos reales. Si pasan más de 5 minutos sin una compra, hay un hueco de diseño.
- Cada capítulo multiplica precios y valores ×4–6; las mejoras de un capítulo deben sentirse obsoletas al siguiente, como en todo incremental.
- Un menú de depuración (F1) para dar dinero, saltar días y simular 1.000 snacks es obligatorio para probar el balance rápido.

## 8. Árbol de mejoras

44 mejoras repartidas en 4 apps (más 7 de prestigio) del teléfono; cada app es una rama del árbol y sus mejoras se desbloquean por capítulo o por tener otra mejora previa. Las ramas siguen el pilar de «fricción que se compra»: primero hacer las cosas más rápido, luego hacer más a la vez y al final automatizarlas.

Costos base en la moneda indicada; cada nivel sube con la fórmula de la sección 7. Todo es primera propuesta.

### FitBro · tu cuerpo ($)

| Mejora | Efecto por nivel | Niveles | Costo base | Desbloqueo |
| --- | --- | --- | --- | --- |
| Piernas de Gelatina | +10 % velocidad al caminar | 5 | $20 | Cap. 1 |
| Mandíbula Turbo | +15 % velocidad de bocado | 5 | $30 | Cap. 1 |
| Dedos Rápidos | −25 % tiempo para abrir envases | 2 | $25 | Cap. 1 |
| Estómago Elástico | +20 de llenura máxima | 5 | $50 | Cap. 1 |
| Buen Diente | El premio sale 1 bocado antes | 3 | $60 | Cap. 1 |
| Tripas Express | −1,5 s en el baño | 5 | $60 | Cap. 1 |
| Metabolismo de Colibrí | Digestión pasiva ×1,5 | 3 | $400 | Cap. 2 |
| Masticación Continua | Mantener Espacio come en cadena | 1 | $300 | Cap. 2 |
| Muñeca de Batidora | +25 % probabilidad al agitar | 3 | $1.500 | Cap. 3 |
| Insomnio Productivo | El día dura 1 h de juego más | 3 | $5.000 | Cap. 3 |
| Mandíbula de Acero | Cada bocado cuenta doble | 1 | $20.000 | Cap. 4 + Mandíbula Turbo 5 |

### CasaMart · tu apartamento ($)

| Mejora | Efecto por nivel | Niveles | Costo base | Desbloqueo |
| --- | --- | --- | --- | --- |
| Bolsillos Profundos | +1 espacio de inventario | 5 | $40 | Cap. 1 |
| Bolsa de Super | +2 a la pila máxima por espacio | 4 | $100 | Cap. 1 |
| Mesa Extensible | +1 snack abierto a la vez en la zona de comer | 3 | $250 | Cap. 1 |
| Zona de Tazos Ampliada | +4 casillas en la zona de tazos | 3 | $150 | Cap. 1 |
| Repisa Nueva | Espacio para los álbumes del capítulo siguiente (decorativo + necesario) | 4 | $500 | Por capítulo |
| Sofá con Ruedas | La silla de la mesa queda junto a la máquina: compras sin levantarte | 1 | $3.000 | Cap. 3 |
| Caja Fuerte | El Error 67 no toca un 25 % de tu efectivo | 2 | $2.500 | Cap. 3 |
| Antivirus Casero | −20 % probabilidad del Error 67 | 3 | $4.000 | Cap. 3 |
| Robot Aspiradora | Recoge los tazos de la mesa y aplica una regla (ej. vender repetidos) | 1 | $15.000 | Cap. 4 |
| Inodoro Inteligente | El baño es instantáneo | 1 | $60.000 | Cap. 5 + Tripas Express 5 |

### TazoBay · el mercado ($)

| Mejora | Efecto por nivel | Niveles | Costo base | Desbloqueo |
| --- | --- | --- | --- | --- |
| Vendedor Verificado | −5 % comisión (empieza en 20 %) | 4 | $80 | Cap. 1 |
| Influencer de Tazos | +8 % al valor de venta | 5 | $50 | Cap. 1 |
| Recolección a Domicilio | Ya no hay que llevar la caja a la puerta | 1 | $250 | Cap. 1 |
| Paquete Sorpresa | Vender 10 repetidos de una vez regala 1 snack al azar | 1 | $300 | Cap. 1 |
| Repartidor Puntual | El repartidor llega 30 min después de pedirlo en vez de 1 h | 1 | $400 | Cap. 2 |
| Autoventa de Repetidos | Los repetidos van solos a la caja | 1 | $5.000 | Cap. 3 |
| Cazador de Glitches | Comprador que paga ×2 por tazos Corruptos | 1 | $8.000 | Cap. 3 |
| Venta Instantánea | El dinero llega al vender, sin esperar | 1 | $10.000 | Cap. 3 + Repartidor Puntual |
| Casa de Subastas | Los Legendarios se venden con +50 % | 1 | $25.000 | Cap. 4 |

### VendiMagic · la máquina y la suerte (✦ Brillos)

| Mejora | Efecto por nivel | Niveles | Costo base | Desbloqueo |
| --- | --- | --- | --- | --- |
| Licencia de Sabor | Activa la casilla del siguiente snack | 14 | 10 ✦ | Solo los snacks del capítulo actual |
| Resurtido Generoso | +2 stock diario por casilla | 5 | 15 ✦ | Cap. 1 |
| Snack de Regalo | 5 % de que la máquina suelte 2 snacks por 1 | 4 | 15 ✦ | Cap. 1 |
| Descuento del Dueño | −5 % precio de snacks | 5 | 25 ✦ | Cap. 1 |
| Trébol de Bolsillo | +5 % suerte | 10 | 20 ✦ | Cap. 1 |
| Premio Seguro | +5 % probabilidad de premio | 5 | 30 ✦ | Cap. 2 |
| Brillo Holográfico | +1 % probabilidad de holográfico | 5 | 60 ✦ | Cap. 2 |
| Reciclaje Eficiente | +25 % Brillos al reciclar | 4 | 50 ✦ | Cap. 2 |
| Doble Casilla Dorada | 2 casillas doradas al día | 1 | 200 ✦ | Cap. 3 |
| Olfato de Coleccionista | Anti-mala-racha sube 4 % en vez de 2 % | 2 | 150 ✦ | Cap. 3 |
| Imán de Glitches | +50 % probabilidad de que salga un Corrupto (para valientes) | 2 | 100 ✦ | Cap. 3 |
| Parche de Azar | −15 % probabilidad del Error 67 | 3 | 120 ✦ | Cap. 3 |
| Cañón de Snacks | La máquina dispara a la mesa lo que eliges en el panel | 1 | 1.000 ✦ | Cap. 4 + Sofá con Ruedas |
| Modo Infinito | La máquina compra y lanza snacks sola cada 10 s mientras estés sentado | 1 | 5.000 ✦ | Cap. 5 + Cañón de Snacks |

### BanCruel · finanzas ($)

No vende mejoras, pero tiene dos funciones de progreso:

- **Cuenta de ahorro:** el saldo genera 2 % diario al dormir (máximo configurable). Es el pequeño componente «idle» del juego.
- **Tarjeta BanCruel:** se desbloquea con el primer pago; permite pagar con tarjeta en la máquina y comprar a crédito hasta un límite (con interés).

### Ecos · prestigio (permanente)

App que aparece en el teléfono tras la primera semana perdida. Sus mejoras nunca se reinician, ni al repetir la semana ni al empezar de cero.

| Mejora | Efecto por nivel | Niveles | Costo base (Ecos) |
| --- | --- | --- | --- |
| Bolsillo de la Suerte | +3 % suerte permanente | 5 | 5 |
| Ahorro del Pasado | Al repetir una semana empiezas con +20 % del pago semanal en efectivo | 5 | 8 |
| Músculo de Memoria | −10 % al costo de las mejoras de FitBro | 3 | 10 |
| Fragmentos Atraídos | +50 % probabilidad de fragmento | 2 | 12 |
| Contacto en BanCruel | −5 % al pago semanal | 4 | 15 |
| Máquina Recordada | Al empezar de cero, 2 casillas extra desde el día 1 | 2 | 20 |
| Memoria de Coleccionista | Al empezar de cero, conservas los álbumes | 1 | 30 |

Límite de diseño: un jugador que pierde dos veces cada semana debería terminar en \~5 h, no más. Si los Ecos lo hacen demasiado fácil, se baja la Compasión de Azar antes que los Ecos.

## 9. Apartamento: zonas interactuables

Todo ocurre en un apartamento de una habitación con 11 zonas interactuables. Todas usan el mismo componente de interacción (sección 14), así agregar una zona nueva es configurar datos, no programar un sistema.

| Zona | Interacción | Función en el loop | Notas |
| --- | --- | --- | --- |
| Máquina expendedora | E: abrir panel de compra | Comprar snacks y bebidas (20 casillas, 4×5); ranura mágica para reciclar | Centro visual del apartamento; brilla, cambia de modelo por capítulo |
| Mesa + sofá | E: sentarse | Estación de comer: zona de comer a la derecha, zona de tazos a la izquierda | La zona donde más tiempo se pasa: la que más detalle merece |
| Repisas de álbumes | E: abrir álbum | Ver y completar colecciones | Junto a la mesa; los álbumes completos brillan |
| Baño (inodoro) | E: sentarse | Vaciar la llenura | Periódico decorativo con chistes y pistas de easter eggs |
| Cama | E: dormir | Termina el día, resumen y guardado | Desde las 22:00; antes solo si ya no puede comprar nada (con confirmación). Nunca con llenura > 80 |
| Mesa de noche | E: tomar | Teléfono (solo en el tutorial; después va en el inventario permanente) | Despertador decorativo con la hora |
| TV | E: cambiar canal | Decorativa: comerciales de snacks, canales absurdos y easter eggs | Encendida de fondo da ambiente sonoro; no afecta la economía |
| Puerta principal | E: dejar caja | Caja de envío de tazos vendidos; notas del repartidor | Mensajes de BanCruel deslizados bajo la puerta |
| Ventana | E: mirar | Muestra la hora del día; planta que crece si la riegas cada día | Easter egg de la planta |
| Refrigerador | E: abrir | Siempre vacío; frase distinta cada vez (chiste recurrente) | Cap. 5: un tazo escondido |
| Bote de basura | E: tirar | Tirar tazos Basura sin reciclar (desaparecen) | Un mapache aparece a veces (easter egg) |

**Recomendación de distribución** para tu diseño del apartamento: máquina a 4–5 m de la mesa y baño a 6–8 m. Esa distancia es la fricción inicial que las mejoras de velocidad y el Sofá con Ruedas eliminan; si las zonas están muy juntas, esas mejoras pierden sentido.

## 10. Controles

Teclado y ratón, con controles distintos según el contexto (caminar, mesa, teléfono). Todas las teclas se pueden reasignar desde Opciones; en Godot esto sale casi gratis si todo pasa por el Input Map con acciones con nombre.

| Acción | Tecla | Contexto |
| --- | --- | --- |
| Moverse | WASD | Caminar |
| Mirar | Ratón | Caminar |
| Correr | Shift (mantener) | Caminar |
| Interactuar | E | Caminar |
| Abrir / cerrar teléfono | Tab | Siempre (menos en diálogos) |
| Pausa | Esc | Siempre |
| Colocar snack del inventario | 1–8 | Mesa |
| Agarrar y mover snack | Clic izquierdo (mantener) | Mesa |
| Girar snack agarrado | Clic derecho (mantener) + mover ratón | Mesa |
| Acercar / alejar snack agarrado | Rueda del ratón | Mesa |
| Abrir snack | E | Mesa |
| Comer un bocado | Espacio (mantener con Masticación Continua) | Mesa |
| Agitar | Mover el ratón rápido con un snack abierto agarrado | Mesa |
| Coleccionar / Vender / Reciclar tazo | Clic en el tazo y elegir en su carta, o C / V / R con el ratón encima | Mesa |
| Agregar al carrito / quitar | Clic izquierdo / clic derecho sobre el snack | Máquina |
| Pagar / abrir bandeja | Clic en la ranura o el lector / clic en la bandeja | Máquina |
| Guardar snack de la bandeja | E | Máquina |
| Levantarse / alejarse | Q | Mesa, máquina, baño |
| Navegar apps | Ratón (clic) | Teléfono |
| Adelantar diálogo | Clic izquierdo o Espacio | Diálogo |
| Menú de depuración | F1 | Solo en versión de desarrollo |

**Control y Steam Deck: sí, sin rehacer mecánicas.** Toda la entrada pasa por acciones con nombre del Input Map («interact», «eat»…), nunca por teclas fijas en el código; así agregar el control es asignar botones. Lo único distinto es la mesa: con control aparece un cursor virtual que se mueve con el stick y se pega al snack o tazo más cercano. Ese cursor se programa una vez en el `GrabController` y el resto de la mesa no cambia. Se hace en la fase 5, pero el código de la mesa se escribe desde el inicio leyendo una «posición de cursor» en vez del ratón directo.

## 11. GUI y menús

La interfaz es mínima en pantalla y casi todo vive dentro del teléfono. Un solo tema visual (fuente pixel legible, bordes de 2 px, colores de la paleta) aplicado a todo con un recurso Theme de Godot.

### HUD al caminar

- **Arriba izquierda:** reloj y día («Día 4 · 15:30»), días para el próximo pago.
- **Arriba derecha:** dinero, Brillos y suerte (trébol + %).
- **Abajo centro:** barra de inventario (1–8) con el número de unidades por espacio.
- **Abajo izquierda:** barra de llenura (cambia de color y el estómago gruñe al pasar 80).
- **Centro:** punto de mira y texto de interacción («E · Sentarse»).
- **Derecha:** objetivo actual (tutorial y metas de capítulo) y notificaciones tipo toast («Vendiste DOR-03 por $12»).

### HUD de la mesa

Igual que el anterior pero sin punto de mira. La mesa se divide en dos recuadros que se iluminan al pasar el ratón: a la **derecha la zona de comer** (contador de bocados del snack señalado) y a la **izquierda la zona de tazos**, donde cada tazo se acomoda solo tras su animación. Al hacer clic en un tazo aparece su carta (nombre, serie, rareza, valor, «Ya lo tienes») con los botones Coleccionar / Vender / Reciclar.

### El teléfono

Se abre con Tab: la cámara baja un poco y aparece el teléfono en primer plano con la pantalla de inicio. Estilo de smartphone barato con apps de colores chillones.

| App | Contenido |
| --- | --- |
| Mensajes | Chats con el Ente, BanCruel, el jefe y el repartidor; historial de la historia |
| FitBro | Mejoras del cuerpo |
| CasaMart | Mejoras del apartamento |
| TazoBay | Publicar tazos e historial de ventas |
| VendiMagic | Mejoras de la máquina y suerte (aparece después de la llamada del Ente) |
| BanCruel | Saldo, pago semanal, abonos, ahorro, préstamos |
| Álbum | Atajo a todas las colecciones (alternativa a ir a la repisa) |
| Ajustes | Las mismas opciones del menú de pausa |

Las apps aparecen poco a poco (el tutorial empieza solo con Mensajes y TazoBay) para no abrumar al inicio. Un globo rojo marca las apps con algo nuevo o comprable.

### Pantallas

- **Menú principal:** el apartamento de fondo con la máquina brillando. Opciones: Continuar, Nueva partida (3 ranuras), Opciones, Créditos, Salir.
- **Pausa:** Continuar, Opciones, Guardar y salir al menú, Salir al escritorio.
- **Opciones:** audio por canal (música, efectos, voces, interfaz), sensibilidad e inversión del ratón, FOV, resolución y escala de píxel, pantalla completa, V-Sync, límite de FPS, idioma, velocidad del texto, reasignar teclas, accesibilidad.
- **Resumen del día:** tarjeta tipo recibo de tienda con las cifras del día, que se imprime con sonido de impresora.
- **Fin de semana:** pantalla del pago a BanCruel («PAGADO» con sello, o strike).
- **Finales y créditos:** créditos que pasan como comercial de TV.

### Accesibilidad mínima

- La rareza se distingue también por forma del borde e icono, no solo por color.
- Interruptores para sacudida de cámara, destellos y balanceo al caminar.
- Tamaño de texto ajustable en diálogos y teléfono.

## 12. Guion y diálogos

Tu intro y tutorial se mantienen tal cual (solo con ortografía corregida); añadí las llamadas de cada capítulo, mensajes de sistema y frases sueltas. Indicaciones del juego en *cursiva*, acciones entre corchetes.

### Intro (pantalla negra)

&#91;Suena el tono del teléfono. El protagonista estaba dormido.\]

**Jefe:** ¿Dónde estás?

**Prota:** ¿Qué?… ¿Quién habla?

**Jefe:** ¡#&$! ¡Hoy teníamos que hacer la mudanza de la empresa!

**Prota:** …Me quedé dormido… lo siento, jefe. Eh, voy para allá.

**Jefe:** Ya no hace falta… estoy cansado de esto. ¡Estás despedido!

**Prota:** ¡No, por favor! Necesito pagar mis deudas. El banco—

**Jefe:** Lo siento, pero… no es mi problema.

&#91;Cuelga.\]

### Tutorial

&#91;Apartamento sucio. Se levanta.\] *Muévete con WASD, interactúa con E.*

&#91;Le suena el estómago.\]

**Prota:** Tengo hambre…

*Se marca la máquina expendedora.*

**Prota:** ¿Por qué me gasté tanto dinero en una máquina expendedora propia?

*Elige el número del snack → paga con billete → confirma → recoge con E.* (Solo hay una unidad disponible.)

*Ve al sofá y siéntate a la mesa.* \[La cámara enfoca la mesa.\]

*Pulsa 1 para colocar la bolsa · Mantén clic izquierdo para agarrarla · E para abrir · Espacio para comer.*

&#91;Aparece un tazo mágico flotando frente a la pantalla.\]

**Prota:** ¡Wow! Nunca había visto este, ¿será nuevo?

**Prota:** Es diferente…

**Prota:** Tengo que ver cuánto vale.

&#91;Suena el teléfono.\] *Recoge el teléfono de la mesa de noche.*

**Ser misterioso:** Veo que has hallado mi tazo mágico.

**Prota:** …¿Quién eres? ¿De qué estás hablando?

**Ser misterioso:** Sé que pasas por una situación complicada, así que te daré una oportunidad…

**Prota:** ¿Oportunidad? No entiendo nada…

**Ser misterioso:** La suerte te ha elegido. Has encontrado parte de mi poder y este te podría volver muy rico…

**Prota:** Me interesa.

**Ser misterioso:** Pero a cambio, si no cumples con el trabajo y la suerte se aleja de ti, lo tomaré de regreso y buscaré a alguien más.

**Prota:** Pues no tengo nada que perder. ¿De qué va el trabajo?

**Ser misterioso:** Ya lo verás…

&#91;La máquina suena, lanza brillos cada vez más intensos y se transforma en la InfiniteVM3000.\]

**Prota:** Increíble…

**Ser misterioso:** Tu trabajo será recuperar todos los fragmentos de mi poder ocultos en esa máquina, mientras vendes (o no) los coleccionables para ganar dinero.

**Ser misterioso:** Como soy un ente sin cuerpo, no puedo comer. Así que dependo de ti.

**Prota:** ¿Así que solo debo comer?

**Ser misterioso:** Sí… y mucho.

**Ser misterioso:** Revisa tu teléfono, te he instalado unas apps que te pueden interesar.

**Ser misterioso:** Estaremos en contacto. Suerte…

&#91;Cuelga. *Abre el teléfono con Tab.* Continúa el tutorial de vender, el baño y dormir.\]

**Continuación propuesta del tutorial:**

&#91;SMS de BanCruel\] **Lic. Cobrano:** Estimado cliente: le recordamos que su primer pago de $150 por «Máquina expendedora usada (1)» vence en 7 días. Le deseamos un día productivo. Atte., BanCruel. *«Su deuda, nuestra pasión».*

**Prota:** …Ah, cierto. Por eso me la gasté toda.

*Toca un tazo repetido y pulsa V para venderlo. Lleva la caja a la puerta.*

&#91;Llenura al máximo\] **Prota:** Uf… creo que necesito… un momento a solas. *Ve al baño.*

&#91;22:00\] **Prota:** (bostezo) Mañana sigo comiendo. *Ve a la cama.*

### Llamadas del Ente por capítulo

**Fin del cap. 1**

**Ente:** Tres fragmentos. No está mal para alguien que se quedó dormido en su propia mudanza.

**Prota:** ¿Cómo sabes eso?

**Ente:** Sé muchas cosas. Ahora, observa. \[La máquina evoluciona.\] Mi máquina recuerda viejos sabores.

**Fin del cap. 2**

**Ente:** Hace mucho, una empresa decidió que la suerte se vendía mejor en bolsitas.

**Prota:** ¿Crunchicorp? ¿Los de las papas?

**Ente:** Me partieron en pedazos y me metieron en tazos. «Colecciónalos todos», decían.

**Inicio del cap. 3**

**Ente:** Puedes llamarme Azar. Hace treinta años que nadie dice mi nombre.

**Azar:** Cuidado: Crunchicorp también escondió tazos corruptos, con un chip para encontrar a quien me busque.

**Inicio del cap. 4** \[Número desconocido\]

**Agente de Crunchicorp:** Buenas tardes. Detectamos actividad inusual en una de nuestras máquinas. Le ofrecemos un millón por ella. Sin preguntas.

**Prota:** ¿Un millón? Eh…

**Azar:** \[Interfiere la llamada\] Cuélgale.

*Opciones: «Cuelgo» / «¿Y si lo pienso?»* (ambas terminan rechazando la oferta; la segunda da una frase extra de Azar molesto).

**Inicio del cap. 5**

**Azar:** Dos fragmentos más. Y el banco. Luego tendrás que decidir algo.

**Prota:** ¿Decidir qué?

**Azar:** Qué tan suertudo quieres ser.

**Semana perdida** \[La imagen pierde color, el reloj gira hacia atrás.\]

**Azar:** Mmm. La suerte se alejó esta vez.

**Prota:** ¿Me vas a quitar el poder?

**Azar:** Dije que lo tomaría de regreso… no que no te daría otra oportunidad. Recuerda lo que aprendiste.

*Opciones: «Repetir la semana» / «Empezar de cero».*

### Final

**Azar:** Están todos. Puedo sentirme entero otra vez… o puedes quedarte con todo.

*Opciones: «Devolverte tu poder» / «Quedarme el poder» / «Trato con Crunchicorp» (solo con el álbum corrupto completo).*

- **Final A:** **Azar:** Cumpliste. Te dejaré un poco de suerte… para siempre. \[La máquina se apaga para siempre. Créditos.\]
- **Final B:** **Prota:** Con esto nunca más voy a deber nada. \[Fundido a blanco. Otro apartamento. Suena un teléfono.\] **Voz del prota, con eco:** Veo que has hallado mi tazo mágico…
- **Final secreto (100 %):** **Jefe:** Oye… sobre lo del despido… ¿no quieres volver? Te subo el sueldo. *Opciones: «No» / \[Colgar\]*.

* **Final C (Trato):** **Agente de Crunchicorp:** Sabíamos que eras de los nuestros. Bienvenido a la familia. \[La máquina se apaga en rojo. Comercial de TV con el protagonista disfrazado de mascota: «Crunchicorp: tu suerte, nuestra receta».\]

### Frases sueltas del protagonista (aleatorias, sin repetir seguidas)

- Al encontrar un Legendario: «¡NO PUEDE SER!» · «Mamá, mira, soy rico… bueno, menos pobre.»
- Al sacar Basura: «Cartón. Delicioso cartón.» · «Esto lo diseñó un becario.»
- Con la llenura al máximo: «Ya no me cabe ni un chisme.» · «Si como uno más, exploto.»
- En el baño: «Momento de reflexión.» · «Aquí nacen las grandes ideas.»
- Al repetir un tazo: «Otra vez tú.» · «Ya te tengo, amigo. Vete a TazoBay.»
- Con un Corrupto: «Creo que este tazo tiene lag.»

### Notas del repartidor (una nueva por día, cada vez más raras)

1. «Recibido. Gracias.»
2. «Recibido. ¿Todo bien ahí dentro?»
3. «Oí una máquina hablando. No es asunto mío.»
4. «Mi hijo colecciona tazos. ¿Me guardas un Dorkito?»
5. «No sé quién eres pero tu edificio huele a queso.»

### Comerciales de TV (texto en pantalla + jingle)

- «¡Dorkitos! Tan crujientes que te vuelves genio. O no.»
- «Fakis Fuego: picor 100 % real. Probablemente.»
- «Meh&Meh's: están bien. Supongo.»
- «Cringles: una vez que haces pop, ya no hay vuelta atrás.»
- Noticiero: «Última hora: fiebre mundial por los tazos de Cringles» (puro chiste de fondo, no afecta precios).

## 13. Easter eggs y logros

Secretos baratos de hacer (un objeto, una frase o una condición) que premian explorar y dan material para compartir. Varios hacen guiño a los juegos que te inspiran.

### Easter eggs

| Secreto | Cómo se activa | Qué pasa |
| --- | --- | --- |
| Galleta Clicker | Hacer clic 100 veces seguidas en una galleta de Moreos sobre la mesa | Sale un tazo especial con forma de galleta (guiño a Cookie Clicker) |
| Mapache del bote | Tirar 20 tazos Basura al bote | Aparece un mapache que se lleva una moneda y deja un tazo (guiño a Raccoin) |
| Trébol de cuatro hojas | Regar la planta de la ventana 7 días seguidos | Florece un trébol: +4 % suerte permanente (guiño a CloverPit) |
| Rasca y gana | Revisar el correo bajo la puerta el día 13 | Un boleto de rasca y gana que se rasca con el ratón (guiño a Scritchy Scratchy) |
| La factura | Abrir el refri en el cap. 3 | Una factura pegada: «Bills must be paid» (guiño directo) |
| Código secreto | Teclear 0-4-2-0 en la máquina | Cae un snack de «Sabor Misterioso» con una frase rara del desarrollador |
| Canal 404 | Cambiar 30 veces de canal en la TV | Canal de estática con un mensaje oculto de Azar sobre su pasado |
| 3:33 | Seguir despierto a las 03:33 (requiere Insomnio Productivo) | La máquina habla sola y te da 33 Brillos |
| Vecino enojado | Agitar snacks con mucho ruido después de las 00:00 | Golpes en la pared y una nota bajo la puerta |
| Descarga ritual | Jalar la palanca del baño 50 veces | Logro «Hidrólogo» y una frase del protagonista |
| El jefe arrepentido | Llamar al jefe desde la app de Mensajes (desde el cap. 4) | Buzón de voz cada vez más desesperado |
| Tazo del desarrollador | Final secreto (100 % de álbumes) | Tazo dorado con tu cara en pixel art |

Cada uno de estos 12 secretos da además un tazo para la página **Secretos** del álbum, que aparece con casillas «???» desde el inicio para que el jugador sepa que existen.

### Logros de Steam (propuesta de 23)

- **Historia:** Despedido (terminar la intro) · Primer pago · La máquina despierta · Azar · Libre de deudas · Final A · Final B · Final del Trato · Final secreto.
- **Colección:** Primer álbum completo · Todos los álbumes · Primer Legendario · Primer Mal impreso · No es un bug, es una función (tener 3 Corruptos a la vez) · Sobreviviente del Error 67 · Platino (todas las casillas holográficas).
- **Absurdos:** Hidrólogo · Estómago de acero (comer 50 snacks en un día) · Ayuno (dormir sin comer nada) · Insomne (llegar a las 02:00 tres días seguidos) · Amigo del mapache · Jardinero · Millonario (tener $1.000.000 a la vez).

## 14. Arquitectura técnica en Godot 4

La arquitectura separa tres cosas: **datos** (qué existe: snacks, tazos, mejoras), **estado** (qué tiene el jugador ahora) y **presentación** (escenas 3D y UI que muestran ese estado). Los sistemas hablan por señales, así cada pieza se puede entender, probar y cambiar sola.

```
Presentación (escenas 3D y UI): Player · Apartment · EatingStation · UI
        │ piden cambios / leen estado        ▲ señales vía EventBus
        ▼                                    │
Autoloads: EventBus · Database · GameState · TimeManager · SaveManager · AudioManager
        │ usan para calcular
        ▼
Lógica pura: LootSystem · Economy · Stats · ObjectiveSystem
        ▲ Database los carga al iniciar
        │
Datos (.tres): SnackData · TazoData · SeriesData · UpgradeData · DrinkData · ChapterData
```

Las escenas piden cambios a GameState y escuchan sus señales; la lógica pura no conoce ninguna escena, y los datos solo se leen.

Versión: la estable más reciente de Godot 4 al empezar, con GDScript. Solo se actualiza con parches menores durante el desarrollo.

### Principios (la regla para revisar cada cambio)

1. **Datos fuera del código.** Snacks, tazos, mejoras, capítulos y bebidas son archivos `.tres` (Resources personalizados) editables en el Inspector. Para agregar un snack no se toca código.
2. **Un solo dueño del estado.** Dinero, inventario, colección, mejoras, día y deuda viven en `GameState`. Las escenas lo leen y piden cambios; nunca guardan su propia copia.
3. **Llamar hacia abajo, señales hacia arriba.** Un nodo puede llamar a sus hijos; para avisar hacia arriba o a otros sistemas emite una señal. Las señales globales viven en `EventBus`.
4. **La UI no pregunta cada frame.** El HUD se actualiza cuando llega una señal (`money_changed`), no en `_process`.
5. **Lógica pura aparte.** Tiradas de botín, precios y costos son funciones estáticas sin nodos: se pueden probar y simular miles de veces.
6. **Código legible.** Tipado estático siempre, nombres en inglés, comentarios en español, una clase por archivo, `class_name` en todo lo reutilizable.

### Autoloads (6, cada uno con una sola tarea)

| Autoload | Responsabilidad | Lo que NO hace |
| --- | --- | --- |
| `EventBus` | Solo declara señales globales (`snack_bought`, `tazo_found`, `day_ended`…) | No tiene lógica ni datos |
| `Database` | Carga al inicio todos los `.tres` y los indexa por id (`Database.get_snack("dor")`) | No modifica datos |
| `GameState` | Estado del jugador y operaciones válidas (`spend_money()`, `add_tazo()`); emite señales al cambiar | No toca escenas 3D ni UI |
| `TimeManager` | Reloj del día, pausa, eventos de hora (08:00, 00:00, 02:00) | No decide qué pasa al dormir, solo avisa |
| `SaveManager` | Convierte `GameState` a JSON y de vuelta; versión de guardado; 3 ranuras | No guarda objetos 3D |
| `AudioManager` | Música por capas, grupo de reproductores de efectos, buses de volumen | No decide cuándo sonar: responde a llamadas o señales |

### Sistemas de lógica (clases sin escena)

- `LootSystem`: `roll(snack, luck, pity, rng) -> LootResult`. Aplica premio sí/no, rareza con suerte, variante, fragmento, Corrupto, anti-mala-racha y la tirada del Error 67.
- `Economy`: precio de venta y costo de mejora.
- `Stats`: calcula estadísticas finales (velocidad, llenura máxima, suerte…) a partir de las mejoras compradas. Cada `UpgradeData` declara `stat_id`, operación (+ o ×) y valor por nivel; `Stats` recalcula y guarda en caché solo cuando llega `upgrade_purchased`.
- `ObjectiveSystem`: pasos del tutorial y metas de capítulo; cada paso escucha una señal del `EventBus` (ej. «completar cuando llegue `snack_opened`»).

### Recursos de datos (`.tres`)

`SnackData` (id, nombre, precio, bocados, llenura, tipo de envase, escena, serie) · `TazoData` (id, serie, rareza, región del atlas, frase) · `SeriesData` (tazos y bono al completar) · `UpgradeData` (app, stat, valores, costo base, crecimiento, requisitos) · `DrinkData` · `ChapterData` (pago, fragmentos, desbloqueos, diálogos).

### Escenas principales

- `Main.tscn`: raíz. Contiene el mundo 3D dentro de un `SubViewport` a 640×360 (con filtro *nearest* para el look pixel), la capa de UI (`CanvasLayer`) encima a resolución completa, y el menú de depuración.
- `Apartment.tscn`: el apartamento de Blender + las zonas interactuables. Los grupos de basura y decoración por capítulo son nodos que se muestran u ocultan.
- `Player.tscn`: `CharacterBody3D` + cámara + `RayCast3D` para interactuar. Tiene un **modo** activo: CAMINAR, MESA, TELÉFONO, MÁQUINA, BAÑO, DIÁLOGO, DORMIR. Solo el modo activo procesa entrada; cambiar de modo cambia cámara y captura del ratón en un solo lugar.
- `Interactable` (componente): un `Area3D` reutilizable con texto de ayuda y señal `interacted`. Máquina, cama, baño, TV y puerta son lo mismo con distinto script de respuesta.
- `EatingStation.tscn`: cámara fija, dos `Area3D` (zona de comer y zona de tazos) que se iluminan al pasar el ratón, `GrabController` (rayo del cursor a un plano sobre la mesa; el objeto agarrado sigue el punto con velocidad, no se teletransporta, así la física sigue estable), `SnackBody` (`RigidBody3D`) y `TazoZone` (casillas fijas donde se acomodan los tazos; no usan física, solo una animación hacia su casilla).
- `Phone.tscn`: pantalla de inicio + cada app como escena que hereda de `PhoneApp`.

### Rendimiento (presupuestos)

| Regla | Límite |
| --- | --- |
| Cuerpos físicos activos en la mesa | Máx. \~6 (solo snacks); los tazos no usan física |
| Bocados | No son objetos físicos: un contador + partículas + sonido |
| Objetos que aparecen seguido (tazos, números flotantes, partículas) | Se reutilizan de un grupo (pool), no se crean y destruyen |
| Carga de recursos | Todo se precarga en `Database` y al abrir la escena; nada de `load()` a mitad del juego |
| Referencias a nodos | `@onready` o nombres únicos (`%Nombre`); nunca `get_node()` dentro de bucles |
| Objetivo | 60 FPS estables en una PC modesta con gráfica integrada reciente |

### Guardado

- JSON en `user://` con número de versión para poder migrar partidas al actualizar el juego.
- Se guardan solo ids y números (nunca nodos ni posiciones físicas).
- Autoguardado al dormir. Al salir a mitad del día se guarda el estado económico y lo que hay en la mesa vuelve al inventario o a la charola.
- Punto de control al inicio de cada semana (copia del guardado del día 1) para «Repetir la semana».
- Los Ecos y sus mejoras van en un archivo aparte (`meta.json`) que nunca se borra al empezar de cero.

### Herramientas y flujo de trabajo

- **Git desde el día 1** (repositorio privado), con commits pequeños por cambio.
- **Plugins:** Dialogue Manager (de Nathan Hoad) para diálogos; GUT para pruebas de `LootSystem` y `Economy` (opcional pero recomendado). Nada más salvo necesidad real.
- **Traducción:** todo texto visible pasa por `tr()` con claves desde el inicio (CSV español/inglés). Agregar inglés después es mucho más caro.
- **Menú de depuración (F1):** dar dinero y Brillos, saltar hora y día, forzar rareza, simular N snacks e imprimir estadísticas.
- **Forma de trabajar juntos:** cada cambio se explica antes de hacerse, el código va comentado y se revisa contra estos principios.

### Estructura de carpetas

```
res://
  autoload/        EventBus, Database, GameState, TimeManager, SaveManager, AudioManager
  systems/         loot_system.gd, economy.gd, stats.gd, objective_system.gd
  data/
    resources/     snack_data.gd, tazo_data.gd, upgrade_data.gd (definiciones de clase)
    snacks/        *.tres
    tazos/         *.tres
    upgrades/      *.tres
    chapters/      *.tres
  scenes/
    main/          main.tscn
    world/         apartment.tscn, interactables/
    player/        player.tscn, modes/
    eating/        eating_station.tscn, snack_body.tscn, tazo_slot.tscn
    ui/            hud/, phone/, apps/, menus/, dialogue/
  assets/
    models/  textures/  audio/music/  audio/sfx/  fonts/
  dialogue/        *.dialogue
  localization/    strings.csv
  tests/
```

## 15. Plan de producción, riesgos y decisiones abiertas

Lanzamiento objetivo: noviembre de 2027, en 6 fases. La regla de oro es probar el loop con cubos grises antes de hacer arte: si comer y abrir tazos no es divertido con cubos, el arte no lo va a arreglar.

### Fases

| Fase | Meses | Entregable | Puerta para avanzar |
| --- | --- | --- | --- |
| 1. Preproducción | Dic 2026 | Este GDD cerrado, hoja de balance, proyecto Godot con la arquitectura vacía y Git | GDD aprobado por ti |
| 2. Prototipo gris | Ene–Feb 2027 | Loop completo con cubos: comprar, comer, tazo, vender, baño, dormir, guardar | ¿Es divertido 20 minutos seguidos con cubos? |
| 3. Vertical slice | Mar–Abr 2027 | Capítulo 1 terminado: arte, audio, tutorial, juice | Página de Steam publicada + tráiler corto |
| 4. Producción | May–Ago 2027 | Capítulos 2–5, todos los snacks, tazos, mejoras, diálogos y finales | Juego completo de principio a fin |
| 5. Beta y balance | Sep–Oct 2027 | Pruebas con jugadores, ajuste de economía, soporte de control, demo pública (ideal en un Steam Next Fest) | Contenido cerrado, sin bugs graves |
| 6. Lanzamiento | Nov 2027 | Pulido, logros, traducción al inglés, lanzamiento | — |

### Riesgos principales

- **Volumen de arte de tazos:** 296 sprites de 16×16. A \~10 por día son unas 6 semanas. Mitigación: marco común por rareza, dibujar solo el personaje y hacer los holográficos con un shader.
- **Física de la mesa:** agarrar y agitar objetos es lo más delicado de programar. Mitigación: es lo primero del prototipo gris.
- **Balance:** un incremental mal balanceado aburre o se rompe. Mitigación: hoja de cálculo + simulador en el menú de depuración + pruebas semanales desde la fase 3.
- **Alcance que crece:** cada idea nueva se anota en una lista de «después del lanzamiento» y solo entra si reemplaza algo de igual tamaño.
- **Parodias de marcas:** cambiar nombre, logo y colores lo suficiente; nunca usar logotipos reales.

### Nombres propuestos en inglés

Los nombres deben hacer gracia en inglés y entenderse en español. Antes de decidir hay que buscar en Steam y en registros de marca que no estén tomados.

| Nombre | Para | Por qué funciona |
| --- | --- | --- |
| **Chip Happens** | Juego | Juego de palabras con «shit happens»; muy conocido en ambos idiomas y resume el tono |
| **Full of Luck** | Juego | «Lleno de suerte»: la barra de llenura lo hace literal |
| **Gut Feeling** | Juego | «Corazonada», y *gut* también es la panza |
| **Snackrifice** | Juego | Snack + sacrifice: comer por un espíritu |
| **Snackulator 3000** | Máquina | Snack + calculator: suena a aparato noventero |
| **Gluttonator 3000** | Máquina | *Glutton* = glotón, casi igual en español |
| **Vend-O-Matic Infinity** | Máquina | Estilo de anuncio retro |
| **InfiniteVM3000** | Máquina | El nombre actual |

Mi recomendación: **Chip Happens** con la **Snackulator 3000**. Las empresas del mundo usan nombres que se entienden en ambos idiomas: Crunchicorp (antes Crujicorp), BanCruel, TazoBay, FitBro, CasaMart y VendiMagic.

### Decisiones abiertas

- [ ] Título final y nombre de la máquina (opciones en inglés arriba).
- [ ] ¿Se queda la segunda moneda (Brillos) o todo con dinero?
- [ ] Decidido: sin final malo; al perder una semana se repite o se empieza de cero con prestigio (Ecos).
- [ ] ¿Soporte de control para Steam Deck desde el inicio?
- [ ] Idiomas al lanzar (recomendado: español + inglés).
- [ ] Precio de venta (los incrementales cortos suelen estar entre 5 y 10 USD).
