extends CharacterBody2D

#Чтобы перевести скорость из сабпикселей/кадр в пиксели/секунда умножь числа на 15/4
@export var max_walk_speed:float = 52.5
@export var max_run_speed:float = 90
@export var max_sprint_speed:float = 112.5
@export var acceleration:float = 5
@export var deceleration:float = 7.5

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		pass

	if Input.is_action_just_pressed("ui_left") and is_on_floor():
		pass
