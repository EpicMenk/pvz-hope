extends entityComponent
class_name animationComponent

@export var animationPlayer : AnimationPlayer
@export var fallbackAnimName : StringName = &""

# Per-animation config, keyed by animation name (Section 20).
# actionPointRatios / maxPlaybackSpeeds are stored now but unused until
# Phase 3's speed math — see playAction() below.
@export var actionPointRatios : Dictionary
@export var maxPlaybackSpeeds : Dictionary
@export var uninterruptibleAnimNames : Array[StringName] = []   # Section 28, visual-only guard — live starting this phase
@export var actionPriorities : Dictionary[StringName, int]   # animName -> int, default 0 if unlisted. Higher wins while its claim hasn't expired.
var protectedActive : bool = false

var activePriority : int = -1
var activeUntil : float = 0.0

func _ready() -> void:
	if animationPlayer:
		animationPlayer.animation_finished.connect(onAnimFinished)

func playAction(animName: StringName, actionInterval: float) -> void:
	if not animationPlayer or not isActivated():
		return
	if protectedActive:
		return   # gameplay already happened via the caller; only the visual is held (Section 28)
	# Phase 2 placeholder — always normal speed. Phase 3 replaces this with
	# the requiredPlaybackSpeed formula (Sections 4-7, 21) using
	# actionPointRatios/maxPlaybackSpeeds above.
	var priority : int = actionPriorities.get(animName, 0)
	var now := Time.get_ticks_msec() / 1000.0
	if priority < activePriority and now < activeUntil:
		return   # a higher-priority animation still owns the display

	activePriority = priority
	activeUntil = now + actionInterval
	animationPlayer.speed_scale = 1.0
	animationPlayer.play(animName)
	if animName in uninterruptibleAnimNames:
		protectedActive = true
	
	animationPlayer.speed_scale = 1.0
	animationPlayer.play(animName)
	if animName in uninterruptibleAnimNames:
		protectedActive = true

func releaseClaim() -> void:
	# Ends a claim early without playing anything — for cases where some
	# other owner is already continuously re-calling playAction on its own
	# schedule (e.g. a walk cycle), so the display resumes on THEIR next
	# natural call instead of an out-of-band restart that fights it.
	activePriority = -1
	activeUntil = 0.0

func revertToFallback() -> void:
	# For state changes where nothing else is continuously re-driving the
	# display afterward — forces fallbackAnimName (or stop() if empty),
	# per Section 14. If a continuous owner like a walk loop exists,
	# prefer releaseClaim() so the resumption stays in sync with it.
	if not animationPlayer or protectedActive:
		return
	releaseClaim()
	if fallbackAnimName == &"":
		animationPlayer.stop()
	else:
		animationPlayer.play(fallbackAnimName)

func onAnimFinished(animName: StringName) -> void:
	if animName in uninterruptibleAnimNames:
		protectedActive = false
