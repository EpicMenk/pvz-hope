@tool
extends Node2D
class_name bakeRig

signal bakingCompleted

@export var output_dir : String = "res://BakedFrames/"
@export var target_fps : float = 30
@export var animations_to_bake : Array[String] = []
@export var capture_size : Vector2i = Vector2i(128, 128)

@onready var viewport : SubViewport = %SubViewport
@onready var rig_container : Node2D = %Node2D

# ------------------------------------------------------------
# Bake selection
# ------------------------------------------------------------

# If false, the entire rig is baked normally.
#
# If true:
# - bakeTarget and its descendants are included.
# - anything outside bakeTarget is hidden.
# - anything inside bakeExcludedNodes is hidden even if it
#   would normally be included.
@export var bakeOnlyTarget : bool = false:
	set(value):
		bakeOnlyTarget = value
		notify_property_list_changed()

# The top node of the visual group to bake.
#
# Examples:
# Head
# UpperHandRight
# root
@export var bakeTarget : Node2D

# The top-level node that the bake target will temporarily
# be reparented to when the target is not already at this level.
#
# In your zombie scene this is "root".
@export var bakeRoot : Node2D

# Any branches that should be excluded from the bake.
#
# Example for the body:
# bakeTarget = root
# bakeExcludedNodes = [Head, UpperHandRight]
#
# This means the body, left arm, and legs remain while
# the head and right arm are removed from the baked result.
@export var bakeExcludedNodes : Array[Node2D] = []

@export_tool_button("Scan Folder") var scanFolder := scanFiles

var _anim_player : AnimationPlayer

# Original visibility of every Sprite2D before baking starts.
#
# We use this to restore the rig before evaluating the next
# animation frame, and after baking has finished.
var _originalVisibility : Dictionary = {}

# Original parent of the bake target when it is temporarily
# reparented.
var _originalParent : Node = null

# Original visibility of the bake target itself.
var _originalTargetVisible : bool = true


func scanFiles():
	if Engine.is_editor_hint():
		var fileSystem : EditorFileSystem = EditorInterface.get_resource_filesystem()

		if not fileSystem.is_scanning():
			fileSystem.scan()


func _ready():
	if Engine.is_editor_hint():
		return

	viewport.size = capture_size
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	_anim_player = _find_animation_player(rig_container)

	if _anim_player == null:
		push_error("No AnimationPlayer found under RigContainer.")
		return

	if bakeOnlyTarget:
		if bakeTarget == null:
			push_error(
				"Bake Only Target is enabled, but no Bake Target was assigned."
			)
			return

		if bakeRoot == null:
			push_error(
				"Bake Only Target is enabled, but no Bake Root was assigned."
			)
			return

	var anim_list : Array[String] = animations_to_bake

	if anim_list.is_empty():
		anim_list.assign(_anim_player.get_animation_list())

	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(output_dir)
	)

	# Save the editor state before any baking changes are made.
	_saveOriginalVisibility()

	# Calculate the crop using exactly the same isolation logic
	# that will be used during the actual bake.
	var crop_rect : Rect2i = await _compute_global_crop_rect(anim_list)

	for anim_name in anim_list:
		await _bake_animation(anim_name, crop_rect)

	# Make sure everything has been restored.
	_restoreBakeTarget()
	_restoreOriginalVisibility()

	print("Baking complete! Check: ", output_dir)

	bakingCompleted.emit()


func _find_animation_player(node : Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node

	for child in node.get_children():
		var found : AnimationPlayer = _find_animation_player(child)

		if found:
			return found

	return null


# ============================================================
# ANIMATION BAKING
# ============================================================

func _bake_animation(anim_name : String, crop_rect : Rect2i):

	# Make sure the animation starts from the original rig state.
	_restoreBakeTarget()
	_restoreOriginalVisibility()

	_anim_player.play(anim_name)
	_anim_player.pause()
	_anim_player.seek(0.0, true)
	_anim_player.advance(0.0)

	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw

	var animation : Animation = _anim_player.get_animation(anim_name)

	var frame_interval : float = 1.0 / target_fps
	var frame_count : int = int(animation.length / frame_interval) + 1

	var columns : int = int(ceil(sqrt(frame_count)))
	var rows : int = int(ceil(float(frame_count) / columns))

	var frames : Array[Image] = []

	for frame_i in range(frame_count):

		var t : float = frame_i * frame_interval

		# --------------------------------------------------------
		# 1. Restore original hierarchy and visibility.
		# --------------------------------------------------------

		_restoreBakeTarget()
		_restoreOriginalVisibility()

		# --------------------------------------------------------
		# 2. Evaluate the animation normally.
		#
		# This MUST happen while the rig has its original hierarchy
		# because AnimationPlayer tracks depend on those paths.
		# --------------------------------------------------------

		_anim_player.seek(t, true)
		_anim_player.advance(0.0)

		# --------------------------------------------------------
		# 3. Apply bake-only isolation.
		#
		# This happens AFTER animation evaluation so the animation's
		# visibility/modulate tracks cannot overwrite our selection.
		# --------------------------------------------------------

		_prepareBakeTarget()

		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw

		frames.append(
			viewport.get_texture().get_image()
		)

		# --------------------------------------------------------
		# 4. Restore before evaluating the next frame.
		# --------------------------------------------------------

		_restoreBakeTarget()
		_restoreOriginalVisibility()


	var sheet : Image = Image.create(
		columns * crop_rect.size.x,
		rows * crop_rect.size.y,
		false,
		Image.FORMAT_RGBA8
	)

	for i in range(frame_count):

		var cropped : Image = Image.create(
			crop_rect.size.x,
			crop_rect.size.y,
			false,
			Image.FORMAT_RGBA8
		)

		cropped.blit_rect(
			frames[i],
			crop_rect,
			Vector2i.ZERO
		)

		var col : int = i % columns

		@warning_ignore("integer_division")
		var row : int = i / columns

		var dst : Vector2i = Vector2i(
			col * crop_rect.size.x,
			row * crop_rect.size.y
		)

		sheet.blit_rect(
			cropped,
			Rect2i(
				Vector2i.ZERO,
				crop_rect.size
			),
			dst
		)

	var sheet_path : String = output_dir.path_join(
		anim_name + ".png"
	)

	sheet.save_png(sheet_path)

	var meta_path : String = output_dir.path_join(
		anim_name + "_info.txt"
	)

	var meta_file : FileAccess = FileAccess.open(
		meta_path,
		FileAccess.WRITE
	)

	var layer_offset : Vector2 = (
		Vector2(crop_rect.position)
		+ Vector2(crop_rect.size) / 2.0
	) - (Vector2(capture_size) / 2.0)

	meta_file.store_string(
		"frame_count: %d\ncolumns: %d\nrows: %d\nframe_size: %dx%d\nlayer_offset: %f,%f\n"
		% [
			frame_count,
			columns,
			rows,
			crop_rect.size.x,
			crop_rect.size.y,
			layer_offset.x,
			layer_offset.y
		]
	)

	meta_file.close()

	print(
		"Baked '",
		anim_name,
		"': ",
		frame_count,
		" frames -> ",
		sheet_path,
		" (",
		columns,
		"x",
		rows,
		" grid)"
	)


# ============================================================
# ORIGINAL VISIBILITY
# ============================================================

func _saveOriginalVisibility():
	_originalVisibility.clear()

	var sprites : Array[Sprite2D] = []

	_collectSprites(
		rig_container,
		sprites
	)

	for sprite in sprites:
		_originalVisibility[sprite] = sprite.visible


func _restoreOriginalVisibility():
	for sprite in _originalVisibility:
		if is_instance_valid(sprite):
			sprite.visible = _originalVisibility[sprite]


# ============================================================
# BAKE TARGET ISOLATION
# ============================================================

func _prepareBakeTarget():
	if not bakeOnlyTarget:
		return

	if bakeTarget == null:
		return

	if bakeRoot == null:
		return

	var allSprites : Array[Sprite2D] = []

	_collectSprites(
		rig_container,
		allSprites
	)

	var targetSprites : Array[Sprite2D] = []

	_collectSprites(
		bakeTarget,
		targetSprites
	)

	# ------------------------------------------------------------
	# Hide everything outside the target subtree.
	#
	# IMPORTANT:
	# We do NOT set visibility on sprites inside the target subtree.
	#
	# This means animation-controlled visibility still works for:
	# - eyes
	# - jaw
	# - other animated sub-limbs
	# ------------------------------------------------------------

	for sprite in allSprites:

		if not _isInsideBakeTarget(sprite):
			sprite.visible = false

	# ------------------------------------------------------------
	# Apply explicit exclusions.
	#
	# This is what allows:
	#
	# bakeTarget = root
	# exclusions = Head + RightArm
	#
	# to produce the body-only sheet.
	# ------------------------------------------------------------

	for excludedNode in bakeExcludedNodes:

		if excludedNode == null:
			continue

		var excludedSprites : Array[Sprite2D] = []

		_collectSprites(
			excludedNode,
			excludedSprites
		)

		for sprite in excludedSprites:
			sprite.visible = false

	# ------------------------------------------------------------
	# Detach the target if it is not already at bakeRoot.
	#
	# This is necessary for things like Head and RightArm because
	# they may otherwise inherit visibility from Torso.
	# ------------------------------------------------------------

	if bakeTarget != bakeRoot:

		if bakeTarget.get_parent() != bakeRoot:

			_originalParent = bakeTarget.get_parent()
			_originalTargetVisible = bakeTarget.visible

			bakeTarget.reparent(
				bakeRoot,
				true
			)

		# The selected target itself must render.
		#
		# Descendants are NOT forced visible so their animation
		# tracks continue to control them.
		bakeTarget.visible = true


func _isInsideBakeTarget(sprite : Sprite2D) -> bool:

	if bakeTarget == null:
		return true

	# When bakeTarget itself is the root, every sprite belongs
	# to the target unless explicitly excluded.
	if bakeTarget == rig_container:
		return true

	# A sprite is included when it is the target itself or one of
	# its descendants.
	if bakeTarget == sprite:
		return true

	return bakeTarget.is_ancestor_of(sprite)


func _restoreBakeTarget():

	if not bakeOnlyTarget:
		return

	if bakeTarget == null:
		return

	# The body/root bake does not need reparenting.
	if bakeTarget == bakeRoot:
		return

	if _originalParent == null:
		return

	# Reparent back to the original hierarchy while preserving
	# the global transform.
	bakeTarget.reparent(
		_originalParent,
		true
	)

	bakeTarget.visible = _originalTargetVisible

	_originalParent = null


func _collectSprites(
	node : Node,
	result : Array[Sprite2D]
):
	if node is Sprite2D:
		result.append(node)

	for child in node.get_children():
		_collectSprites(
			child,
			result
		)


# ============================================================
# CROPPING
# ============================================================

func _getTrimRect(img : Image) -> Rect2i:
	var min_x : int = img.get_width()
	var min_y : int = img.get_height()

	var max_x : int = -1
	var max_y : int = -1

	for y in range(img.get_height()):
		for x in range(img.get_width()):

			if img.get_pixel(x, y).a > 0.001:
				min_x = min(min_x, x)
				min_y = min(min_y, y)

				max_x = max(max_x, x)
				max_y = max(max_y, y)

	if max_x == -1:
		return Rect2i(
			Vector2i.ZERO,
			Vector2i.ONE
		)

	return Rect2i(
		min_x,
		min_y,
		max_x - min_x + 1,
		max_y - min_y + 1
	)


func _compute_global_crop_rect(
	anim_list : Array[String]
) -> Rect2i:

	var global_min_x : int = capture_size.x
	var global_min_y : int = capture_size.y

	var global_max_x : int = 0
	var global_max_y : int = 0

	const PADDING : int = 2

	for anim_name in anim_list:

		# Always evaluate with the original rig.
		_restoreBakeTarget()
		_restoreOriginalVisibility()

		_anim_player.play(anim_name)
		_anim_player.pause()
		_anim_player.seek(0.0, true)
		_anim_player.advance(0.0)

		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw

		var animation : Animation = _anim_player.get_animation(
			anim_name
		)

		var frame_interval : float = 1.0 / target_fps
		var frame_count : int = int(
			animation.length / frame_interval
		) + 1

		for frame_i in range(frame_count):

			var t : float = frame_i * frame_interval

			# ----------------------------------------------------
			# Evaluate animation in original hierarchy.
			# ----------------------------------------------------

			_restoreBakeTarget()
			_restoreOriginalVisibility()

			_anim_player.seek(t, true)
			_anim_player.advance(0.0)

			# ----------------------------------------------------
			# Isolate the desired bake group AFTER evaluating.
			# ----------------------------------------------------

			_prepareBakeTarget()

			await RenderingServer.frame_post_draw
			await RenderingServer.frame_post_draw

			var frame_img : Image = (
				viewport.get_texture().get_image()
			)

			var trim : Rect2i = _getTrimRect(
				frame_img
			)

			global_min_x = min(
				global_min_x,
				trim.position.x
			)

			global_min_y = min(
				global_min_y,
				trim.position.y
			)

			global_max_x = max(
				global_max_x,
				trim.position.x + trim.size.x
			)

			global_max_y = max(
				global_max_y,
				trim.position.y + trim.size.y
			)

			_restoreBakeTarget()
			_restoreOriginalVisibility()

	global_min_x = max(
		global_min_x - PADDING,
		0
	)

	global_min_y = max(
		global_min_y - PADDING,
		0
	)

	global_max_x = min(
		global_max_x + PADDING,
		capture_size.x
	)

	global_max_y = min(
		global_max_y + PADDING,
		capture_size.y
	)

	var crop_rect : Rect2i = Rect2i(
		global_min_x,
		global_min_y,
		global_max_x - global_min_x,
		global_max_y - global_min_y
	)

	print(
		"Global crop rect: ",
		crop_rect
	)

	return crop_rect

func _validate_property(property : Dictionary):
	if property.name == "bakeTarget":
		if not bakeOnlyTarget:
			property.usage = PROPERTY_USAGE_NO_EDITOR

	elif property.name == "bakeRoot":
		if not bakeOnlyTarget:
			property.usage = PROPERTY_USAGE_NO_EDITOR

	elif property.name == "bakeExcludedNodes":
		if not bakeOnlyTarget:
			property.usage = PROPERTY_USAGE_NO_EDITOR
