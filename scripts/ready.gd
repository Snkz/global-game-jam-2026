extends Sprite2D
signal gamestart()
var start_tick = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer = get_node("Timer")
	timer.timeout.connect(_on_timer_timeout)
	get_parent().connect("gameover", _on_gameover)
	var rng = RandomNumberGenerator.new()
	var wait = rng.randf_range(2, 5);
	timer.wait_time = wait
	timer.start()
	
func _on_timer_timeout():
	visible = not visible
	var go = get_parent().get_node("Go")
	go.visible = true
	go.get_node("Timer").start()
	go.get_node("Timer").timeout.connect(_on_go_timer_timeout)
	gamestart.emit()
	start_tick = Time.get_ticks_msec()

func _on_go_timer_timeout():
	var go = get_parent().get_node("Go")
	go.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_gameover(score, time) -> void:
	var go = get_parent().get_node("Go")
	go.visible = false
	go.get_node("Timer").stop()
	visible = false
	get_node("Timer").stop()
	var total_time = Time.get_ticks_msec() - start_tick;
	var game = get_parent().get_node("Game")
	game.visible = true
	if (start_tick != -1):
		game.get_node("Label").text = " Mask OFF " + str(total_time).pad_decimals(2) + "ms"
	else:
		game.get_node("Label").text = " Mask OFF "

	
func _on_game_timer_timeout():
	var game = get_parent().get_node("Game")
	game.visible = false
	
