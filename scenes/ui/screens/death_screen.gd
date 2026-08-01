class_name DeathScreen extends CanvasLayer


@onready var labubu: TextureRect = $Labubu

func _ready() -> void:
	labubu.scale = Vector2.ZERO
	labubu.self_modulate.a = 0.0

	var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_parallel()
	tween.tween_property(labubu, "scale", Vector2.ONE, 10.0)
	tween.tween_property(labubu, "self_modulate:a", 1.0, 10.0)
