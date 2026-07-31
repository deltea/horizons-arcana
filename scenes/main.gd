extends Node3D


const blind_box_scene = preload("res://scenes/blind_box/blind_box.tscn")

@onready var inspecting_progress_bar: TextureProgressBar = $CanvasLayer/MarginContainer/InspectingProgressBar
@onready var opening_progress_bar: TextureProgressBar = $CanvasLayer/MarginContainer/OpeningProgressBar

@onready var trash_bin: Bin = $TrashBin


func _ready() -> void:
	next_day()


func next_day() -> void:
	spawn_blind_box()


func spawn_blind_box() -> void:
	var blind_box := blind_box_scene.instantiate() as BlindBox
	add_child(blind_box)
	blind_box.position.y = 14.2
	blind_box.animate_in()
	await get_tree().create_timer(1.5).timeout
	blind_box.toggle_open(true)
	await get_tree().create_timer(1.5).timeout
	blind_box.item.throw_in_bin(trash_bin)
