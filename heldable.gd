extends RigidBody3D

class_name Heldable


var disabled = false

func hints():
	return []

func on_state_enter(_state):
	pass

func on_state_exit(_state):
	pass

func ray_hints(_body):
	return []

func use(_point, _dir, _body, _normal):
	pass

func tick_ray(_point, _dir, _body, _normal):
	pass

func cleanup():
	pass

func on_pickup():
	pass
