extends CharacterBody2D

# Чтобы перевести скорость из сабпикселей/кадр в пиксели/секунда умножь числа на 15/4
@export var max_walk_speed: float = 52.5
@export var max_run_speed: float = 1200
@export var max_sprint_speed: float = 112.5
@export var acceleration: float = 162.5
@export var deceleration: float = 205.5
@export var slidding_decel: float = 50.5
@export var jump_strength: float = 56.25

# Инициализация дополнительных нод
@onready var sprite = $Sprite

func _physics_process(delta: float) -> void:
	# Декопозинг переменных состояния игрока для более читабельного кода
	var is_slid: bool = Input.is_action_pressed("Down")
	var is_run: bool = Input.is_action_pressed("Run")
	velocity.y += get_gravity().y * delta   

	var input_vector = Vector2.ZERO

	if not is_slid:
		if Input.is_action_pressed("Left"):
			input_vector.x -= 1
		elif Input.is_action_pressed("Right"):
			input_vector.x += 1
		elif Input.is_action_pressed("Up") and is_on_floor() and velocity.x == 0:
			sprite.animation = "look_up"

	input_vector = input_vector.normalized()

	var real_max_speed: float
	if is_run:
		real_max_speed = max_run_speed
	else:
		real_max_speed = max_walk_speed
	
	if is_on_floor():
		velocity.x += input_vector.x * acceleration * delta
		
		# Ограничение скорости
		if abs(velocity.x) > real_max_speed:
			if velocity.x > 0:
				velocity.x -= deceleration * delta
			else:
				velocity.x += deceleration * delta

			velocity.x = clamp(velocity.x, -real_max_speed, real_max_speed)
		else:
			velocity.x = clamp(velocity.x, -real_max_speed, real_max_speed)

		# Обработка прыжка
		if Input.is_action_just_pressed("Jump"):
			velocity.y -= ((jump_strength * 175) * delta) * clamp(abs(velocity.x) / 100, 1, 1.5)

	if input_vector.x == 0 and is_on_floor():
		# Проверка с каким замедлением замедлять игрока
		var real_decel: float
		if is_slid:
			real_decel = slidding_decel
		else:
			real_decel = deceleration

		if velocity.x > 0:
			velocity.x -= real_decel * delta
			if velocity.x < 0:
				velocity.x = 0
		elif velocity.x < 0:
			velocity.x += real_decel * delta
			if velocity.x > 0:
				velocity.x = 0
	if Input.is_action_just_released("Jump") && velocity.y < -10:
		velocity.y = -25

	# Логика анимаций
	if is_on_floor():
		if is_slid:
			sprite.animation = "duck"
		else:
			if velocity.x != 0:
				sprite.flip_h = velocity.x < 0
				
				if (Input.is_action_pressed("Right") and velocity.x < 0) or (Input.is_action_pressed("Left") and velocity.x > 0):
					sprite.animation = "skid"
				else:
					if is_run:
						sprite.animation = "run"
					else:
						sprite.animation = "walk"
			else:
				if not(Input.is_action_pressed("Up")):
					sprite.animation = "idle"
	else:
		if velocity.y < 1:
			sprite.animation = "jump"
		else:
			sprite.animation = "fall"

	# Движение
	move_and_slide()
