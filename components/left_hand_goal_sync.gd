extends SkeletonModifier3D
class_name LeftHandGoalSync


# Places the goal of the left hand IK on the sword handle using this frame's
# pose of the right hand. LeftHandTarget hangs from a BoneAttachment3D, which is
# only updated after the skeleton modifiers run, so aiming the IK at it directly
# uses the previous frame's handle and the left hand trembles whenever the body
# moves (e.g. running). Must run before the IK (be before it in the Skeleton3D's
# children).

@export var source: Node3D
@export var attachment: BoneAttachment3D
@export var goal: Node3D


func _process_modification() -> void:
	var skeleton := get_skeleton()
	if skeleton == null or source == null or attachment == null or goal == null:
		return
	# Offset of the target from the hand: only the sword and target local
	# transforms, which are already current, so the stale attachment cancels out.
	var offset := attachment.global_transform.affine_inverse() * source.global_transform
	var hand := skeleton.get_bone_global_pose(skeleton.find_bone(attachment.bone_name))
	goal.global_transform = skeleton.global_transform * hand * offset
