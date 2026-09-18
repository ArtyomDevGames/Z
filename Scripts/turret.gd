extends Area2D

@export var bullet_scene: PackedScene
@export var bullets_container: Node2D

# Настройки пулемёта
@export var spread_degrees: float = 14.0   # Градус разброса (чем больше, тем шире веер)
@export var barrel_offset: float = 110.0   # Смещение точки вылета к кончикам стволов

@onready var shoot_timer: Timer = $AttackTimer

func _ready() -> void:
	shoot_timer.timeout.connect(_shoot_nearest_enemy)
	shoot_timer.one_shot = false
	shoot_timer.wait_time = GameManager.turret_attack_delay
	shoot_timer.start()

func _physics_process(_delta: float) -> void:
	var target = _get_nearest_enemy()
	if is_instance_valid(target):
		look_at(target.global_position)

func _shoot_nearest_enemy() -> void:
	var target_enemy = _get_nearest_enemy()
	if not is_instance_valid(target_enemy) or not bullet_scene:
		return

	# Базовое направление ровно на врага
	var base_dir = (target_enemy.global_position - global_position).normalized()

	# ДОБАВЛЯЕМ РАНДОМНЫЙ РАЗБРОС
	var random_angle = deg_to_rad(randf_range(-spread_degrees, spread_degrees))
	var spread_dir = base_dir.rotated(random_angle)

	var bullet = bullet_scene.instantiate()
	
	# Пуля появляется не в центре турели, а на конце ствола
	bullet.global_position = global_position + (base_dir * barrel_offset)
	bullet.direction = spread_dir
	bullet.damage = GameManager.turret_damage

	# Поворачиваем сам спрайт пули по ходу её полёта
	bullet.rotation = spread_dir.angle()

	if bullets_container:
		bullets_container.add_child(bullet)
	else:
		get_tree().current_scene.add_child(bullet)

func _get_nearest_enemy() -> CharacterBody2D:
	var enemies = get_tree().get_nodes_in_group(&"enemies")
	var nearest: CharacterBody2D = null
	var min_dist: float = GameManager.turret_range

	for enemy in enemies:
		if is_instance_valid(enemy):
			var dist = global_position.distance_to(enemy.global_position)
			if dist < min_dist:
				min_dist = dist
				nearest = enemy
	return nearest
