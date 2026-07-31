extends Node3D


const blind_box_scene = preload("res://scenes/blind_box/blind_box.tscn")

@onready var inspecting_progress_bar: TextureProgressBar = $CanvasLayer/MarginContainer/InspectingProgressBar
@onready var opening_progress_bar: TextureProgressBar = $CanvasLayer/MarginContainer/OpeningProgressBar
@onready var day_label: Label3D = $Turntable/DayLabel

@onready var turntable: Node3D = $Turntable
@onready var trash_bin: Bin = $Turntable/TrashBin

var curr_day: int = -1


func _ready() -> void:
	next_day()


func _process(dt: float) -> void:
	turntable.rotate_y(dt * 0.1)


func next_day() -> void:
	set_day(curr_day + 1)
	spawn_blind_box()


func set_day(new_day: int) -> void:
	curr_day = new_day
	day_label.text = "DAY %d" % curr_day
	day_label.position.y = 13.0
	var tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(day_label, "position:y", 10.0, 1.0)
	tween.tween_interval(1.0)
	tween.tween_property(day_label, "position:y", 13.0, 0.5)


func spawn_blind_box() -> void:
	var blind_box := blind_box_scene.instantiate() as BlindBox
	turntable.add_child(blind_box)
	blind_box.position.y = 14.2
	blind_box.animate_in()
	await get_tree().create_timer(1.5).timeout
	blind_box.toggle_open(true)
