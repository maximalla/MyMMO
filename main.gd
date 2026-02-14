extends Node2D

const PORT = 7777
@onready var PlayerScene = preload("res://Player.tscn")

func _ready():
	start_server() # якшо хост - розкоментувати
	
	#connect_to_server("31.43.49.240") # якшо клієнт - розкоментувати
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

# --- HOST ---
func start_server():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	
	print("Сервер запущено")
	
	spawn_player(multiplayer.get_unique_id())

# --- CLIENT ---
func connect_to_server(ip):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer

	print("Підключення...")

func _on_peer_connected(id):
	print("Підключився гравець: ", id)
	spawn_player(id)

func spawn_player(id):
	var player = PlayerScene.instantiate()
	player.name = str(id)
	add_child(player)
	player.global_position = Vector2(randi()%500, randi()%400)
	player.set_multiplayer_authority(id)

func _on_peer_disconnected(id):
	if has_node(str(id)):
		get_node(str(id)).queue_free()

func _process(delta):
	if multiplayer.multiplayer_peer:
		var status = multiplayer.multiplayer_peer.get_connection_status()
		print("Connection status:", status)
