class_name AlertLabel extends Label3D


func _ready() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_parallel()
	tween.tween_property(self, "position:y", 1.0, 2.0).as_relative()
	tween.tween_property(self, "modulate:a", 0.0, 2.0)
	tween.chain().tween_callback(queue_free)
