class_name BlindBox extends Node3D


const LID_CLOSED_ROT = 180.0
const LID_OPEN_ROT = -75.0
const BOMB_CHANCE = 0.5

@onready var lid: MeshInstance3D = $box/Lid
@onready var item: BlindBoxItem = $BlindBoxItem

var has_bomb: bool = false
var open_tween: Tween


func _ready() -> void:
	Events.box_resolved.connect(_on_box_resolved)

	has_bomb = randf() < BOMB_CHANCE


func toggle_open(is_open: bool) -> void:
	open_tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	open_tween.tween_property(lid, "rotation_degrees:z", LID_OPEN_ROT if is_open else LID_CLOSED_ROT, 0.5)

	if is_open:
		Events.cam_toggle_intense.emit(true)
		await get_tree().create_timer(1.5).timeout
		Events.cam_toggle_intense.emit(false)
		Events.box_opened.emit(has_bomb)
		if has_bomb:
			item.set_bomb()
		item.animate_in()


func animate_in() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property(self, "position:y", 3.3, 1.5)
	tween.tween_callback(func() -> void: Events.cam_shake.emit(0.3)).set_delay(0.6)
	tween.tween_callback(func() -> void: Events.cam_shake.emit(0.3)).set_delay(1.1)
	tween.tween_callback(func() -> void: Events.cam_shake.emit(0.3)).set_delay(1.4)
	await tween.finished


func set_info(item_texture: Texture2D) -> void:
	item.item_sprite.texture = item_texture


func _on_box_resolved() -> void:
	# queue_free()
	var tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector3.ZERO, 0.2)
	tween.tween_callback(queue_free)
