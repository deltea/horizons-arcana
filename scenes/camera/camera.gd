class_name Camera extends Camera3D

@export var decay: float = 1.0
@export var max_roll: float = 0.1
@export var max_offset: float = 0.5

var trauma: float = 0.0
var trauma_power: int = 2

@onready var initial_transform: Transform3D = self.transform

func _ready() -> void:
	Events.cam_shake.connect(_on_cam_shake)


func _process(delta: float) -> void:
	if trauma > 0:
		trauma = max(trauma - decay * delta, 0.0)
		shake()
	else:
		self.transform = self.transform.interpolate_with(initial_transform, 10.0 * delta)


func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)


func shake() -> void:
	var amt := pow(trauma, trauma_power)

	rotation.x = initial_transform.basis.get_euler().x + max_roll * amt * randf_range(-1.0, 1.0)
	rotation.y = initial_transform.basis.get_euler().y + max_roll * amt * randf_range(-1.0, 1.0)
	rotation.z = initial_transform.basis.get_euler().z + max_roll * amt * randf_range(-1.0, 1.0)

	h_offset = max_offset * amt * randf_range(-1.0, 1.0)
	v_offset = max_offset * amt * randf_range(-1.0, 1.0)


func _on_cam_shake(amount: float) -> void:
	add_trauma(amount)
