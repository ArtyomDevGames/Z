extends Area2D

@export var max_hp: int = 250
var current_hp: int

@export var bullet_scene: PackedScene
@export var base_bullet_speed: float = 400.0

@onready var attack_timer: Timer = $AttackTimer
@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	current_hp = max_hp
	if health_bar:
		health_bar.setup(max_hp)
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func take_damage(amount: int) -> void:
	current_hp -= amount
	if health_bar:
		health_bar.update_hp(current_hp)
	if current_hp <= 0:
		queue_free() # Башня уничтожена

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_dir = (get_global_mouse_position() - global_position).normalized()
		spawn_bullet(mouse_dir, base_bullet_speed * 3.0)

func _on_attack_timer_timeout() -> void:
	var nearest_enemy = get_nearest_enemy()
	if nearest_enemy:
		var enemy_dir = (nearest_enemy.global_position - global_position).normalized()
		spawn_bullet(enemy_dir, base_bullet_speed)

func get_nearest_enemy() -> Node2D:
	var overlapping_bodies = get_overlapping_bodies()
	var nearest: Node2D = null
	var min_distance: float = INF

	for body in overlapping_bodies:
		if body is CharacterBody2D and body != self and body.has_method("shoot"):
			var dist = global_position.distance_to(body.global_position)
			if dist < min_distance:
				min_distance = dist
				nearest = body

	return nearest

func spawn_bullet(dir: Vector2, speed: float) -> void:
	if bullet_scene == null:
		return
		
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	
	if "direction" in bullet:
		bullet.direction = dir
	if "speed" in bullet:
		bullet.speed = speed
		
	get_parent().add_child(bullet)
