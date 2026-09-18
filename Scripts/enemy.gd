extends CharacterBody2D

signal died(bounty: int)
signal reached_base(damage: int) 
@export var max_hp: int = 30
@export var speed: float = 90.0
@export var bounty: int = 5
@export var stop_distance: float = 280.0 # Дистанция, где он встаёт и начинает стрелять
@export var shoot_interval: float = 1.2  # Частота выстрела по базе
@export var bullet_scene: PackedScene    # Сцена bullet.tscn

var current_hp: int
var target_base: Node2D
var shoot_cooldown: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	current_hp = max_hp
	add_to_group(&"enemies")
	
	# Разброс скорости, чтобы толпа шла живой массой
	speed = randf_range(speed * 0.85, speed * 1.15)
	
	# Включаем кликабельность мыши кодом на всякий случай
	input_pickable = true
	
	# Ищем базу
	target_base = get_tree().get_first_node_in_group(&"base")
	
	if sprite and sprite.sprite_frames:
		sprite.play()

func _physics_process(delta: float) -> void:
	# 1. Ищем турель напрямую по имени, без всяких групп
	if not is_instance_valid(target_base):
		target_base = get_tree().current_scene.get_node_or_null("TargetPoint")

	# 2. Движение
	if is_instance_valid(target_base):
		var to_base = target_base.global_position - global_position
		look_at(target_base.global_position)
		
		if to_base.length() > stop_distance:
			velocity = to_base.normalized() * speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			shoot_cooldown -= delta
			if shoot_cooldown <= 0.0:
				shoot_cooldown = shoot_interval
				_shoot_at_base()
	else:
		# ЕСЛИ БАЗУ НЕ НАШЛИ — ТУПО БЕЖИМ ВЛЕВО НА ЭКРАН!
		velocity = Vector2.LEFT * speed
		move_and_slide()

# Стрельба врага по базе
func _shoot_at_base() -> void:
	if bullet_scene and is_instance_valid(target_base):
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = (target_base.global_position - global_position).normalized()
		# Добавляем пулю на главную сцену
		get_tree().current_scene.add_child(bullet)

# Клик игрока (Снайперка)
func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		take_damage(GameManager.sniper_damage)
		get_viewport().set_input_as_handled()

func take_damage(amount: int) -> void:
	current_hp -= amount
	
	# Вспышка красным цветом при попадании
	modulate = Color(2.5, 0.3, 0.3) # Ярко-красный
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.08)

	if current_hp <= 0:
		died.emit(bounty)
		queue_free()
