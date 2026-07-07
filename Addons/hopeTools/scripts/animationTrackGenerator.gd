@tool
extends Node
class_name animationTrackGenerator

@export var animationPlayer : AnimationPlayer
@export var visuals : Node2D
@export var animationName : StringName = "idle"
@export var insertKeyAt : float = 0.0
@export var animationLength : float = 2.0
@export_tool_button("Generate Tracks")
var generateButton := generateTracks
@export_tool_button("print debug")
var debugbutton := debug
var sprites : Array[Sprite2D] = []

func debug():
	print(sprites)


# Entry point.
# Finds the selected animation and generates transform tracks
# for every Sprite2D underneath the Visuals node.
func generateTracks():
	if animationPlayer == null or visuals == null:
		push_error("Assign AnimationPlayer and Visuals first.")
		return
	sprites.clear()
	var animation := getOrCreateAnimation()
	
	getSprites(visuals)
	for sprite in sprites:
		addTransformTracks(animation, sprite)


# Recursively walks through the visuals hierarchy and collects
# every Sprite2D so we don't have to care how deeply nested they are.
func getSprites(node : Node):
	for child in node.get_children():
		if child is Sprite2D:
			sprites.append(child)
		getSprites(child)


# Generates the transform tracks required for a sprite.
# Currently position, rotation and scale.
# More properties (visibility, modulate, etc.) can be added later.
func addTransformTracks(animation : Animation, sprite : Sprite2D):
	addTrack(animation, sprite, "position", sprite.position)
	addTrack(animation, sprite, "rotation", sprite.rotation)
	addTrack(animation, sprite, "scale", sprite.scale)
	addTrack(animation, sprite, "visible" , sprite.visible)
	addTrack(animation, sprite, "modulate" , sprite.modulate)
	addTrack(animation, sprite, "show_behind_parent" , sprite.show_behind_parent )


# Finds (or creates) a track for the given property,
# then inserts a keyframe at time 0 using the sprite's current value.
func addTrack(animation : Animation, node : Node, property : String, value : Variant):
	var path := NodePath(
	str(animationPlayer.get_parent().get_path_to(node)) + ":" + property)
	var track := findTrackIndex(animation, path)
	if track == -1:
		track = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track, path)
		configureTrack(animation , track)
		animation.track_insert_key(track, insertKeyAt , value)


func getOrCreateAnimation() -> Animation:
	var library := animationPlayer.get_animation_library("")
	if library == null:
		library = AnimationLibrary.new()
		animationPlayer.add_animation_library("", library)
	var animation := library.get_animation(animationName)
	if animation == null:
		animation = Animation.new()
		animation.length = animationLength
		library.add_animation(animationName, animation)
	return animation


# Searches the animation for an existing track with the same path.
# Returns its index if found, otherwise returns -1.
func findTrackIndex(animation : Animation, path : NodePath) -> int:
	for i in animation.get_track_count():
		if animation.track_get_path(i) == path:
			return i
	return -1

func configureTrack(animation: Animation, track: int):
	animation.track_set_interpolation_type(
		track,
		Animation.InterpolationType.INTERPOLATION_CUBIC
	)
