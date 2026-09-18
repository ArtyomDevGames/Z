extends Node2D

@export var enemy_scenes: Array[PackedScene]
@export var target_node: Node2D
@export var enemies_container: Node2D     # Enemies из Main
@export var bullets_container: Node2D     # Bullets из Main

@onready var spawn_timer: Timer = $EnemySpawner/SpawnTimer
@onready var spawn_points: Array[Marker2D] = []

func _ready() -> void:
	# Собираем все Marker2D-дети
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)

	if spawn_points.is_empty():
		push_error("EnemySpawner: не найдено ни одного Marker2D!")
		return
	if not enemies_container:
		push_error("EnemySpawner: не назначен enemies_container!")
		return

	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout() -> void:
	if enemy_scenes.is_empty():
		return

	var random_point = spawn_points.pick_random()
	var random_enemy_scene = enemy_scenes.pick_random()

	var enemy = random_enemy_scene.instantiate()

	# Передаём ссылки ДО add_child
	if "target" in enemy and is_instance_valid(target_node):
		enemy.target = target_node
	if "bullets_container" in enemy:
		enemy.bullets_container = bullets_container

	# Кладём врага в контейнер, а не к родителю спавнера
	enemies_container.add_child(enemy)

	# Позиция — после add_child, чтобы global_position работал корректно
	enemy.global_position = random_point.global_position

	# Группа для поиска и лимитов
	enemy.add_to_group(&"enemies")
