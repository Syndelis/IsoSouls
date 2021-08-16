extends Spatial

func correctPrompt():
	
	$PC.visible = false
	$PS4.visible = false
	$Xbox.visible = false
	
	match GlobalPrompt.input_type:
		GlobalPrompt.InputType.PC:
			$PC.visible = true
			
		GlobalPrompt.InputType.PS4:
			$PS4.visible = true
		
		GlobalPrompt.InputType.Xbox:
			$Xbox.visible = true


func _input(event):
	
	if visible:
		
		if event is InputEventKey or event is InputEventMouseButton:
			GlobalPrompt.input_type = GlobalPrompt.InputType.PC
			
		elif event is InputEventJoypadButton:
			var name = Input.get_joy_name(event.device)
			
			if name.begins_with("PS"):
				GlobalPrompt.input_type = GlobalPrompt.InputType.PS4
				
			else: GlobalPrompt.input_type = GlobalPrompt.InputType.Xbox
			
		correctPrompt()


func _on_InteractPrompt_visibility_changed():
	correctPrompt()
	
	if visible:
		$AnimationPlayer.play("Anim")
		
	else: $AnimationPlayer.stop()
