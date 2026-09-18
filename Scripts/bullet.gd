extends Area2D

@export var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT
var bullets_container: Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if sprite and sprite.sprite_frames:
		sprite.play()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	if sprite:
		sprite.look_at(global_position + direction)
