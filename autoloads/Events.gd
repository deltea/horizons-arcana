extends Node


signal input_shake()
signal input_open()
signal input_close()

signal box_opened(is_bomb: bool)
signal cam_shake(amount: float)
signal cam_toggle_intense(value: bool)
