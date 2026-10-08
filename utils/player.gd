extends CharacterBody3D
class_name Player

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

@onready var mesh: MeshInstance3D = $Mesh
@onready var body = $human/MaleRig/Skeleton3D/MaleMesh
@onready var collision: CollisionShape3D = $Collision
@onready var camera: Camera3D = $Camera
@onready var creator_ui: Control = $"../CreatorUI"

var current_player: Player

func _ready() -> void:
	current_player = self

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("leftward", "rightward", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

#func _input(event: InputEvent) -> void:
	#if event is InputEventKey:
		#if Input.is_action_just_pressed("pause"):
			##get_tree().paused = !get_tree().paused
			#creator_ui.visible = !creator_ui.visible
