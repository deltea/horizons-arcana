class_name BlindBoxItem extends Node3D


@onready var item_sprite: Sprite3D = $ItemSprite
@onready var star_sprite: Sprite3D = $StarSprite
@onready var star_sprite_2: Sprite3D = $StarSprite2
@onready var money_sprite: Sprite3D = $MoneySprite

var is_opened: bool = false
var wobble_tween: Tween


func _ready() -> void:
	star_sprite.scale = Vector3.ZERO
	money_sprite.scale = Vector3.ZERO

	wobble_tween = create_tween().set_loops()
	wobble_tween.tween_property(item_sprite, "rotation_degrees:z", 15.0, 0.0)
	wobble_tween.tween_interval(0.5)
	wobble_tween.tween_property(item_sprite, "rotation_degrees:z", -15.0, 0.0)
	wobble_tween.tween_interval(0.5)


func _process(dt: float) -> void:
	star_sprite.rotation_degrees.z += 25.0 * dt
	star_sprite_2.rotation = star_sprite.rotation
	star_sprite_2.scale = star_sprite.scale
	if is_opened:
		item_sprite.rotation_degrees.z += 800.0 * dt


func animate_in() -> void:
	star_sprite.scale = Vector3.ZERO
	item_sprite.scale = Vector3.ZERO

	var tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property(self, "position:y", 4.0, 1.0).as_relative()
	tween.tween_property(self, "scale", Vector3.ONE * 2.0, 1.0)
	tween.tween_property(item_sprite, "scale", Vector3.ONE * 1.0, 1.0)
	tween.tween_property(star_sprite, "scale", Vector3.ONE * 1.0, 1.0)
	tween.tween_interval(5.0)
	# turn into money
	tween.chain().tween_callback(func() -> void:
		wobble_tween.stop()
		is_opened = true
	)
	tween.tween_property(star_sprite, "scale", Vector3.ZERO, 0.5)
	tween.tween_property(item_sprite, "scale", Vector3.ZERO, 0.5)
	tween.tween_property(money_sprite, "scale", Vector3.ONE, 0.5)
