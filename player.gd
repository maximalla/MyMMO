extends CharacterBody2D

@export var speed: float = 350.0

var input_dir: Vector2 = Vector2.ZERO

func _physics_process(delta):

	if is_multiplayer_authority():

		var dir = Vector2.ZERO
		dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

		if multiplayer.is_server():
			# якщо це хост — напряму
			input_dir = dir
		else:
			# якщо клієнт — шлемо серверу
			rpc_id(1, "receive_input", dir)

	if multiplayer.is_server():
		velocity = input_dir.normalized() * speed
		move_and_slide()

		rpc("sync_position", global_position)

@rpc("any_peer")
func receive_input(dir: Vector2):
	if multiplayer.is_server():
		input_dir = dir

@rpc("unreliable")
func sync_position(pos: Vector2):
	if !multiplayer.is_server():
		global_position = pos
