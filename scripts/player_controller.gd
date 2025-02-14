extends CharacterBody2D

class_name Player

@export var walk_max_speed: float = 100.5
@export var walk_accel: float = 120
@export var walk_deccel: float = 225

@export var max_jump_height: float = 50
@export var min_jump_height: float = 165
@export var max_fall_speed: float = 7761

const buffer_time: float = 0.15

@export var run_max_speed: float = 175
@export var run_accel: float = 300
@export var run_deccel: float = 900

@export var srun_max_speed: float = 225
@export var srun_accel: float = 100
@export var srun_deccel: float = 725

@export var smeter_add: float = 0.25
@export var smeter_sub: float = 0.6

@export var duck_max_speed: float = 100
@export var duck_deccel: float = 125

var cur_slope: String = "FLAT"
@export var slopes_moddifs: Dictionary = {
	"FLAT": [1, 1, 1, false],
	"GRADUAL": [0.80, 0.85, 0.85, false],
	"NORMAL": [0.70, 0.75, 0.75, false],
	"STEEP": [0.55, 0.60, 0.60, true],
	"VERY STEEP": [0.175, 0.6, 0.35, true]
}

var s_meter: float = 0
var coins: float = 0
var score: float = 0

var leftKey: bool = false
var rightKey: bool = false
var upKey: bool = false
var downKey: bool = false
var jumpKey: bool = false
var spinjumpKey: bool = false
var jumpKey_pressed: bool = false
var spinjumpKey_pressed: bool = false
var runKey: bool = false

var is_sliding: bool = false
var in_spinjump: bool = false
var moveDirectionX = 0

var is_big: bool = false

@export var sprite: AnimatedSprite2D
@onready var anim: AnimationPlayer = sprite.get_child(0)
@export var jump_buffer_timer: Timer
@export var audio_player: AudioPlayer

func _ready() -> void:
	assert(sprite and sprite.get_parent() is Player, "У игрока на сцене {path} не определен спрайт".format({"path": self.get_parent().name}))
	assert(anim and anim.get_parent() == sprite, "У игрока на сцене не определен проигрователь анимаций".format({"path": self.get_parent().name}))
	assert(jump_buffer_timer, "У игрока не определен таймер буфферизации прыжка".format({"path": self.get_parent().name}))
	on_ready()

func on_ready() -> void:
	floor_snap_length = 20
	
func _physics_process(delta: float) -> void:
	get_input()

	gravity(delta)
	horizontal_move(delta)
	handle_slopes()
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
	spinjumpKey_pressed = Input.is_action_just_pressed("SpinJump")
	jumpKey = Input.is_action_pressed("Jump")
	spinjumpKey = Input.is_action_pressed("SpinJump")
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
		if not downKey and not(slopes_moddifs.get(cur_slope)[3] and not (rightKey or leftKey)):
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
			if not is_sliding and not(slopes_moddifs.get(cur_slope)[3] and not (rightKey or leftKey)):
				set_animation("Duck")
			else:
				set_animation("Slide")
	else:
		if is_on_floor():
			if not downKey:
				if upKey:
					set_animation("Look_Up")
				else:
					set_animation("Idle")
			else:
				if is_sliding:
					set_animation("Slide")
				else:
					set_animation("Duck")
		else:
			if in_spinjump:
				set_animation("SpinJump")
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
				
	if not in_spinjump:
		if (abs(velocity).x > 0):
			anim.speed_scale = (abs(velocity.x) * (walk_max_speed / 16)) / 250
		else:
			anim.speed_scale = 1
	else:
		anim.speed_scale = 1

func gravity(delta: float):
	if (!is_on_floor()):
		velocity.y += get_gravity().y * delta
	if velocity.y > max_fall_speed:
		velocity.y = max_fall_speed

func horizontal_move(delta: float):
	if not downKey:
		var moveDirectionX = Input.get_axis("Left", "Right")
		var target_speed = 0.0
		var acceleration = 0.0
		var deceleration = 0.0

		if runKey:
			if s_meter == 100:
				target_speed = moveDirectionX * srun_max_speed
				acceleration = srun_accel
				deceleration = srun_deccel
			else:
				target_speed = moveDirectionX * run_max_speed
				acceleration = run_accel
				deceleration = run_deccel
		else:
			target_speed = moveDirectionX * walk_max_speed
			acceleration = walk_accel
			deceleration = walk_deccel
			
		var normal: Vector2 = get_floor_normal()

		if cur_slope != "FLAT":
			var is_climbing = get_real_velocity().y < 0
			var is_descending = get_real_velocity().y  > 0

			if is_climbing:
				target_speed *= slopes_moddifs.get(cur_slope)[0]
				acceleration *= slopes_moddifs.get(cur_slope)[1]
				deceleration *= slopes_moddifs.get(cur_slope)[2]
			elif is_descending:
				target_speed /= slopes_moddifs.get(cur_slope)[0]
				acceleration /= slopes_moddifs.get(cur_slope)[1]
				deceleration /= slopes_moddifs.get(cur_slope)[2]

		if moveDirectionX != 0 and sign(moveDirectionX) != sign(velocity.x):
			velocity.x = move_toward(velocity.x, target_speed, (acceleration + deceleration) * delta)
		else:
			if moveDirectionX != 0:
				velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
			else:
				velocity.x = move_toward(velocity.x, target_speed, deceleration * delta)

		# Автоходьба по склонам
		if slopes_moddifs.get(cur_slope)[3] and not (rightKey or leftKey):
			var slope_speed = normal.normalized().x * walk_max_speed * (1/slopes_moddifs.get(cur_slope)[0])
			velocity.x = lerp(self.velocity.x, slope_speed, 0.2)
	else:
		if cur_slope == "FLAT":
			velocity.x = move_toward(velocity.x, 0, duck_deccel * delta)
		else:
			var normal: Vector2 = get_floor_normal()
			velocity.x = lerp(self.velocity.x, normal.normalized().x * duck_max_speed * 4, 0.15)

func jump():
	if (jumpKey_pressed and not spinjumpKey_pressed) and is_on_floor() and (not downKey):
		do_jump(false)
		in_spinjump = false

	if Input.is_action_just_released("Jump") and not in_spinjump:
		if velocity.y < -min_jump_height:
			velocity.y = -min_jump_height

	if (spinjumpKey_pressed and not jumpKey_pressed) and is_on_floor() and (not downKey):
		do_jump(true)
		set_deferred("in_spinjump", true)

	if Input.is_action_just_released("SpinJump") and in_spinjump:
		if velocity.y < -min_jump_height:
			velocity.y = -min_jump_height
		
	if is_on_floor():
		in_spinjump = false

func using_s_meter():
	if abs(velocity.x) > walk_max_speed:
		s_meter = clamp(s_meter + smeter_add + s_meter / 500, 0, 100)
	else:
		s_meter = clamp(s_meter - smeter_sub - s_meter / 400, 0, 100)
		
func buffer_jump():
	if jumpKey_pressed and not is_on_floor():
		jump_buffer_timer.start(buffer_time)
	if jump_buffer_timer.time_left > 0 and is_on_floor():
		do_jump(false)
		audio_player.play_sound("Jump")

func handle_slopes():
	var angle: float = get_floor_angle()
	if not is_on_floor():
		cur_slope = "FLAT"
	else:
		if angle > 0 and angle < 0.35:
			cur_slope = "GRADUAL"
		elif angle > 0.35 and angle < 0.6:
			cur_slope = "NORMAL"
		elif angle > 0.6 and angle < 0.8:
			cur_slope = "STEEP"
		elif angle > 0.8:
			cur_slope = "VERY STEEP"
		else:
			cur_slope = "FLAT"
	is_sliding = (cur_slope != "FLAT" and downKey)

# Ручная обработка столкновений и подбора предметов и блоков
func _on_detect_zone_body_entered(body: Node2D) -> void:
	if body is Block:
		body._on_player_collide(self)

func _on_detect_zone_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	if body is Item:
		if body.matchable:
			body.matchable = false
			body._on_matched(self)
			
#МЕТОДИКИИИ
func hurt(actor:Node) -> void:
	if is_big:
		is_big = false
		return
	else:
		velocity.y -= 300
	
#И деланье прыжка и его звук
func do_jump(spin_jump:bool) -> void:
	velocity.y = -sqrt(max_jump_height * 2 * get_gravity().y) - abs(velocity.x / 3)
	if spin_jump:
		audio_player.play_sound("SpinJump")
	else:
		audio_player.play_sound("Jump")
