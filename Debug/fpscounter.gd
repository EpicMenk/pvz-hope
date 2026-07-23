extends Label

func _process(_delta):
   # Update the label text with the current FPS
   text = "FPS: %d" % Engine.get_frames_per_second()
