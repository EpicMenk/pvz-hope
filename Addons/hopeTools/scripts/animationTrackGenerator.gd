@tool
extends Node
class_name animationTrackGenerator

# IMPORTANT:
# AnimationPlayer MUST be created directly under Visuals.
# Creating it elsewhere and moving it later causes incorrect
# track resolution in Godot 4.7.

@export var animationPlayer : AnimationPlayer
@export var visuals : Node2D

@export var animationName : StringName = "idle"
@export var insertKeyAt : float = 0.0
@export var animationLength : float = 2.0

@export_tool_button("Generate Tracks")
var generateButton := generateTracks

var sprites : Array[Sprite2D] = []


# Entry point.
# Creates the requested animation if necessary, then ensures
# every Sprite2D underneath Visuals has the required tracks.
func generateTracks():
	if animationPlayer == null or visuals == null:
		push_error("Assign AnimationPlayer and Visuals first.")
		return
	
	sprites.clear()
	
	var animation := getOrCreateAnimation()
	
	collectSprites(visuals)
	
	for sprite in sprites:
		addTransformTracks(animation, sprite)


# Recursively collects every Sprite2D underneath Visuals.
func collectSprites(node : Node):
	if node is Sprite2D:
		sprites.append(node)
	
	for child in node.get_children():
		collectSprites(child)


# Generates every transform/property track used by the animation system.
func addTransformTracks(animation : Animation, sprite : Sprite2D):
	addTrack(animation, sprite, "position", sprite.position)
	addTrack(animation, sprite, "rotation", sprite.rotation)
	addTrack(animation, sprite, "scale", sprite.scale)
	#addTrack(animation, sprite, "visible", sprite.visible)
	addTrack(animation, sprite, "modulate", sprite.modulate)
	addTrack(animation, sprite, "show_behind_parent", sprite.show_behind_parent)


# Creates a track if it doesn't already exist, then inserts
# the initial keyframe.
func addTrack(animation : Animation, node : Node, property : String, value : Variant):
	var path := NodePath(
		"%s:%s" % [
			animationPlayer.get_parent().get_path_to(node),
			property
		]
	)
	
	var track := findTrackIndex(animation, path)
	if track != -1:
		return
	
	track = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track, path)
	
	configureTrack(animation, track)
	
	animation.track_insert_key(track, insertKeyAt, value)


# Returns an existing animation or creates one if necessary.
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


# Returns the track index if the path already exists.
# Otherwise returns -1.
func findTrackIndex(animation : Animation, path : NodePath) -> int:
	for i in animation.get_track_count():
		if animation.track_get_path(i) == path:
			return i
	
	return -1


# Applies our preferred defaults for newly-created tracks.
func configureTrack(animation : Animation, track : int):
	animation.track_set_interpolation_type(
		track,
		Animation.INTERPOLATION_CUBIC
	)
