extends CanvasLayer

@onready var title_label = $Panel/VBoxContainer/TitleLabel
@onready var stats_label = $Panel/VBoxContainer/StatsLabel

# Referencias a los botones de bebidas
@onready var btn_gaseosa = $Panel/VBoxContainer/DrinksContainer/BtnGaseosa
@onready var btn_cerveza = $Panel/VBoxContainer/DrinksContainer/BtnCerveza

@onready var btn_upgrade = $Panel/VBoxContainer/BtnUpgrade
@onready var btn_next_day = $Panel/VBoxContainer/BtnNextDay

var cost_gaseosa: int = 5
var cost_cerveza: int = 10
var upgrade_price: int = 500

func _ready() -> void:
	update_ui()

func update_ui() -> void:
	if Global.current_day == 1 and Global.total_orders_today == 0:
		title_label.text = "--- INICIO DEL DÍA 1 ---"
	else:
		title_label.text = "--- FIN DEL DÍA " + str(Global.current_day - 1) + " ---"
	
	# Mostrar inventario detallado solo con Gaseosa y Cerveza
	stats_label.text = "Plata Total: $" + str(Global.money) + "\n"
	stats_label.text += "Stock Gaseosa: " + str(Global.stock_gaseosa) + " | Stock Cerveza: " + str(Global.stock_cerveza) + "\n"
	stats_label.text += "Nivel del Local: " + str(Global.restaurant_level)
	
	btn_gaseosa.text = "Gaseosa ($" + str(cost_gaseosa) + ")"
	btn_cerveza.text = "Cerveza ($" + str(cost_cerveza) + ")"
	
	btn_upgrade.text = "Subir de Nivel ($" + str(upgrade_price) + ")"
	btn_next_day.text = "Empezar Día"
	
	if Global.current_day == 1 and Global.total_orders_today == 0:
		btn_upgrade.disabled = true
		
		# Límite individual de 10 por bebida en el día 1
		btn_gaseosa.disabled = Global.stock_gaseosa >= 10
		btn_cerveza.disabled = Global.stock_cerveza >= 10
	else:
		# Días siguientes: solo se bloquean si no tenés plata
		btn_gaseosa.disabled = Global.money < cost_gaseosa
		btn_cerveza.disabled = Global.money < cost_cerveza
		btn_upgrade.disabled = Global.money < upgrade_price

# --- FUNCIONES DE COMPRA ---

func _on_btn_gaseosa_pressed() -> void:
	Global.money -= cost_gaseosa
	Global.stock_gaseosa += 1
	update_ui()

func _on_btn_cerveza_pressed() -> void:
	Global.money -= cost_cerveza
	Global.stock_cerveza += 1
	update_ui()

func _on_btn_upgrade_pressed() -> void:
	Global.money -= upgrade_price
	Global.restaurant_level += 1
	upgrade_price += 500
	update_ui()

func _on_btn_next_day_pressed() -> void:
	Global.daily_profit = 0
	Global.total_orders_today = 0
	get_tree().change_scene_to_file("res://Scenes/main_lvl.tscn")
