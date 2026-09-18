extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_zone: Area2D
@export var enemies_container: Node2D

@onready var timer: Timer = $SpawnTimer

func _ready() -> void:
	if not spawn_zone or not enemy_scene or not enemies_container:
		push_error("EnemySpawner: заполни экспорт-переменные в инспекторе!")
		return
	timer.timeout.connect(spawn_enemy)

func start_spawning(interval: float) -> void:
	timer.wait_time = interval
	timer.start()

func stop_spawning() -> void:
	timer.stop()

func spawn_enemy() -> void:
	print("--- СПАВН СРАБОТАЛ! ---") # <--- ПРИНТ 1
	var enemy = enemy_scene.instantiate()
	enemies_container.add_child(enemy)
	
	var pos = _get_random_point_in_zone()
	enemy.global_position = pos
	print("Координаты врага: ", pos)     # <--- ПРИНТ 2

	enemy.died.connect(GameManager._on_enemy_died)
	if enemy.has_signal("reached_base"):
		enemy.reached_base.connect(GameManager._on_base_damaged)

func _get_random_point_in_zone() -> Vector2:
	var col_shape = spawn_zone.get_node("CollisionShape2D")
	var shape = col_shape.shape as RectangleShape2D
	var origin = col_shape.global_position
	var extents = shape.size / 2.0

	return origin + Vector2(
		randf_range(-extents.x, extents.x),
		randf_range(-extents.y, extents.y)
	)
