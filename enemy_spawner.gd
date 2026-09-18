extends Node2D

@export var enemy_scene: PackedScene      # enemy.tscn
@export var spawn_zone: Area2D            # SpawnZone
@export var target: Node2D                # TargetPoint
@export var enemies_container: Node2D     # Enemies
@export var bullets_container: Node2D     # Bullets

@export_group("Spawn Settings")
@export var spawn_interval: float = 1.0
@export var max_enemies: int = 50
@export var min_distance_from_target: float = 300.0

@onready var timer: Timer = $SpawnTimer

func _ready() -> void:
	if not enemy_scene or not spawn_zone or not target or not enemies_container:
		push_error("EnemySpawner: не все ссылки назначены в инспекторе!")
		return

	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	if get_tree().get_nodes_in_group(&"enemies").size() >= max_enemies:
		return
	_spawn_enemy()

func _spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()

	# 1. Сначала передаём ссылки, ПОКА враг не в дереве — это безопаснее
	if "target" in enemy:
		enemy.target = target
	if "bullets_container" in enemy:
		enemy.bullets_container = bullets_container

	# 2. Потом добавляем в контейнер
	enemies_container.add_child(enemy)

	# 3. Позиция
	enemy.global_position = _get_valid_spawn_position()

func _get_valid_spawn_position() -> Vector2:
	for i in 10:
		var point = _get_random_point_in_zone(spawn_zone)
		if point.distance_to(target.global_position) >= min_distance_from_target:
			return point
	return _get_random_point_in_zone(spawn_zone)

func _get_random_point_in_zone(zone: Area2D) -> Vector2:
	var shape_node: CollisionShape2D = zone.get_node("CollisionShape2D")
	var shape = shape_node.shape
	var origin = shape_node.global_position

	if shape is CircleShape2D:
		var angle = randf() * TAU
		var radius = sqrt(randf()) * shape.radius
		return origin + Vector2.RIGHT.rotated(angle) * radius

	elif shape is RectangleShape2D:
		var half = shape.size / 2.0
		return origin + Vector2(
			randf_range(-half.x, half.x),
			randf_range(-half.y, half.y)
		)

	elif shape is CapsuleShape2D:
		var half_height = shape.height / 2.0 - shape.radius
		var offset = Vector2(0, randf_range(-half_height, half_height))
		var angle = randf() * TAU
		var r = sqrt(randf()) * shape.radius
		return origin + offset + Vector2.RIGHT.rotated(angle) * r

	else:
		push_warning("SpawnZone: неизвестная форма, возвращаю origin")
		return origin
