extends Camera2D

@export var grid_height: int
@export var grid_width: int
@export var playable_area_offset: Vector2

@export var max_camera_shake_offset = Vector2(100, 75) 
@export var max_camera_roll = 0.1 
@export var respawn_rate := 30.0
@export var respawn_cap := 1
@export var respawn_as_mimic_chance := 0.5

var rng = RandomNumberGenerator.new()
var matched_count = 0
var game_time = 0.0
var noise = null
var camera_shake_lifetime = 0
var camera_shake_strength = 0
var game_started = false
var game_over = false
var game_ending = false

signal gameover(int, float)
signal camera_shake(a, b)

func do_camera_shake(strength, seed) -> void:
	var amount = pow(strength, 2)
	rotation = max_camera_roll * amount * randf_range(-1.0, 1.0)
	offset.x = max_camera_shake_offset.x * amount * randf_range(-1.0, 1.0)
	offset.y = max_camera_shake_offset.y * amount * randf_range(-1.0, 1.0)

func _on_camera_shake(strength, lifetime) -> void:
	noise.seed = randi()
	camera_shake_lifetime = max(camera_shake_lifetime, lifetime)
	camera_shake_strength = max(camera_shake_strength, strength)
	
func _on_gameover(winner) -> void:
	camera_shake.emit(0.5, 0.25)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

	var screen_res = Vector2()
	screen_res.x = ProjectSettings.get_setting("display/window/size/viewport_width")
	screen_res.y = ProjectSettings.get_setting("display/window/size/viewport_height")
	camera_shake_strength = 0;
	camera_shake_lifetime = 0;
	offset = Vector2(0.0, 0.0)
	rotation = 0.0
	game_over = false
	game_started = false
	game_ending = false

	connect("camera_shake", _on_camera_shake)
	connect("gameover", _on_gameover)
	get_node("Ready").connect("gamestart", _on_gamestart)
	get_node("first_player").connect("character_draw", _on_character_draw)
	get_node("second_player").connect("character_draw", _on_character_draw)

func _on_character_draw(player):
	if (not game_started or game_ending):
		return
	
	game_ending = true
	get_node("Impact").visible = true
	await get_tree().create_timer(0.05, true, false, true).timeout
	get_node("ImpactFollowUp").visible = true
	var first_player = get_node("first_player")
	var second_player = get_node("second_player")
	var fp_pos = first_player.position
	var sp_pos = second_player.position
	first_player.character_drawn.emit(player, sp_pos)
	second_player.character_drawn.emit(player, fp_pos)

	await get_tree().create_timer(0.05, true, false, true).timeout

	get_node("Impact").visible = false
	get_node("ImpactFollowUp").visible = false
	
	await get_tree().create_timer(0.5, true, false, true).timeout

	gameover.emit(player, 10)
	game_over = true


func _on_gamestart():
	camera_shake.emit(0.5, 0.25)
	game_started = true
  	#var gameover = self.get_node("gameover")
	#gameover.connect("restart", _on_restart)
	#var intro = self.get_node("intro")
  	#intro.connect("restart", _on_restart)
			
func _process(delta):
	var window_rect = get_viewport().get_visible_rect()
	var mouse_pos = get_viewport().get_mouse_position()
	game_time = game_time + delta
	
	if camera_shake_lifetime > 0:
		do_camera_shake(camera_shake_strength, noise.seed)
		camera_shake_lifetime -= delta
	else:
		camera_shake_strength = 0;
		camera_shake_lifetime = 0;
		offset = Vector2(0.0, 0.0)
		rotation = 0.0

	if window_rect.has_point(mouse_pos):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event):
	if OS.get_name() == "Web":
		return
		
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.keycode == KEY_SHIFT and game_over:
			get_tree().reload_current_scene()
