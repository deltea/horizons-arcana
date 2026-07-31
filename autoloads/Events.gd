extends Node


const DEBUG = true


signal input_shake()
signal input_open()
signal input_close()

signal box_opened(is_bomb: bool)
signal box_resolved()
signal box_trashed()

signal cam_shake(amount: float)
signal cam_toggle_intense(value: bool)

signal hand_extend()
signal hand_retract()
signal hand_grab()
