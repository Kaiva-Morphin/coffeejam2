extends CharacterBody3D

# ====== НАСТРОЙКИ ======
@export var SPEED: float = 10.0
@export var LOSS_SPEED: float = 50.0;
@export var GAIN_SPEED: float = 50.0;
@export var GRAVITY_SCALE: float = 20.0
@export var MOUSE_SENSITIVITY: float = 0.002

@export var TILT_LOWER_LIMIT := deg_to_rad(-80.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(80.0)

@export var CAMERA_CONTROLLER: Camera3D
@export var PICKUP_RAYCAST: RayCast3D

# ====== ВНУТРЕННИЕ ПЕРЕМЕННЫЕ ======
var _mouse_input := false
var _rotation_input := 0.0
var _tilt_input := 0.0

var _mouse_rotation := Vector2.ZERO # x = tilt, y = yaw


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

var picked_item : RigidBody3D = null
var held_distance = 10.0
@export var dbg : Node3D

func _process(_dt: float) -> void:
	if Input.is_action_just_released("lmb"):
		if picked_item == null: return
		picked_item.sleeping = false
		picked_item.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_AUTO
		picked_item = null
	
	if Input.is_action_just_pressed("lmb"):
		var body = PICKUP_RAYCAST.get_collider()
		if body == null:
			return
		if picked_item != null: return
		#print("q")
		if body is RigidBody3D:
			picked_item = body
			picked_item.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
			var d = PICKUP_RAYCAST.get_collision_point()
			held_distance = (d - PICKUP_RAYCAST.global_position).length() # ??
			dbg.global_position = d
			
			# how to make it relative to rotation? (in local space)
			picked_item.center_of_mass = picked_item.to_local(d)
	#print(picked_item)

#func _integrate_forces():
	if picked_item:
		var target_pos = PICKUP_RAYCAST.global_position - PICKUP_RAYCAST.global_transform.basis.z * held_distance
		var dir = target_pos - picked_item.global_position
		picked_item.linear_velocity = velocity + dir * 10.0
		#picked_item.global_position = target_pos
		#print(target_pos)
		# вращение относительно мыши (если нужно)
		#var mouse_delta = Input.get_last_mouse_speed() * 0.01
		#picked_item.angular_velocity = Vector3(-mouse_delta.y, -mouse_delta.x, 0)
	


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_rotation_input -= event.relative.x * MOUSE_SENSITIVITY
		_tilt_input -= event.relative.y * MOUSE_SENSITIVITY

	if event.is_action_pressed("ui_cancel"):
		_mouse_input = !_mouse_input
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if _mouse_input else Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	_update_camera()
	_update_movement(delta)


func _update_camera() -> void:
	_mouse_rotation.x = clamp(
		_mouse_rotation.x + _tilt_input,
		TILT_LOWER_LIMIT,
		TILT_UPPER_LIMIT
	)
	_mouse_rotation.y += _rotation_input

	rotation.y = _mouse_rotation.y
	CAMERA_CONTROLLER.rotation.x = _mouse_rotation.x
	CAMERA_CONTROLLER.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0


func _update_movement(delta: float) -> void:
	var input_dir := Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("forward", "backward")
	)
	
	var direction := Vector3.ZERO
	if input_dir != Vector2.ZERO:
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var target_velocity := direction * SPEED
	velocity = velocity.move_toward(target_velocity, LOSS_SPEED * delta)
	
	velocity.y += get_gravity().y * GRAVITY_SCALE * delta
	
	move_and_slide()

func _handle_push(delta: float) -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider is RigidBody3D:
			var push_dir := -collision.get_normal()
			var push_amount := velocity.length() * delta

			collider.global_position += push_dir * push_amount

			# Гасим скорость игрока, чтобы не было дрожания
			velocity.x *= 0.8
			velocity.z *= 0.8
