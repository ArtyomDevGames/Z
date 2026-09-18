extends Node

# Сигналы для обновления интерфейса (UI)
signal stats_changed
signal wave_started(wave_number: int)
signal wave_ended(victory: bool)
signal base_hp_changed(current: int, max_hp: int)

# Экономика и база
var money: int = 0
var base_max_hp: int = 100
var base_current_hp: int = 100

# Характеристики прокачки (GDD: Must Have)
var turret_damage: int = 15
var turret_attack_delay: float = 0.12 
var turret_range: float = 1200.0
var sniper_damage: int = 35
var money_multiplier: float = 1.0

# Стоимость прокачки
var turret_damage_cost: int = 20
var sniper_damage_cost: int = 15

func add_money(amount: int) -> void:
	money += int(amount * money_multiplier)
	stats_changed.emit()

func _on_enemy_died(bounty: int) -> void:
	add_money(bounty)

func _on_base_damaged(amount: int) -> void:
	base_current_hp = max(0, base_current_hp - amount)
	base_hp_changed.emit(base_current_hp, base_max_hp)
	if base_current_hp <= 0:
		wave_ended.emit(false) # Поражение (по GDD деньги и апы остаются!)

# Методы покупки апгрейдов для кнопок UI
func upgrade_turret_damage() -> bool:
	if money >= turret_damage_cost:
		money -= turret_damage_cost
		turret_damage += 5
		turret_damage_cost = int(turret_damage_cost * 1.4) # Рост цены
		stats_changed.emit()
		return true
	return false

func upgrade_sniper_damage() -> bool:
	if money >= sniper_damage_cost:
		money -= sniper_damage_cost
		sniper_damage += 15
		sniper_damage_cost = int(sniper_damage_cost * 1.5)
		stats_changed.emit()
		return true
	return false
