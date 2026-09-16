extends ProgressBar

@onready var hp_label: Label = $HPLabel

func setup(max_hp: int) -> void:
	max_value = max_hp
	value = max_hp
	update_text()

func update_hp(current_hp: int) -> void:
	value = current_hp
	update_text()

func update_text() -> void:
	if hp_label:
		hp_label.text = str(int(max_value)) + "/" + str(int(value))
