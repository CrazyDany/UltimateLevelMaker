extends CharacterBody2D

#Чтобы перевести скорость из сабпикселей/кадр в пиксели/секунда умножь числа на 15/4
@export var max_walk_speed: float = 85
@export var walk_accel: float = 225.5
@export var walk_deccel: float = 250.5

@export var max_run_speed: float = 200
@export var run_accel: float = 125.5
@export var run_deccel: float = 265.5

@export var max_duck_speed: float = 90
@export var duck_accel: float = 0
@export var duck_dessel: float = 65

@export var jump_strenth: float = 275
#Иницилизация дочерних нод
@onready var sprite = $Sprite
@onready var collision = $CollisionShape2D
@onready var anim:AnimationPlayer = sprite.get_child(0)

#func _ready():
	#print(anim)

var is_running = false

func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = Vector2.ZERO
	var is_running:float = Input.is_action_pressed("Run")
	var is_moving = Input.is_action_pressed("Left") or Input.is_action_pressed("Right")
	var in_air = not(is_on_floor())
	var is_ducking:bool = Input.is_action_pressed("Down")
	var is_looking_up:bool = Input.is_action_pressed("Up")

	if Input.is_action_pressed("Right"):
		input_vector.x += 1
	if Input.is_action_pressed("Left"):
		input_vector.x -= 1

	if not is_ducking:
		if input_vector.x != 0:
			if is_running:
				accelerate(input_vector.x * run_accel, max_run_speed, delta)
			else:
				accelerate(input_vector.x * walk_accel, max_walk_speed, delta)
		else:
			if is_running:
				deccelerate(run_deccel, 0, delta)
			else:
				deccelerate(walk_deccel, 0, delta)
		if not is_running:
			if is_looking_up:
				pass
	else:
		deccelerate(duck_dessel, 0, delta)
			
#	DO YOU BELIVE IN GRAVITY
	if not(is_on_floor()):
		velocity.y += get_gravity().y
		
#	Прыжок
	if not is_ducking:
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = -jump_strenth

	if (abs(velocity).x > 0) and (is_moving):
		anim.speed_scale = (abs(velocity.x) * (max_walk_speed/16))/250
	else:
		anim.speed_scale = 1
	move_and_slide()
	
#	Анимация
	if in_air:
		if velocity.y > 0:
			if abs(velocity.x) >= 190:
				handle_set_animation("RunJump")
			else:
				handle_set_animation("Fall")
		elif not(anim.current_animation == "Fall"):
			if abs(velocity.x) >= 190:
				handle_set_animation("RunJump")
			else:
				handle_set_animation("Jump")
	else:
		if not is_ducking:
			if is_moving:
				if (Input.is_action_pressed("Right") and velocity.x < 0) or (Input.is_action_pressed("Left") and velocity.x > 0):
					handle_set_animation("Skid")
				else:
					if abs(velocity.x) >= 190:
						handle_set_animation("Run")
					else:
						handle_set_animation("Walk")
			else:
				if not is_looking_up:
					handle_set_animation("Idle")
				else:
					handle_set_animation("Look_Up")
		else:
			handle_set_animation("Duck")

			
#	ЙОУ КРУТЫЕ ПОВОРОТЫ СПРАЙТА
	if velocity.x < 0 and not sprite.flip_h:
		sprite.flip_h = true
	elif velocity.x > 0 and sprite.flip_h:
		sprite.flip_h = false
		
#	Изменение колизии при приседе
	if is_ducking:
		if not(collision.scale.y == 0.5):
			collision.scale.y = 0.5
			collision.position.y += 3
	else:
		if not(collision.scale.y == 1):
			collision.scale.y = 1
			collision.position.y -= 3
		
func accelerate(accel: float, max_speed: float, delta: float):
	velocity.x += accel * delta

	if abs(velocity.x) >= max_speed:
		deccelerate(run_deccel if is_running else walk_deccel, max_speed, delta)

func deccelerate(deccel: float, min_speed: float, delta: float):
	if velocity.x > min_speed:
		velocity.x -= deccel * delta
		if velocity.x < min_speed:
			velocity.x = min_speed
	elif velocity.x < min_speed:
		velocity.x += deccel * delta
		if velocity.x > min_speed:
			velocity.x = min_speed
			
func handle_set_animation(name:StringName):
	if anim.current_animation == name:
		return
	else:
		anim.play(name)
