extends Node2D

@export var enemy_scenes: Array[PackedScene]
@export var target_node: Node2D

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout() -> void:
	if enemy_scenes.is_empty():
		return

	var spawn_points = get_children().filter(func(child): return child is Marker2D and child != target_node)
	if spawn_points.is_empty():
		return
	var random_point = spawn_points.pick_random()

	var random_enemy_scene = enemy_scenes.pick_random()

	var enemy = random_enemy_scene.instantiate()
	enemy.global_position = random_point.global_position
	
	if "target" in enemy and is_instance_valid(target_node):
		enemy.target = target_node

	get_parent().add_child(enemy)
