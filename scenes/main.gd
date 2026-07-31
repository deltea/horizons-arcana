extends Node3D


const blind_box_scene = preload("res://scenes/blind_box/blind_box.tscn")

@onready var inspecting_progress_bar: TextureProgressBar = $CanvasLayer/MarginContainer/InspectingProgressBar
@onready var opening_progress_bar: TextureProgressBar = $CanvasLayer/MarginContainer/OpeningProgressBar


func _ready() -> void:
	next_day()


func next_day() -> void:
	spawn_blind_box()


func spawn_blind_box() -> void:
	var blind_box := blind_box_scene.instantiate() as BlindBox
	add_child(blind_box)
	blind_box.position.y = 14.2
	var tween := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(blind_box, "position:y", 3.3, 1.0)
	tween.tween_interval(0.5)
	tween.tween_callback(func() -> void: blind_box.toggle_open(true))
