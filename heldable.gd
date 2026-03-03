extends RigidBody3D

class_name Heldable


var disabled = false

func hints():
	return []



func on_state_enter(state):
	pass

func on_state_exit(state):
	pass



func ray_hints():
	return []

func use(_point, _dir, _body, _normal):
	pass

func tick_ray(_point, _dir, _body, _normal):
	pass

func cleanup():
	pass

func on_pickup():
	pass
