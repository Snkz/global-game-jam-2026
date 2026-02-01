extends CharacterBody2D

signal character_draw(int)
signal character_drawn(int, Vector2)
signal character_early(int)
@export var player_index = 1
var game_over = false
var can_press = false
var failure = false

func _ready():
	get_node("Early").visible = false
	get_parent().get_node("Ready").connect("gamestart", _on_gamestart)
	get_parent().connect("gameover", _on_gameover)
	connect("character_drawn", _on_character_drawn)
	connect("character_early", _on_character_early)
	game_over = false
	can_press = false
	failure = false

func _on_gamestart():
	if (not failure):
		can_press = true
	pass

func _on_gameover(winner, score):
	game_over = true
	if (winner == player_index):
		$Sprite2D.play(&"win")
	else:
		$Sprite2D.play(&"loss")
			
	
func _on_character_early(player_index):
	if (not failure):
		failure = true
		# Show failure indicator
		get_node("Early").visible = true
		get_parent().camera_shake.emit(0.15, 0.25)
		$Sprite2D.play(&"attack")

func _on_character_drawn(winner, pos):
	position = pos
	$Sprite2D.play(&"attack")
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
	
func _unhandled_input(event: InputEvent) -> void:
	if (game_over):
		return

	var min_x = DisplayServer.window_get_size().x / 2 - 20;
	var max_x = DisplayServer.window_get_size().x - (DisplayServer.window_get_size().x / 2 - 20);
	
	if event is InputEventScreenTouch:
		if (event.pressed and event.position.x < min_x):
			if (player_index == 1 and can_press):
				character_draw.emit(player_index)
				get_tree().get_root().set_input_as_handled()
			elif (player_index == 1 and not can_press and not failure):
				character_early.emit(player_index)
				get_tree().get_root().set_input_as_handled()
		elif (event.pressed and event.position.x > max_x):
			if (player_index == 2 and can_press):
				character_draw.emit(player_index)
				get_tree().get_root().set_input_as_handled()
			elif (player_index == 2 and not can_press and not failure):
				character_early.emit(player_index)
				get_tree().get_root().set_input_as_handled()

	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SHIFT:
			match event.location:
				KEY_LOCATION_LEFT:
					if (player_index == 1 and can_press):
						character_draw.emit(player_index)
						get_tree().get_root().set_input_as_handled()
					elif (player_index == 1 and not can_press and not failure):
						character_early.emit(player_index)
						get_tree().get_root().set_input_as_handled()
				KEY_LOCATION_RIGHT:
					if (player_index == 2 and can_press):
						character_draw.emit(player_index)
						get_tree().get_root().set_input_as_handled()
					elif (player_index == 2 and not can_press and not failure):
						character_early.emit(player_index)
						get_tree().get_root().set_input_as_handled()
