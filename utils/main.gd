extends Node3D

@onready var creator_ui = $CreatorUI
@onready var player = $Player


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("pause"):
			#get_tree().paused = !get_tree().paused
			creator_ui.visible = !creator_ui.visible
			creator_ui.body.visible = !creator_ui.body.visible
			player.visible = !player.visible
			if player.camera.current:
				creator_ui.camera.make_current()
			elif creator_ui.camera.current:
				player.camera.make_current()
