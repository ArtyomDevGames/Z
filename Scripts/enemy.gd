extends CharacterBody2D

@export var max_hp: int = 75
var current_hp: int

@export var speed: float = 150.0
@export var bullet_scene: PackedScene   # Перетащи bullet.tscn сюда
@export var bullets_container: Node2D   # Передаётся из спавнера

var target: Node2D

@onready var shoot_timer: Timer = $ShootTimer
@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	current_hp = max_hp
	if health_bar:
		health_bar.setup(max_hp)
	shoot_timer.timeout.connect(shoot)
	add_to_group(&"enemies")
	if sprite and sprite.sprite_frames:
		sprite.play()

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(target):
		return

	var to_target = target.global_position - global_position
	var direction = to_target.normalized()

	# Вращаем только спрайт, чтобы HP-бар не крутился
	if sprite:
		sprite.look_at(target.global_position)

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

	# Передаём контейнер пуле, если у неё есть такое поле
	if "bullets_container" in bullet:
		bullet.bullets_container = bullets_container

	# Добавляем пулю в контейнер Bullets из Main
	if bullets_container:
		bullets_container.add_child(bullet)
	else:
		get_parent().add_child(bullet)
