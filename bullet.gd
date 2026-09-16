extends Area2D

@export var speed: float = 400.0
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	apply_damage_and_destroy(body)

func _on_area_entered(area: Area2D) -> void:
	apply_damage_and_destroy(area)

func apply_damage_and_destroy(target_object: Node) -> void:
	if target_object.has_method("take_damage"):
		var damage = randi_range(10, 20)
		target_object.take_damage(damage)
		queue_free()
