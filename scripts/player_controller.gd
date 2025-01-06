extends CharacterBody2D

# ЧТОБЫ КОНВЕРТИРОВАТЬ СКОРОСТЬ ИЗ SMW В ТУ КОТОРУЮ ИСПОЛЬЗУЕТ ДВИЖОК УМНОЖЬТЕ ЕЕ НА 3.75 (Но для ускорений дополнительно поделить на 2.5)
@export var walk_max_speed: float = 100.5
@export var walk_accel: float = 120
@export var walk_deccel: float = 150

@export var max_jump_height: float = 45
@export var min_jump_height: float = 30

#Перменные буфферизации прыжкка
const buffer_time: float = 0.15

@export var run_max_speed: float = 220
@export var run_accel: float = 175
@export var run_deccel: float = 300

@export var srun_max_speed: float = 250
@export var srun_accel: float = 225
@export var srun_deccel: float = 400

@export var smeter_add: float = 0.5
@export var smeter_sub: float = 0.5

@export var duck_max_speed: float = 0
@export var duck_deccel: float = 45

var s_meter: float = 0

var leftKey: bool = false
var rightKey: bool = false
var upKey: bool = false
var downKey: bool = false
var jumpKey: bool = false
var jumpKey_pressed: bool = false
var runKey: bool = false

var moveDirectionX = 0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision = $CollisionShape2D
@onready var anim: AnimationPlayer = sprite.get_child(0)
@onready var jump_buffer_timer: Timer = $JumpBuffer

func _physics_process(delta: float) -> void:
	get_input()

	gravity(delta)
	horizontal_move(delta)
	using_s_meter()
	buffer_jump()
	jump()

	handle_animator()

	move_and_slide()

func get_input():
	leftKey = Input.is_action_pressed("Left")
	rightKey = Input.is_action_pressed("Right")
	upKey = Input.is_action_pressed("Up")
	downKey = Input.is_action_pressed("Down")
	jumpKey_pressed = Input.is_action_just_pressed("Jump")
	jumpKey = Input.is_action_pressed("Jump")
	runKey = Input.is_action_pressed("Run")

func set_animation(name: StringName):
	if anim.current_animation == name:
		return
	else:
		anim.play(name)

func handle_animator():
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

	if !(velocity.x == 0) and is_on_floor():
		if not downKey:
			if rightKey:
				if velocity.x > 0:
					if s_meter == 100:
						set_animation("Run")
					else:
						set_animation("Walk")
				else:
					set_animation("Skid")
			elif leftKey:
				if velocity.x < 0:
					if s_meter == 100:
						set_animation("Run")
					else:
						set_animation("Walk")
				else:
					set_animation("Skid")
		else:
			set_animation("Duck")
	else:
		if is_on_floor():
			if not downKey:
				if upKey:
					set_animation("Look_Up")
				else:
					set_animation("Idle")
			else:
				set_animation("Duck")
		else:
			if velocity.y < 0:
				if s_meter == 100:
					set_animation("RunJump")
				else:
					set_animation("Jump")
			else:
				if s_meter == 100:
					set_animation("RunJump")
				else:
					set_animation("Fall")
				
	if (abs(velocity).x > 0):
		anim.speed_scale = (abs(velocity.x) * (walk_max_speed / 16)) / 250
	else:
		anim.speed_scale = 1

func gravity(delta: float):
	if (!is_on_floor()):
		velocity.y += get_gravity().y * delta

func horizontal_move(delta: float):
	if not downKey:
		moveDirectionX = Input.get_axis("Left", "Right")
		if runKey:
			if moveDirectionX != 0:
				velocity.x = move_toward(velocity.x, moveDirectionX * run_max_speed, run_accel * delta)
				if s_meter == 100:
					velocity.x = move_toward(velocity.x, moveDirectionX * srun_max_speed, srun_accel * delta)
			else:
				velocity.x = move_toward(velocity.x, moveDirectionX * run_max_speed, run_deccel * delta)
				if s_meter == 100:
					velocity.x = move_toward(velocity.x, moveDirectionX * srun_max_speed, srun_deccel * delta)
		else:
			if moveDirectionX != 0:
				velocity.x = move_toward(velocity.x, moveDirectionX * walk_max_speed, walk_accel * delta)
			else:
				velocity.x = move_toward(velocity.x, moveDirectionX * walk_max_speed, walk_deccel * delta)
	else:
		velocity.x = move_toward(velocity.x, moveDirectionX * duck_max_speed, duck_deccel * delta)

func jump():
	if (jumpKey_pressed) and is_on_floor() and (not downKey):
		velocity.y = -sqrt(max_jump_height * 2 * get_gravity().y) - abs(velocity.x / 3)
	if Input.is_action_just_released("Jump"):
		if velocity.y < -min_jump_height:
			velocity.y = -min_jump_height
	if Input.is_action_just_released("Jump"):
			if velocity.y < -min_jump_height:
				velocity.y = -min_jump_height

func using_s_meter():
	if abs(velocity.x) > walk_max_speed:
		s_meter = clamp(s_meter + smeter_add + s_meter / 500, 0, 100)
	else:
		s_meter = clamp(s_meter - smeter_sub - s_meter / 400, 0, 100)
		
func buffer_jump():
	if jumpKey_pressed and not is_on_floor():
		jump_buffer_timer.start(buffer_time)
	if jump_buffer_timer.time_left > 0 and is_on_floor():
		velocity.y = -sqrt(max_jump_height * 2 * get_gravity().y) - abs(velocity.x / 3)
		
