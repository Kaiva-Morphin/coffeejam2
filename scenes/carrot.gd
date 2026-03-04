extends Heldable

var preview
@export var preview_material : StandardMaterial3D

func _ready():
	if preview_material == null:
		preview_material = StandardMaterial3D.new()
		preview_material.albedo_color = Color(0.2, 1, 0.4, 0.4)
		preview_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	$CollisionShape3D.shape = $CollisionShape3D.shape.duplicate(true)
	$MeshInstance3D.mesh = $MeshInstance3D.mesh.duplicate(true)
	preview = Node3D.new()
	var m = $MeshInstance3D.duplicate()
	preview.add_child(m)
	get_tree().root.add_child.call_deferred(preview)
	preview.hide()
	m.material_override = preview_material




func tick_ray(point: Vector3, _dir, body, normal: Vector3):
	if body:
		preview.global_position = point
		var up := normal.normalized()
		var ref_forward := Vector3.FORWARD
		if abs(up.dot(ref_forward)) > 0.99:
			ref_forward = Vector3.RIGHT
		var right := up.cross(ref_forward).normalized()
		var forward := right.cross(up).normalized()
		preview.global_basis = Basis(right, up, -forward)
		preview.show()
	else:
		preview.hide()

func cleanup():
	preview.hide()
	GLOBAL.hints.rm_hint("snowball")


func ray_hints():
	if self.disabled:
		GLOBAL.hints.rm_hint("snowball")
		return []
	return [
		["snowball", "F", "Прикрепить"],
	]


func use(_point: Vector3, _dir, _body, _normal):
	if self.disabled: return
	if !_body: return
	var body = StaticBody3D.new()
	get_tree().root.add_child(body)
	var up = _normal.normalized()
	var ref_forward := Vector3.FORWARD
	if abs(up.dot(ref_forward)) > 0.99:
		ref_forward = Vector3.RIGHT
	var right = up.cross(ref_forward).normalized()
	var forward = right.cross(up).normalized()
	body.global_position = _point
	body.global_basis = Basis(right, up, -forward)
	var c = $CollisionShape3D.duplicate()
	c.disabled = false
	body.add_child(c)
	body.add_child($MeshInstance3D.duplicate())
	#cleanup()
	#preview.queue_free()
	#self.queue_free()
	#get_tree().create_timer(0.001).timeout.connect(func (): GLOBAL.hints.rm_hint("snowball"))


func on_state_enter(_state):
	self.disabled = true
	cleanup()


func on_state_exit(_state):
	self.disabled = false
