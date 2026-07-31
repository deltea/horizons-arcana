extends Node3D


const HAND_EXTEND_Y = 8.0
const HAND_RETRACT_Y = 2.5

const BOX_COUNT_MIN = 3
const BOX_COUNT_MAX = 6

const blind_box_scene = preload("res://scenes/blind_box/blind_box.tscn")

@export var hand_open_texture: Texture2D
@export var hand_closed_texture: Texture2D

@export var item_pool: Array[ItemResource]

@onready var day_label: Label3D = $Turntable/DayLabel

@onready var turntable: Node3D = $Turntable
@onready var trash_bin: Bin = $Turntable/TrashBin
@onready var hand: Sprite3D = $Turntable/Hand

var curr_day: int = -1
var hand_tween: Tween
var boxes: Array[int] = []
var boxes_left: int = 0


func _ready() -> void:
	Events.hand_extend.connect(_on_hand_extend)
	Events.hand_retract.connect(_on_hand_retract)
	Events.hand_grab.connect(_on_hand_grab)

	next_day()


func _process(dt: float) -> void:
	turntable.rotate_y(dt * 0.1)


func next_day() -> void:
	set_day(curr_day + 1)

	boxes_left = randi_range(BOX_COUNT_MIN, BOX_COUNT_MAX)
	for i in range(boxes_left): boxes.append(0)

	while boxes_left > 0:
		next_box()
		await Events.box_resolved
		boxes_left -= 1
		print(str(boxes_left) + " boxes left")

	next_day()


func next_box() -> void:
	spawn_blind_box()


func set_day(new_day: int) -> void:
	curr_day = new_day
	day_label.text = "DAY %d" % (curr_day + 1)
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


func _on_hand_extend() -> void:
	hand_tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	hand_tween.tween_property(hand, "position:y", HAND_EXTEND_Y, 0.5)


func _on_hand_retract() -> void:
	hand_tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	hand_tween.tween_property(hand, "position:y", HAND_RETRACT_Y, 0.5)
	hand_tween.tween_callback(func() -> void: hand.texture = hand_open_texture)


func _on_hand_grab() -> void:
	hand.texture = hand_closed_texture
	Events.cam_shake.emit(0.4)


func _input(event: InputEvent) -> void:
	if not Events.DEBUG:
		return

	if event.is_action_pressed("click"):
		Events.input_shake.emit()
	if event.is_action_pressed("open"):
		Events.input_open.emit()
	if event.is_action_pressed("close"):
		Events.input_close.emit()
