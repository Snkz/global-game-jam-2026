extends Sprite2D
signal gamestart()
var start_tick = -1
var game_over = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer = get_node("Timer")
	timer.timeout.connect(_on_timer_timeout)
	get_parent().connect("gameover", _on_gameover)
	var rng = RandomNumberGenerator.new()
	var wait = rng.randf_range(2, 5);
	timer.wait_time = wait
	timer.start()
	game_over = false
	
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
var speed = 2
func _process(delta: float) -> void:
	if (game_over):
		var off = get_parent().get_node("Game").get_node("Off")
		if (off.position.y < 2790):
			off.position.y += 2 * speed
			speed = speed + 1
		if (off.position.y > 2790):
			off.position.y = 2790
	
func _on_gameover(score, time) -> void:
	game_over = true
	var go = get_parent().get_node("Go")
	go.visible = false
	go.get_node("Timer").stop()
	visible = false
	get_node("Timer").stop()
	var total_time = Time.get_ticks_msec() - start_tick;
	var game = get_parent().get_node("Game")
	game.visible = true
	var text = "Player 1: "
	if (score == 2):
		text = "Player 2: "
	if (start_tick != -1):
		game.get_node("Label").text = text + str(total_time).pad_decimals(2) + "ms"
	else:
		game.get_node("Label").text = "Double KO"

	
func _on_game_timer_timeout():
	var game = get_parent().get_node("Game")
	game.visible = false
	
