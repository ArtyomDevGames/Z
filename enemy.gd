extends CharacterBody2D

@export var max_hp: int = 75
var current_hp: int

@export var speed: float = 150.0
@export var bullet_scene: PackedScene

var target: Node2D

@onready var shoot_timer: Timer = $ShootTimer
@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	current_hp = max_hp
	if health_bar:
		health_bar.setup(max_hp)
	shoot_timer.timeout.connect(shoot)

func _physics_process(_delta: float) -> void:
	if is_instance_valid(target):
		look_at(target.global_position)
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func take_damage(amount: int) -> void:
	current_hp -= amount
	if health_bar:
		health_bar.update_hp(current_hp)
	if current_hp <= 0:
		queue_free()

func shoot() -> void:
	if not is_instance_valid(target) or bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	
	var direction = (target.global_position - global_position).normalized()
	if "direction" in bullet:
		bullet.direction = direction

	get_parent().add_child(bullet)
