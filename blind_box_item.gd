class_name BlindBoxItem extends Sprite3D


func _ready() -> void:
	var wobble_tween := create_tween().set_loops()
	wobble_tween.tween_property(self, "rotation_degrees:z", 15.0, 0.0)
	wobble_tween.tween_interval(0.5)
	wobble_tween.tween_property(self, "rotation_degrees:z", -15.0, 0.0)
	wobble_tween.tween_interval(0.5)


func animate_in() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property(self, "position:y", 3.0, 0.5).as_relative()
	tween.tween_property(self, "scale", Vector3.ONE * 2.0, 0.5)
