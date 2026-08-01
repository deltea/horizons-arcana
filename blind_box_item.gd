class_name BlindBoxItem extends Node3D


@export var bomb_texture: Texture2D
@export var exploded_bomb_texture: Texture2D

@onready var item_sprite: Sprite3D = $ItemSprite
@onready var star_sprite: Sprite3D = $StarSprite
@onready var star_sprite_2: Sprite3D = $StarSprite2
@onready var money_sprite: Sprite3D = $MoneySprite

var is_opened: bool = false
var wobble_tween: Tween
var is_bomb: bool = false
var item_resource: ItemResource


func _ready() -> void:
	star_sprite.scale = Vector3.ZERO
	money_sprite.scale = Vector3.ZERO
	item_sprite.scale = Vector3.ZERO

	wobble_tween = create_tween().set_loops()
	wobble_tween.tween_property(item_sprite, "rotation_degrees:z", 10.0, 0.0)
	wobble_tween.tween_interval(0.5)
	wobble_tween.tween_property(item_sprite, "rotation_degrees:z", -10.0, 0.0)
	wobble_tween.tween_interval(0.5)


func _process(dt: float) -> void:
	star_sprite.rotation_degrees.z += 25.0 * dt
	star_sprite_2.rotation = star_sprite.rotation
	star_sprite_2.scale = star_sprite.scale
	if is_opened:
		item_sprite.rotation_degrees.z += 800.0 * dt


func animate_in() -> void:
	star_sprite.scale = Vector3.ZERO

	if is_bomb:
		wobble_tween.stop()

	var tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property(self, "position:y", 4.0, 1.0).as_relative()
	tween.tween_property(self, "scale", Vector3.ONE * 2.0, 1.0)
	tween.tween_property(item_sprite, "scale", Vector3.ONE * 1.0, 1.0)
	if not is_bomb:
		tween.tween_property(star_sprite, "scale", Vector3.ONE * 1.0, 1.0)

	tween.tween_interval(3.0)

	if is_bomb:
		await get_tree().create_timer(1.0).timeout
		item_sprite.texture = exploded_bomb_texture
		Events.flashbang.emit(2.0)
		Events.box_exploded.emit()
		await get_tree().create_timer(2.0).timeout
		Events.box_resolved.emit()
		return

	# turn into money
	tween.chain().tween_callback(func() -> void: Events.box_converted.emit())
	tween.chain().tween_callback(func() -> void:
		wobble_tween.stop()
		is_opened = true
	)
	tween.tween_property(star_sprite, "scale", Vector3.ZERO, 0.5)
	tween.tween_property(item_sprite, "scale", Vector3.ZERO, 0.5)
	tween.tween_property(money_sprite, "scale", Vector3.ONE, 0.5)
	tween.chain().tween_callback(func() -> void: Events.hand_extend.emit())
	tween.chain().tween_interval(0.5)
	tween.chain().tween_callback(func() -> void: Events.hand_grab.emit())
	tween.chain().tween_interval(0.5)
	tween.chain().tween_callback(func() -> void: Events.hand_retract.emit())
	tween.tween_property(self, "global_position:y", -2.0, 0.5).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)
	tween.chain().tween_callback(func() -> void: Events.box_cashed_out.emit(item_resource.item_price))
	tween.chain().tween_callback(func() -> void: Events.box_resolved.emit())


func set_bomb() -> void:
	is_bomb = true
	item_sprite.texture = bomb_texture
