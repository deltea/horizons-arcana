class_name Camera extends Camera3D

const zoom_in_speed: float = 20.0
const zoom_out_duration: float = 0.5

@export var decay: float = 1.0
@export var max_roll: float = 0.1
@export var max_offset: float = 0.5

var trauma: float = 0.0
var trauma_power: int = 2
var is_intense: bool = false

@onready var initial_transform: Transform3D = self.transform

func _ready() -> void:
	Events.cam_shake.connect(_on_cam_shake)
	Events.cam_toggle_intense.connect(_on_cam_toggle_intense)

func _process(delta: float) -> void:
	if trauma > 0:
		trauma = max(trauma - decay * delta, 0.0)
		shake()
	else:
		self.transform = self.transform.interpolate_with(initial_transform, 10.0 * delta)

	if is_intense:
		# increase trauma to shake more and more
		trauma = trauma + 1.2 * delta
		shake()
		fov -= zoom_in_speed * delta


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


func _on_cam_toggle_intense(value: bool) -> void:
	trauma = 0.0
	is_intense = value

	if not value:
		var zoom_tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		zoom_tween.tween_property(self, "fov", 70.0, zoom_out_duration)
