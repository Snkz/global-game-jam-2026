extends Sprite2D
signal gamestart()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer = get_node("Timer")
	timer.timeout.connect(_on_timer_timeout)
	connect("gameover", _on_gameover)

	
func _on_timer_timeout():
	visible = not visible
	var go = get_parent().get_node("Go")
	go.visible = true
	go.get_node("Timer").start()
	go.get_node("Timer").timeout.connect(_on_go_timer_timeout)
	gamestart.emit()
	print("Game start")

func _on_go_timer_timeout():
	var go = get_parent().get_node("Go")
	go.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_gameover(score, time) -> void:
	var game = get_parent().get_node("Game")
	game.visble = true
	game.get_node("Timer").start()
	game.get_node("Timer").timeout.connect(_on_game_timer_timeout)
	
func _on_game_timer_timeout():
	var game = get_parent().get_node("Game")
	game.visible = false
