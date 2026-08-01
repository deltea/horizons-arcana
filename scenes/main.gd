extends Node3D


const HAND_EXTEND_Y = 8.0
const HAND_RETRACT_Y = 2.5

const BOX_COUNT_MIN = 4
const BOX_COUNT_MAX = 6

const blind_box_scene = preload("res://scenes/blind_box/blind_box.tscn")
const phase_rect_scene = preload("res://scenes/ui/phase_rect.tscn")
const death_screen_scene = preload("res://scenes/ui/screens/death_screen.tscn")

@export var hand_open_texture: Texture2D
@export var hand_closed_texture: Texture2D

@export var phase_cashed_out_texture: Texture2D
@export var phase_exploded_texture: Texture2D
@export var phase_trashed: Texture2D

@export var item_pool: Array[ItemResource]

@onready var day_label: Label3D = $Turntable/Calendar/DayLabel

@onready var turntable: Node3D = $Turntable
@onready var trash_can: Sprite3D = $Turntable/TrashCan
@onready var hand: Sprite3D = $Turntable/Hand
@onready var spotlight: TextureRect = $CanvasLayer/Spotlight
@onready var earnings_label: Label3D = $Turntable/EarningsLabel

@onready var item_info: PanelContainer = $CanvasLayer/ItemInfo
@onready var item_name_label: Label = $CanvasLayer/ItemInfo/VBoxContainer/ItemNameLabel
@onready var item_desc_label: Label = $CanvasLayer/ItemInfo/VBoxContainer/ItemDescLabel
@onready var item_value_label: Label = $CanvasLayer/ItemInfo/VBoxContainer/ItemValueLabel

@onready var hearts_container: HBoxContainer = $CanvasLayer/HeartsContainer
@onready var flashbang: ColorRect = $CanvasLayer/Flashbang
@onready var phase_container: VBoxContainer = $CanvasLayer/PhaseContainer

var curr_day: int = -1
var hand_tween: Tween
var boxes: Array[int] = []
var boxes_left: int = 0
var daily_earnings: int = 0
var lives_left: int = 3


func _ready() -> void:
	Events.hand_extend.connect(_on_hand_extend)
	Events.hand_retract.connect(_on_hand_retract)
	Events.hand_grab.connect(_on_hand_grab)
	Events.box_opened.connect(_on_box_opened)
	Events.box_cashed_out.connect(_on_box_cashed_out)
	Events.box_converted.connect(_on_box_converted)
	Events.box_exploded.connect(_on_box_exploded)
	Events.flashbang.connect(_on_flashbang)

	item_info.hide()
	flashbang.self_modulate.a = 0.0

	next_day()


func _process(dt: float) -> void:
	turntable.rotate_y(dt * 0.1)
	for child in hearts_container.get_children():
		child.scale = sin(Clock.time * 5.0) * 0.05 * Vector2.ONE + Vector2.ONE


func next_day() -> void:
	set_day(curr_day + 1)

	boxes_left = randi_range(BOX_COUNT_MIN, BOX_COUNT_MAX)
	for child in phase_container.get_children():
		child.queue_free()
	for i in range(boxes_left):
		boxes.append(0)
		var phase_rect := phase_rect_scene.instantiate() as TextureRect
		phase_container.add_child(phase_rect)

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
	day_label.text = str(curr_day + 1)
	# spotlight.show()
	# await get_tree().create_timer(1.5).timeout
	# spotlight.hide()


func spawn_blind_box() -> void:
	var rand_item := item_pool.pick_random() as ItemResource
	item_name_label.text = rand_item.item_name
	item_desc_label.text = rand_item.item_desc
	item_value_label.text = "$" + str(rand_item.item_price)

	var blind_box := blind_box_scene.instantiate() as BlindBox
	turntable.add_child(blind_box)
	blind_box.set_info(rand_item.item_texture)
	blind_box.position.y = 14.2
	await blind_box.animate_in()
	await get_tree().create_timer(1.0).timeout
	blind_box.toggle_open(true)


func set_curr_phase(texture: Texture2D) -> void:
	phase_container.get_child(phase_container.get_child_count() - boxes_left).texture = texture


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


func _on_box_cashed_out(amount: int) -> void:
	daily_earnings += amount
	earnings_label.text = "Daily Earnings:\n$" + str(daily_earnings)
	set_curr_phase(phase_cashed_out_texture)


func _on_box_converted() -> void:
	item_info.hide()


func _on_box_opened(is_bomb: bool) -> void:
	if is_bomb:
		return
	item_info.show()


func _on_box_exploded() -> void:
	hearts_container.get_child(0).queue_free()
	set_curr_phase(phase_exploded_texture)
	lives_left -= 1
	if lives_left <= 0:
		print("Game Over")
		Engine.time_scale = 0.0
		var death_screen := death_screen_scene.instantiate() as DeathScreen
		get_tree().current_scene.add_child(death_screen)


func _on_flashbang(duration: float) -> void:
	flashbang.self_modulate.a = 1.0
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(flashbang, "self_modulate:a", 0.0, duration)


func _input(event: InputEvent) -> void:
	if not Events.DEBUG:
		return

	if event.is_action_pressed("click"):
		Events.input_shake.emit()
	if event.is_action_pressed("open"):
		Events.input_open.emit()
	if event.is_action_pressed("close"):
		Events.input_close.emit()
