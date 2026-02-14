extends CharacterBody2D

@export var speed: float = 350.0

func _physics_process(delta):
	if !is_multiplayer_authority():
		return

	var dir = Vector2.ZERO
	dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	velocity = dir.normalized() * speed
	move_and_slide()

	rpc("sync_position", global_position)

@rpc("unreliable")
func sync_position(pos: Vector2):
	if !is_multiplayer_authority():
		global_position = pos
