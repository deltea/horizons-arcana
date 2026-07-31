class_name DayEndScreen extends CanvasLayer

@onready var background: TextureRect = $Control/Background


func _process(dt: float) -> void:
	background.position.x = wrapf(Clock.time * 40.0, -64, 0)


func animate_in() -> void:
	pass
