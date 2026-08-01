class_name BlindBox extends Node3D


const LID_CLOSED_ROT = 90.0
const LID_OPEN_ROT = -75.0
const BOMB_CHANCE = 0.4

@onready var lid: MeshInstance3D = $box/Lid
@onready var item: BlindBoxItem = $BlindBoxItem

var has_bomb: bool = false
var open_tween: Tween
var item_resource: ItemResource
var vibrate_tween: Tween


func _ready() -> void:
	Events.box_resolved.connect(_on_box_resolved)
	Events.input_shake.connect(_on_input_shake)

	has_bomb = randf() < BOMB_CHANCE
	item.item_sprite.texture = item_resource.item_texture
	item.item_resource = item_resource


func _on_input_shake() -> void:
	var rand = randf() > (0.3 if has_bomb else 0.7)
	AudioManager.play_sound("tick" if rand else "squeak", 1.4)
	# print("shake")
	scale = Vector3.ONE * 1.5
	if vibrate_tween: vibrate_tween.kill()
	vibrate_tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_parallel()
	vibrate_tween.tween_property(self, "scale", Vector3.ONE, 0.5)


func toggle_open(is_open: bool) -> void:
	open_tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	open_tween.tween_property(lid, "rotation_degrees:z", LID_OPEN_ROT if is_open else LID_CLOSED_ROT, 0.5)
	AudioManager.play_sound("open")

	if is_open:
		Events.cam_toggle_intense.emit(true)
		AudioManager.play_sound("intense")
		await get_tree().create_timer(1.5).timeout
		Events.cam_toggle_intense.emit(false)
		Events.box_opened.emit(has_bomb)
		if has_bomb:
			item.set_bomb()
		item.animate_in()

		await Events.input_close

		open_tween.stop()
		var tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tween.tween_property(lid, "rotation_degrees:z", LID_CLOSED_ROT, 0.5)


func animate_in() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property(self, "position:y", 3.3, 1.5)
	tween.tween_callback(bump).set_delay(0.6)
	tween.tween_callback(bump).set_delay(1.2)
	tween.tween_callback(bump).set_delay(1.4)
	await tween.finished


func bump() -> void:
	Events.cam_shake.emit(0.3)
	AudioManager.play_sound("bump")


func inspect() -> void:
	print("ooh now you know more info")


func _on_box_resolved() -> void:
	# queue_free()
	var tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector3.ZERO, 0.2)
	tween.tween_callback(queue_free)
