extends CharacterBody3D
class_name Player

const SPEED: float = 5.0
const ACCELERATION: float = 12.0
const ROTATION: float = 10.0

const TOON = preload("uid://dvnq1gtre07ho")

@onready var skeleton = $elokido/Rig/Skeleton3D
@onready var body: MeshInstance3D = $elokido/Rig/Skeleton3D/Mesh
@onready var collision: CollisionShape3D = $Collision
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var anima: AnimationPlayer = $elokido/AnimationPlayer
@onready var anima_tree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var creator_ui: Control = $"../CreatorUI"

@onready var eyes: Array[MeshInstance3D] = [null]
@onready var mouths: Array[MeshInstance3D] = [null]
@onready var tails: Array[MeshInstance3D] = [null]
@onready var shirts: Array[MeshInstance3D] = [null]
@onready var pants: Array[MeshInstance3D] = [null]
@onready var hats: Array[MeshInstance3D] = [null]
@onready var rings: Array[MeshInstance3D] = [null]
@onready var earrings: Array[MeshInstance3D] = [null]
@onready var shoes: Array[MeshInstance3D] = [null]

var total_eyes: int
var total_hats: int
var total_shirts: int
var total_pants: int
var total_rings: int
var total_earrings: int
var total_shoes: int

var current_eyes_index: int = 0
var current_hat_index: int = 0
var current_shirt_index: int = 0
var current_pants_index: int = 0
var current_ring_index: int = 0
var current_earring_index: int = 0
var current_shoes_index: int = 0

var mouse_sensitivity: float = 0.15
var joystick_sensitivity: float = 1.0
var invert_y: bool = false
var _mouse_input_direction := Vector2.ZERO
var limit: int = 5.0

func _ready() -> void:
	creator_ui.saved.connect(_on_ui_saved)
	var shader := ShaderMaterial.new()
	shader.shader = TOON
	shader.set_shader_parameter("use_stepped", false)
	# Find all accessories
	for child in skeleton.get_children():
		if child is MeshInstance3D:
			# Apply shader material
			for surface in range(child.get_surface_override_material_count()):
				child.set_surface_override_material(surface, shader.duplicate())
			# Sort the accessories
			var category: String = child.name.get_slice("_", 0)
			if child.name != "Mesh":
				child.name = child.name.get_slice("_", 1)
				child.visible = false
			match category:
				"Eyes": eyes.append(child)
				"Mouth": mouths.append(child)
				"Tail": tails.append(child)
				"Hat": hats.append(child)
				"Shirt": shirts.append(child)
				"Pants": pants.append(child)
				"Ring": rings.append(child)
				"Earring": earrings.append(child)
				"Shoes": shoes.append(child)
	total_hats = hats.size()
	total_shirts = shirts.size()
	total_pants = pants.size()
	total_rings = rings.size()
	total_earrings = rings.size()
	total_shoes = shoes.size()
	total_eyes = eyes.size()


func _physics_process(delta: float) -> void:
	_camera_by_mouse(delta)
	_handle_movement_input(delta)
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_mouse_input_direction = event.screen_relative


func _camera_by_mouse(delta: float) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mouse_sens: float = mouse_sensitivity
		var y_sign: float = -1.0 if invert_y else 1.0
		camera_pivot.rotation.x -= _mouse_input_direction.y * mouse_sens * y_sign * delta
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI/2.0, PI/8.0)
		camera_pivot.rotation.y -= _mouse_input_direction.x * mouse_sens * delta
		_mouse_input_direction = Vector2.ZERO


func _handle_movement_input(delta: float) -> void:
	var raw_input: Vector2 = Input.get_vector("leftward", "rightward", "backward", "forward")
	var cam_basis: Basis = camera_pivot.global_transform.basis
	var move_dir: Vector3 = (cam_basis.x * raw_input.x + cam_basis.z * -raw_input.y)
	move_dir.y = 0.0
	move_dir = move_dir.normalized() if move_dir.length() > 0.01 else Vector3.ZERO

	var target_velocity: Vector3 = move_dir * SPEED

	velocity.x = move_toward(velocity.x, target_velocity.x, ACCELERATION * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, ACCELERATION * delta)

	# Restrict movement
	global_position.x = clamp(global_position.x, -limit, limit)
	global_position.z = clamp(global_position.z, -limit, limit)

	# Face movement direction
	if move_dir.length() > 0.01:
		var target_rot := atan2(move_dir.x, move_dir.z)
		skeleton.rotation.y = lerp_angle(skeleton.rotation.y, target_rot, ROTATION * delta)
	
		# Walk animation blend state
		playback.travel("walking")
		var speed_norm: float = Vector2(velocity.x, velocity.z).length() / SPEED
		anima_tree["parameters/walking/blend_position"] = clamp(speed_norm, 0.0, 1.0)
	else:
		playback.travel("still")


func footstep() -> void:
	AudioManager.char.play()


func _on_ui_saved() -> void:
	playback.travel("surprise")
