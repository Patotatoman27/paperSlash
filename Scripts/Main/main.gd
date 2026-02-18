extends Node

#Singlepayer
const DummyNetworkAdapter = preload("res://addons/godot-rollback-netcode/DummyNetworkAdaptor.gd")

const LOGFILEDIRECTORY = "user://detailed_logs";
var loggingEnabled := false;

@onready var host: LineEdit = $CanvasLayer/MainPanel/MarginContainer/Panel/Host
@onready var port: LineEdit = $CanvasLayer/MainPanel/MarginContainer/Panel/Port
@onready var serverButton: Button = $CanvasLayer/MainPanel/MarginContainer/Panel/ServerButton
@onready var clientButton: Button = $CanvasLayer/MainPanel/MarginContainer/Panel/ClientButton
@onready var message: Label = $CanvasLayer/Message
@onready var syncLabel: Label = $CanvasLayer/SyncLabel
@onready var mainPanel: Window = $CanvasLayer/MainPanel
@onready var reset: Button = $CanvasLayer/Reset
@onready var mainMenu: VBoxContainer = $CanvasLayer/MainMenu

@onready var player1: Node2D = $"World/Player1"
@onready var player2: Node2D = $"World/Player2"

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_network_peer_connected)
	multiplayer.peer_disconnected.connect(_on_network_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	SyncManager.sync_started.connect(_on_SyncManager_sync_started)
	SyncManager.sync_stopped.connect(_on_SyncManager_sync_stopped)
	SyncManager.sync_lost.connect(_on_SyncManager_sync_lost)
	SyncManager.sync_regained.connect(_on_SyncManager_sync_regained)
	SyncManager.sync_error.connect(_on_SyncManager_sync_error)

func _on_server_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(int(port.text), 1)
	multiplayer.multiplayer_peer = peer
	mainPanel.visible = false
	message.text = "Listening..."


func _on_client_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(host.text, int(port.text))
	multiplayer.multiplayer_peer = peer
	mainPanel.visible = false
	message.text = "Conecting..."

func _on_network_peer_connected(peer_id: int) -> void:
	message.text = "Connected"
	SyncManager.add_peer(peer_id)
	
	player1.set_multiplayer_authority(1)
	if multiplayer.is_server():
		player2.set_multiplayer_authority(peer_id)
	else:
		player2.set_multiplayer_authority(multiplayer.get_unique_id())
	if multiplayer.is_server():
		message.text = "Starting..."
		await get_tree().create_timer(2.0).timeout
		SyncManager.start()

func _on_network_peer_disconnected(peer_id: int) -> void:
	message.text = "Disconnected"
	SyncManager.remove_peer(peer_id)

func _on_server_disconnected() -> void:
	#_on_network_peer_disconnected(1)
	message.text = "Server disconnected"
	SyncManager.clear_peers()

#region Sync Manager
func _on_SyncManager_sync_started():
	message.text = "Started!"
	#Debug Log
	if loggingEnabled and not SyncReplay.active:
		# Crear carpeta si no existe
		if not DirAccess.dir_exists_absolute(LOGFILEDIRECTORY):
			DirAccess.make_dir_recursive_absolute(LOGFILEDIRECTORY)

		# Fecha actual (UTC si true)
		var datetime := Time.get_datetime_dict_from_system(true)

		var logFileName := "%04d%02d%02d-%02d%02d%02d-peer-%d.log" % [
			datetime.year,
			datetime.month,
			datetime.day,
			datetime.hour,
			datetime.minute,
			datetime.second,
			multiplayer.get_unique_id(),
		]

		SyncManager.start_logging(LOGFILEDIRECTORY.path_join(logFileName))



func _on_SyncManager_sync_stopped():
	if loggingEnabled:
		SyncManager.stop_logging()

func _on_SyncManager_sync_lost():
	syncLabel.visible = true;

func _on_SyncManager_sync_regained():
	syncLabel.visible = false;

func _on_SyncManager_sync_error(msg: String):
	message.text = "Fatal Sync Error: " + msg
	syncLabel.visible = false;
	SyncManager.clear_peers()
	var peer = multiplayer.multiplayer_peer
	if peer:
		peer.close()
	multiplayer.multiplayer_peer = null


#region Reset
func _on_reset_pressed() -> void:
	SyncManager.stop()
	SyncManager.clear_peers()
	var peer = multiplayer.multiplayer_peer
	if peer:
		peer.close()
		multiplayer.multiplayer_peer = null
	get_tree().reload_current_scene()

func setup_match_for_replay(_my_peer_id : int, _peer_ids : Array, _match_info: Dictionary):
	print("Inicio de Replay")
	mainMenu.visible = false;
	mainPanel.visible = false;
	reset.visible = false;


func _on_singleplayer_pressed() -> void:
	mainMenu.visible = false;
	player2.inputPrefix = "P2_"
	SyncManager.network_adaptor = DummyNetworkAdapter.new()
	SyncManager.start();
	
func _on_online_pressed() -> void:
	SyncManager.reset_network_adaptor()
	mainMenu.visible = false;
	mainPanel.visible = true;
