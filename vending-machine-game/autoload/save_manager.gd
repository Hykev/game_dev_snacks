extends Node
## SaveManager: convierte GameState a JSON y de vuelta.
##
## Guarda en user:// con número de versión (para migrar partidas viejas),
## maneja 3 ranuras y un meta.json aparte para los Ecos, que nunca se borra.
##
## No hace: guardar nodos ni posiciones físicas. Solo ids y números.

# El guardado se programa al final del prototipo gris (paso 7).
