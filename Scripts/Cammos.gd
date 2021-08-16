extends Node

export(NodePath) var floor_path
onready var flooring = get_node(floor_path)
onready var cammo = preload("res://Prefabs/CammoFloor.tscn")
const start = Vector3(65, 15.5, -205)
const end = Vector3(95, 15.5, -125)

func getCellv(x, z):
	
	return flooring.get_cell_item(
		int((x - 5) / flooring.cell_size.x),
		int(start.y / flooring.cell_size.y),
		int((z - 5) / flooring.cell_size.z)
	)

func _ready():
	for x in range(start.x, end.x + 10, 10):
		for z in range(start.z, end.z + 10, 10):
			if getCellv(x, z) == GridMap.INVALID_CELL_ITEM:
				var c = cammo.instance()
				c.transform.origin = Vector3(x, start.y, z)
				add_child(c)
