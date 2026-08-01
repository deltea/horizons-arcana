class_name DeathScreen extends CanvasLayer


@onready var labubu: TextureRect = $Labubu
@onready var flashbang: ColorRect = $Flashbang
@onready var revenue_label: Label = $RevenueLabel
@onready var survival_label: Label = $SurvivalLabel


func _ready() -> void:
	Events.input_shake.connect(_on_input_shake)

	AudioManager.play_sound("flashbang")

	labubu.scale = Vector2.ZERO
	labubu.self_modulate.a = 0.0
	flashbang.self_modulate.a = 1.0

	var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_parallel().set_ignore_time_scale()
	tween.tween_property(flashbang, "self_modulate:a", 0.0, 4.0)
	tween.tween_property(labubu, "scale", Vector2.ONE, 10.0)
	tween.tween_property(labubu, "self_modulate:a", 1.0, 10.0)


func set_info(total_revenue: int, days_survived: int) -> void:
	revenue_label.text = "total revenue:\n$" + str(total_revenue)
	survival_label.text = "days survived:\n" + str(days_survived)


func _on_input_shake() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
