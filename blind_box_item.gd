class_name BlindBoxItem extends Node3D


@onready var item_sprite: Sprite3D = $ItemSprite
@onready var star_sprite: Sprite3D = $StarSprite
@onready var money_sprite: Sprite3D = $MoneySprite

var is_thrown: bool = false
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
	if is_thrown:
		item_sprite.rotation_degrees.z += 800.0 * dt


func animate_in() -> void:
	star_sprite.scale = Vector3.ZERO

	var tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property(self, "position:y", 4.0, 1.0).as_relative()
	tween.tween_property(self, "scale", Vector3.ONE * 2.0, 1.0)
	tween.tween_property(star_sprite, "scale", Vector3.ONE * 1.0, 1.0)


func throw_in_bin(bin: Bin) -> void:
	wobble_tween.stop()
	is_thrown = true
	var tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN).set_parallel()
	# tween.tween_property(self, "global_position", bin.global_position + Vector3.UP * 3.0, 1.0)
	tween.tween_property(star_sprite, "scale", Vector3.ZERO, 0.5)
	tween.tween_property(item_sprite, "scale", Vector3.ZERO, 0.5).set_delay(0.25)
	tween.tween_property(money_sprite, "scale", Vector3.ONE, 0.5)
