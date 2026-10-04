extends SkeletonModifier3D
class_name LeftHandGrip


# Turns the left hand so it grips the sword handle. LeftHandIK only moves the
# wrist to the handle and keeps the hand's animated rotation, which can leave
# the palm facing away from the handle; this sets the hand's rotation to the
# target's (LeftHandGoal, placed this frame by LeftHandGoalSync from the
# LeftHandTarget animated per animation), with the same weight as the IK. Must
# run after the IK (be after it in the Skeleton3D's children).

@export var target: Node3D
@export var ik: SkeletonModifier3D
@export var boneName := "hand_l"


func _process_modification() -> void:
	var skeleton := get_skeleton()
	if skeleton == null or target == null or ik == null or not ik.active:
		return
	var weight := ik.influence
	if weight <= 0.0:
		return
	var bone := skeleton.find_bone(boneName)
	var pose := skeleton.get_bone_global_pose(bone)
	var wanted := (skeleton.global_transform.affine_inverse() * target.global_transform).basis.get_rotation_quaternion()
	var rotation := pose.basis.get_rotation_quaternion().slerp(wanted, weight)
	skeleton.set_bone_global_pose(bone, Transform3D(Basis(rotation), pose.origin))
