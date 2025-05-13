extends CharacterBody2D

# Player speed
const SPEED = 90.0
const DEFAULT_SPEED_MULTIPLIER = 1.0
const DASH_SPEED = 2.5
const JUMP_VELOCITY = -300.0
const CAMERA_OFFSET = 0.75

# References
@onready var _sprite: Sprite2D = $Sprite
@onready var _animation_tree: AnimationTree = $AnimationTree
@onready var _animation_state_machine: AnimationNodeStateMachinePlayback = _animation_tree["parameters/playback"]
@onready var _state_chart: StateChart = $StateChart
@onready var _ray_cast_right: RayCast2D = $RayCastRight
@onready var _ray_cast_left: RayCast2D = $RayCastLeft
@onready var _camera: Camera2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Flags for player movement
var _was_grounded := false
var _speed_multiplier := 1.0
var _last_direction := 1.0


func _ready() -> void:
	_camera = get_node("Camera2D")
	if _camera:
		_camera.make_current()


func _process(delta: float) -> void:
	# Reset speed if body is colliding with anything
	if _ray_cast_right.is_colliding() or _ray_cast_left.is_colliding():
		if _speed_multiplier > DEFAULT_SPEED_MULTIPLIER:
			_reset_speed_multiplier()
	
	# Camera offset based on direction
	if _camera:
		var camera_speed := 1 * delta

		if _last_direction > 0:
			#_camera.drag_horizontal_offset = CAMERA_OFFSET
			_camera.drag_horizontal_offset = min(CAMERA_OFFSET, _camera.drag_horizontal_offset + camera_speed)
		elif _last_direction < 0:
			#_camera.drag_horizontal_offset = CAMERA_OFFSET * -1
			_camera.drag_horizontal_offset = max(CAMERA_OFFSET * -1, _camera.drag_horizontal_offset - camera_speed)

	print(_animation_state_machine.get_current_node())

func _physics_process(delta: float) -> void:
	pass # placeholder


func _on_can_move_state_physics_processing(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	
	# Reset speed if there was a change in direction. This prevents keeping dashing
	# momentum if the direction was changed
	if direction != _last_direction:
		_reset_speed_multiplier()
	_last_direction = direction
	
	if direction:
		velocity.x = direction * SPEED * _speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * _speed_multiplier)
	
	# Flip sprite before moving
	if signf(velocity.x) != 0:
		_sprite.flip_h = velocity.x < 0
	
	move_and_slide()
	
	# Check if we are on the floor
	if is_on_floor():
		velocity.y = 0
		# If we just touched the floor, notify state chart
		if not _was_grounded:
			_was_grounded = true
			_state_chart.send_event("grounded")
			
		if velocity.x == 0.0:
			_animation_state_machine.travel("idle")
		else:
			_animation_state_machine.travel("run")
	else:
		velocity.y += _gravity * delta
		
		# If we just left the floor, notify the state chart
		if _was_grounded:
			_was_grounded = false
			_state_chart.send_event("airborne")
	
	_state_chart.set_expression_property("velocity_y", velocity.y)


# Enable double jump. Connect to this function for all enabled states
func _on_jump_enabled_state_physics_processing(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		_state_chart.send_event("jump")
		
		if _was_grounded:
			_animation_state_machine.travel("jump")


# Enable dash. Typically only on grounded non-dashing state
func _on_dash_enabled_state_physics_processing(delta: float) -> void:
	if Input.is_action_just_pressed("dash") and _last_direction != 0:
		_speed_multiplier = DASH_SPEED
		_state_chart.send_event("dash")


# Additional processing when dashing
func _on_dashing_state_physics_processing(delta: float) -> void:
	if _last_direction:
		velocity.x = _last_direction * SPEED * _speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * _speed_multiplier)
	
	move_and_slide()


# Reset speed after grounded dash
func _on_dash_end() -> void:
	_reset_speed_multiplier()


# Reset speed on double jump
func _on_doublejump_jump() -> void:
	_reset_speed_multiplier()
	_animation_state_machine.travel("doublejump")


# Reset speed after bunny hop window expires
func _on_bunnyhop_expire() -> void:
	_reset_speed_multiplier()


# Reset speed multiplier
func _reset_speed_multiplier() -> void:
	_speed_multiplier = DEFAULT_SPEED_MULTIPLIER


# Process jump hold frames
func _on_rising_state_physics_processing(delta: float) -> void:
	# Cut off jump if button is released
	if Input.is_action_just_released("jump"):
		if velocity.y < 0:
			velocity.y *= 0.5


func _on_falling_state_entered() -> void:
	_animation_state_machine.travel("fall")
