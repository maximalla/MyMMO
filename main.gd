extends Node2D

const PORT = 7777
@onready var PlayerScene = preload("res://Player.tscn")

func _ready():
	var config = ConfigFile.new()
	var err = config.load("res://config.local.cfg")
	var mode = "client"
	var ip = "25.46.104.9"
	
	if err == OK:
		mode = config.get_value("network", "mode", "client")
		ip = config.get_value("network", "ip", "25.46.104.9")
		
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	if mode == "host":
		start_server()
	else:
		connect_to_server(ip)
	
	

# --- HOST ---
func start_server():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer 
	print("Сервер запущено")
	
	# Сервер створює себе через RPC
	spawn_player.rpc(multiplayer.get_unique_id())

# --- CLIENT ---
func connect_to_server(ip):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer

	print("Підключення...")

func _on_peer_connected(id):
	print("Підключився гравець: ", id)
	spawn_player.rpc(id)

@rpc("any_peer", "call_local")
func spawn_player(id):
	if has_node(str(id)):
		return   # захист від дублювання

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
		#print("Connection status:", status) # якшо 0 - не запустилося 1 - не підключилося, 2 - ок
