extends StaticBody

export(int, FLAGS, "Alpha", "Beta", "Gamma") var key_required = 0
var open = false

func interact():
	
	if not open:
		if Global.Player.has(key_required):
			$DungeonEntrance001/AnimationPlayer.play("Open")
			open = true
		
		else:
			pass # Tell player he can't open it yet

func prompt(vis):
	$InteractPrompt.visible = (not open) and vis
