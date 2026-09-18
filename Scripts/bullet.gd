extends Area2D

var speed: float = 600.0
var damage: int = 15
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# Соединяем столкновение с врагом
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"enemies") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free() # Пуля уничтожается при контакте
