extends Node3D


const HAND_EXTEND_Y = 8.0
const HAND_RETRACT_Y = 2.5

const BOX_COUNT_MIN = 4
const BOX_COUNT_MAX = 6

const BOX_COST = 10

const blind_box_scene = preload("res://scenes/blind_box/blind_box.tscn")
const phase_rect_scene = preload("res://scenes/ui/phase_rect.tscn")
const death_screen_scene = preload("res://scenes/ui/screens/death_screen.tscn")
const alert_label_scene = preload("res://scenes/ui/alert_label.tscn")

@export var hand_open_texture: Texture2D
@export var hand_closed_texture: Texture2D

@export var phase_cashed_out_texture: Texture2D
@export var phase_exploded_texture: Texture2D
@export var phase_trashed_texture: Texture2D

@export var item_pool: Array[ItemResource]

@onready var day_label: Label3D = $Turntable/Calendar/DayLabel

@onready var turntable: Node3D = $Turntable
@onready var trash_can: Sprite3D = $Turntable/TrashCan
@onready var hand: Sprite3D = $Turntable/Hand
@onready var spotlight: TextureRect = $CanvasLayer/Spotlight
@onready var earnings_label: Label3D = $Turntable/EarningsLabel

@onready var item_info: PanelContainer = $CanvasLayer/ItemContainer/ItemInfo
@onready var item_name_label: Label = $CanvasLayer/ItemContainer/ItemInfo/VBoxContainer/ItemNameLabel
@onready var item_desc_label: Label = $CanvasLayer/ItemContainer/ItemInfo/VBoxContainer/ItemDescLabel
@onready var item_value_label: Label = $CanvasLayer/ItemContainer/ItemInfo/VBoxContainer/ItemValueLabel

@onready var hearts_container: HBoxContainer = $CanvasLayer/HeartsContainer
@onready var flashbang: ColorRect = $CanvasLayer/Flashbang
@onready var phase_container: VBoxContainer = $CanvasLayer/PhaseContainer
@onready var timer_progress_bar: ProgressBar = $CanvasLayer/ProgressBar

@onready var timer: Timer = $Timer

var curr_day: int = -1
var hand_tween: Tween
var boxes: Array[int] = []
var boxes_left: int = 0
var total_earnings: int = 0
var lives_left: int = 5
var curr_box: BlindBox


func _ready() -> void:
	Events.hand_extend.connect(_on_hand_extend)
	Events.hand_retract.connect(_on_hand_retract)
	Events.hand_grab.connect(_on_hand_grab)
	Events.box_opened.connect(_on_box_opened)
	Events.box_cashed_out.connect(_on_box_cashed_out)
	Events.box_converted.connect(_on_box_converted)
	Events.box_exploded.connect(_on_box_exploded)
	Events.flashbang.connect(_on_flashbang)

	Events.input_open.connect(_on_input_open)
	Events.input_close.connect(_on_input_close)
	Events.input_shake.connect(_on_input_shake)

	item_info.hide()
	timer_progress_bar.hide()
	flashbang.self_modulate.a = 0.0

	next_day()


func _process(dt: float) -> void:
	turntable.rotate_y(dt * 0.1)
	for child in hearts_container.get_children():
		child.scale = sin(Clock.time * 5.0) * 0.05 * Vector2.ONE + Vector2.ONE

	timer_progress_bar.value = timer.time_left / timer.wait_time


func next_day() -> void:
	set_day(curr_day + 1)

	boxes_left = randi_range(BOX_COUNT_MIN, BOX_COUNT_MAX)

	# spend money to buy more boxes
	if curr_day != 0:
		set_curr_cash(total_earnings - (boxes_left * BOX_COST))
		var alert_label := alert_label_scene.instantiate() as AlertLabel
		alert_label.position = earnings_label.position
		alert_label.position.z += 2.0
		alert_label.text = "spent $" + str(boxes_left * BOX_COST) + " to buy more boxes"
		turntable.add_child(alert_label)

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

	await get_tree().create_timer(1.0).timeout
	next_day()


func next_box() -> void:
	spawn_blind_box()


func set_day(new_day: int) -> void:
	curr_day = new_day
	day_label.text = str(curr_day + 1)


func spawn_blind_box() -> void:
	var rand_item := get_random_item()
	item_name_label.text = rand_item.item_name
	item_desc_label.text = rand_item.item_desc
	var rarity_name := ItemResource.ItemRarity.keys()[rand_item.item_rarity] as String
	item_value_label.text = rarity_name + "  /  $" + str(rand_item.item_price)

	var blind_box := blind_box_scene.instantiate() as BlindBox
	curr_box = blind_box
	blind_box.item_resource = rand_item
	turntable.add_child(blind_box)
	blind_box.position.y = 14.2
	await blind_box.animate_in()
	timer.start()
	timer_progress_bar.show()


func get_rarity_weight(rarity: ItemResource.ItemRarity) -> int:
	match rarity:
		ItemResource.ItemRarity.COMMON:
			return 50
		ItemResource.ItemRarity.UNCOMMON:
			return 30
		ItemResource.ItemRarity.RARE:
			return 15
		ItemResource.ItemRarity.LEGENDARY:
			return 4
		ItemResource.ItemRarity.GODLY:
			return 1
		_:
			return 0


func get_random_item() -> ItemResource:
	var total_weight := 0
	for item in item_pool:
		total_weight += get_rarity_weight(item.item_rarity)

	var rand_value := randi_range(0, total_weight - 1)
	var curr_weight := 0
	for item in item_pool:
		curr_weight += get_rarity_weight(item.item_rarity)
		if rand_value <= curr_weight:
			return item

	return item_pool.pick_random() as ItemResource


func set_curr_phase(texture: Texture2D) -> void:
	phase_container.get_child(phase_container.get_child_count() - boxes_left).texture = texture


func set_curr_cash(new_value: int) -> void:
	total_earnings = new_value
	earnings_label.text = "Total Earnings:\n$" + str(total_earnings)


func _on_hand_extend() -> void:
	hand_tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	hand_tween.tween_property(hand, "position:y", HAND_EXTEND_Y, 0.5)


func _on_hand_retract() -> void:
	hand_tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	hand_tween.tween_property(hand, "position:y", HAND_RETRACT_Y, 0.5)
	hand_tween.tween_callback(func() -> void: hand.texture = hand_open_texture)


func _on_hand_grab() -> void:
	AudioManager.play_sound("bump")
	hand.texture = hand_closed_texture
	Events.cam_shake.emit(0.4)


func _on_box_cashed_out(amount: int) -> void:
	set_curr_cash(total_earnings + amount)
	set_curr_phase(phase_cashed_out_texture)


func _on_box_converted() -> void:
	item_info.hide()


func _on_box_opened(is_bomb: bool) -> void:
	if is_bomb: return
	item_info.show()


func _on_box_exploded() -> void:
	hearts_container.get_child(0).queue_free()
	set_curr_phase(phase_exploded_texture)
	lives_left -= 1
	if lives_left <= 0:
		Engine.time_scale = 0.0
		var death_screen := death_screen_scene.instantiate() as DeathScreen
		get_tree().current_scene.add_child(death_screen)
		death_screen.set_info(total_earnings, curr_day + 1)


func _on_flashbang(duration: float) -> void:
	flashbang.self_modulate.a = 1.0
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(flashbang, "self_modulate:a", 0.0, duration)


func _on_input_open() -> void:
	if timer.is_stopped(): return
	curr_box.toggle_open(true)
	timer.stop()
	timer_progress_bar.hide()


func _on_input_close() -> void:
	pass


func _on_input_shake() -> void:
	if timer.is_stopped(): return
	curr_box.inspect()


func _input(event: InputEvent) -> void:
	if not Events.DEBUG:
		return

	if event.is_action_pressed("click"):
		Events.input_shake.emit()
	if event.is_action_pressed("open"):
		Events.input_open.emit()
	if event.is_action_pressed("close"):
		Events.input_close.emit()


func _on_timer_timeout() -> void:
	set_curr_phase(phase_trashed_texture)
	AudioManager.play_sound("trash")
	Events.box_trashed.emit()
	Events.box_resolved.emit()
	print("time's up! automatically trashing")
	timer_progress_bar.hide()
