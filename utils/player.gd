extends CharacterBody3D
class_name Player

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

@onready var elokido = $elokido
@onready var body = $elokido/Rig/Skeleton3D/Mesh
@onready var collision: CollisionShape3D = $Collision
@onready var camera: Camera3D = $Camera
@onready var creator_ui: Control = $"../CreatorUI"

@onready var eyes: Array[MeshInstance3D] = [null]
@onready var mouths: Array[MeshInstance3D] = [null]
@onready var tails: Array[MeshInstance3D] = [null]
@onready var outfits: Array[MeshInstance3D] = [null]
@onready var hats: Array[MeshInstance3D] = [null]
@onready var rings: Array[MeshInstance3D] = [null]
@onready var earrings: Array[MeshInstance3D] = [null]
@onready var shoes: Array[MeshInstance3D] = [null]

var total_hats: int
var total_outfits: int
var total_rings: int
var total_earrings: int
var total_shoes: int

var current_hat_index: int = 0
var current_outfit_index: int = 0
var current_rings_index: int = 0
var current_earrings_index: int = 0
var current_shoes_index: int = 0

func _ready() -> void:
	# Find all accessories
	for child in elokido.get_children():
		if child is MeshInstance3D:
			var category: String = child.name.get_slice("_", 0)
			child.name = child.name.get_slice("_", 1)
			match category:
				"Eyes": eyes.append(child)
				"Mouth": mouths.append(child)
				"Tail": tails.append(child)
				"Hat": hats.append(child)
				"Outfit": outfits.append(child)
				"Ring": rings.append(child)
				"Earring": earrings.append(child)
				"Shoes": shoes.append(child)
	total_hats = hats.size()
	total_outfits = outfits.size()
	total_rings = rings.size()
	total_earrings = rings.size()
	total_shoes = shoes.size()
	print("Player hats: " + str(total_hats))

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
