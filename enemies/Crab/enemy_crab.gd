extends CharacterBody2D

var enemy_death_effect = preload("res://enemies/enemy_death_effect.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var timer = $Timer

@export var gravity = 1000
@export var speed = 1500
@export var patrol_points : Node
@export var wait_time = 3
@export var health_amount = 5
@export var damage_amount = 1


enum State { Idle, Walk }
var current_state : State
var direction = Vector2.LEFT
var number_of_points : int
var point_positions : Array[Vector2]
var current_point : Vector2
var current_point_position : int
var can_walk

func _ready():
	if patrol_points != null:
		number_of_points = patrol_points.get_children().size()
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
		current_point = point_positions[current_point_position]
	current_state = State.Idle
	
	timer.wait_time = wait_time
	
func _physics_process(delta):
	enemy_gravity(delta)
	enemy_idle(delta)
	enemy_walk(delta)
	enemy_animations()
	move_and_slide()


func enemy_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
func enemy_idle(delta):
	if !can_walk:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		current_state = State.Idle

func enemy_walk(delta):
	if !can_walk:
		return
	if abs(position.x -current_point.x) > 0.5:
		velocity.x = direction.x * speed * delta
		current_state = State.Walk
	else:
		current_point_position += 1
			
		if current_point_position >= number_of_points:
			current_point_position = 0
		
		current_point = point_positions[current_point_position]
		
		if current_point.x > position.x:
			direction = Vector2.RIGHT
			animated_sprite_2d.flip_h = true
		else:
			direction = Vector2.LEFT
			animated_sprite_2d.flip_h = false
	
		can_walk = false
		timer.start()

func enemy_animations():
	if current_state == State.Idle && !can_walk:
		animated_sprite_2d.play("idle")
	elif current_state == State.Walk && can_walk:
		animated_sprite_2d.play("walk")


func _on_timer_timeout() -> void:
	can_walk = true


func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("hurtbox area enterned")
	if area.get_parent().has_method("get_damage_amount"):
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		print("health amount: ", health_amount)
		if health_amount <= 0:
			var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
			enemy_death_effect_instance.global_position = global_position
			get_parent().add_child(enemy_death_effect_instance)
			queue_free()
	
