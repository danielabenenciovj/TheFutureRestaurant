extends VisibleOnScreenEnabler2D

var Money = -1000
var GlobalSeconds = 180

@onready var label_Money = $Money
@onready var label_Watch = $Watch
@onready var Timer_Node = $Timer

func _ready():
	Update_Money()
	Timer_Node.timeout.connect(_After_One_Second)
	
func _After_One_Second():
	if GlobalSeconds > 0:
		GlobalSeconds -= 1
		Update_Timer()
	else:
		Timer_Node.stop()
		label_Watch.text = "00:00"
		
		var main_level = get_tree().get_first_node_in_group("MainLevel")
		if main_level != null:
			main_level.stop_spawning_customers()
		
func Update_Money():
	label_Money.text = "Cash: $" + str(Money)
	
func Update_Timer():
	var Mins = GlobalSeconds / 60
	var Seconds = GlobalSeconds % 60
	label_Watch.text = "%02d:%02d" % [Mins, Seconds]
	
func Add_Money(Amount):
	Money += Amount
	Update_Money()
