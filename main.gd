extends Node2D

const PORT = 7777
@onready var PlayerScene = preload("res://Player.tscn")

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	start_server()

func start_server():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	spawn_player(multiplayer.get_unique_id())
	multiplayer.multiplayer_peer = peer
	print("Сервер запущено на порту ", PORT)

func connect_to_server(ip):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer

func _on_peer_connected(id):
	spawn_player(id)

func spawn_player(id):
	var player = PlayerScene.instantiate()
	player.name = str(id)
	add_child(player)
	player.global_position = Vector2(randi()%500, randi()%400)

func _on_peer_disconnected(id):
	if has_node(str(id)):
		get_node(str(id)).queue_free()
