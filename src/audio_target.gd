@icon("icon_audio_target.svg")
extends Node
class_name AudioTarget3D

func _ready():
	var parent = self.get_parent();
	parent.add_to_group("AudioTarget");
