class_name DeathScreen extends CanvasLayer


@onready var labubu: TextureRect = $Labubu
@onready var flashbang: ColorRect = $Flashbang


func _ready() -> void:
	labubu.scale = Vector2.ZERO
	labubu.self_modulate.a = 0.0
	flashbang.self_modulate.a = 1.0

	var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_parallel().set_ignore_time_scale()
	tween.tween_property(labubu, "scale", Vector2.ONE, 10.0)
	tween.tween_property(labubu, "self_modulate:a", 1.0, 10.0)
	tween.tween_property(flashbang, "self_modulate:a", 0.0, 2.0)
