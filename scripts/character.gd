extends CharacterBody2D

signal character_draw(int)
signal character_drawn(int, Vector2)
@export var player_index = 1

func _ready():
	get_node("Early").visible = false
	get_parent().get_node("Ready").connect("gamestart", _on_gamestart)
	get_parent().connect("gameover", _on_gameover)
	connect("character_drawn", _on_character_drawn)

var can_press = false
var failure = false

func _on_gamestart():
	if (not failure):
		can_press = true
	pass

func _on_gameover(winner, score):
	if (winner == player_index):
		$Sprite2D.play(&"win")
	else:
		$Sprite2D.play(&"loss")
			
	
func on_lost():
	if (not failure):
		failure = true
		# Play animation for first time
		if (not can_press):
			# Show failure indicator
			get_node("Early").visible = true
			get_parent().camera_shake.emit(0.15, 0.25)
			$Sprite2D.play(&"attack")

func _on_character_drawn(winner, pos):
	position = pos
	print("POS", winner, pos)
	$Sprite2D.play(&"attack")
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SHIFT:
			match event.location:
				KEY_LOCATION_LEFT:
					if (player_index == 1):
						character_draw.emit(player_index)
						if (can_press and not failure):
							can_press = false
						else:
							on_lost()
				KEY_LOCATION_RIGHT:
					if (player_index == 2):
						character_draw.emit(player_index)
						if (can_press and not failure):
							can_press = false
						else:
							on_lost()
