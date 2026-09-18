extends Node2D

@export var wave_duration: float = 20.0
var time_left: float

@onready var timer_label: Label = $Ui/WaveTimerLabel
@onready var shop_panel: Control = $Ui/ShopPanel

func _ready() -> void:
	start_wave()

func _process(delta: float) -> void:
	if time_left > 0:
		time_left -= delta
		# Выводит: "TIME: 19.4" (секунды с десятыми долями)
		timer_label.text = "TIME: %.1f" % max(0.0, time_left)
		
		# Либо если нужны ТОЛЬКО голые цифры (например: 19.45):
		# timer_label.text = "%.2f" % max(0.0, time_left)

		if time_left <= 0:
			end_wave()

func start_wave() -> void:
	time_left = wave_duration
	shop_panel.visible = false
	get_tree().paused = false
	$EnemySpawner.start_spawning(0.2) # Спавним мясо каждые 0.2 сек

func end_wave() -> void:
	$EnemySpawner.stop_spawning()
	get_tree().paused = true
	shop_panel.visible = true # Открываем магазин прокачки

# Подключи сигнал pressed() от кнопки NextWaveBtn сюда:
func _on_next_wave_btn_pressed() -> void:
	start_wave()
