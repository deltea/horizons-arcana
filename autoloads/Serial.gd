extends Node


const PORT_NAME = "/dev/cu.usbmodem1101"
const BAUD_RATE = 9600

@onready var manager: GdSerialManager = GdSerialManager.new()


func _ready() -> void:
	manager.data_received.connect(_on_data_received)
	manager.port_disconnected.connect(_on_port_disconnected)

	if manager.open(PORT_NAME, BAUD_RATE, 1000, GdSerialManager.MODE_LINE_BUFFERED):
		print("connected to " + PORT_NAME)


func _process(dt: float) -> void:
	manager.poll_events()


func _on_data_received(port: String, data: PackedByteArray) -> void:
	print("data from ", port, ": ", data.get_string_from_utf8())


func _on_port_disconnected(port: String) -> void:
	print("lost connection to " + port)
