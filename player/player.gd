extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D


var bullet = preload("res://player/bullet.tscn")
var player_death_effect = preload("res://player/player_death_effect/playerdeatheffect.tscn")

@onready var hitanimationplayer: AnimationPlayer = $hitanimationplayer


@onready var muzzle: Marker2D = $muzzle

const GRAVITY = 1000
@export var speed = 1000
@export var jump = -300

@export var max_horizontal_speed = 300
@export var slow_down_speed = 1700
@export var jump_horizontal_speed = 1000
@export var max_jump_horizontal_speed = 300

@export var max_jumps = 3


enum State { Idle, Run, Jump, Shoot, Shoot_idle }

var jump_count = 0
var current_state
var muzzle_position

func _ready():
	current_state = State.Idle
	muzzle_position = muzzle.position
	
func _physics_process(delta):
	
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	player_shooting(delta)
	
	move_and_slide()
	player_muzzle_position()
	player_animations()
	
func player_falling(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func player_idle(delta):
	if is_on_floor():
		current_state = State.Idle
		
func player_run(delta):
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		current_state = State.Run
		if direction > 0:
			animated_sprite_2d.flip_h = false
		else:
			animated_sprite_2d.flip_h = true
			
	
	if direction:
		velocity.x += direction * speed * delta
		velocity.x = clamp(velocity.x, -max_jump_horizontal_speed, max_jump_horizontal_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, slow_down_speed * delta)

func player_jump(delta):
	if is_on_floor() and jump_count > 0:
		jump_count = 0
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		velocity.y = jump
		current_state = State.Jump
		jump_count += 1

	if not is_on_floor() and current_state == State.Jump:
		var direction = Input.get_axis("move_left", "move_right")
		velocity.x += direction * jump_horizontal_speed * delta
		velocity.x = clamp(velocity.x, -max_horizontal_speed, max_horizontal_speed)
	
func player_shooting(delta):
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0 and Input.is_action_just_pressed("shoot"):
		var bullet_instance = bullet.instantiate() as Node2D
		bullet_instance.direction = direction
		bullet_instance.global_position = muzzle.global_position
		get_parent().add_child(bullet_instance)
		current_state = State.Shoot
	if direction == 0 and Input.is_action_just_pressed("shoot"):
		var bullet_instance = bullet.instantiate() as Node2D
		if animated_sprite_2d.flip_h == false:
			bullet_instance.direction = direction + 1
			bullet_instance.global_position = muzzle.global_position
			get_parent().add_child(bullet_instance)
			current_state = State.Shoot_idle
		else:
			bullet_instance.direction = direction - 1
			bullet_instance.global_position = muzzle.global_position
			get_parent().add_child(bullet_instance)
			current_state = State.Shoot_idle

func player_muzzle_position():
	var direction = Input.get_axis("move_left", "move_right")
	if direction > 0:
		muzzle.position.x = muzzle_position.x
	elif direction < 0:
		muzzle.position.x = -muzzle_position.x

func player_animations():
	if current_state == State.Idle:
		animated_sprite_2d.play("idle")
	elif current_state == State.Run and is_on_floor() and animated_sprite_2d.animation != "run_shoot":
		animated_sprite_2d.play("run")
	elif current_state == State.Jump:
		animated_sprite_2d.play("jump")
	elif current_state == State.Shoot:
		animated_sprite_2d.play("run_shoot")
	elif current_state == State.Shoot_idle:
		animated_sprite_2d.play("shoot")


func player_death():
	var player_death_effect_instance = player_death_effect.instantiate()
	player_death_effect_instance.global_position = global_position
	get_parent().add_child(player_death_effect_instance)
	queue_free()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		print("Enemey enterned ", body.damage_amount)
		hitanimationplayer.play("hit")
		HealthManager.decrease_health(body.damage_amount)
	if HealthManager.current_health == 0:
		player_death()
