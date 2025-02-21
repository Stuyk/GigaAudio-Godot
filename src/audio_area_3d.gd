@icon("icon_audio_area_3d.svg")
extends Area3D
class_name AudioArea3D

## Invoked when an entity with a matching body name enters
signal on_entity_enter;

## Invoked when an entity with a matching body name exits
signal on_entity_exit;

## The audio to play when entering the stream range
@export var audio_stream: AudioStream;

## The target volume for the node when fully faded in
@export_range(-25.0, 10.0, 1.0) var fade_in_volume = 0.0;

## The target volume for the node when fully faded out
@export_range(-80.0, 10.0, 1.0) var fade_out_volume = -80.0;

## The main bus to play the audio under
@export var audio_bus = "Master";

## The time it takes for the audio to fade in
@export_range(0.1, 5.0, 0.1) var fade_in_speed = 0.5;

## The time it takes for the audio to fade out
@export_range(0.1, 5.0, 0.1) var fade_out_speed = 0.5;

var audio_player: AudioStreamPlayer;
var is_entity_inside = false;

var _last_audio_pos = 0.0;

func _ready() -> void:
	audio_player = AudioStreamPlayer.new();
	audio_player.volume_db = -80.0;
	audio_player.stream = audio_stream;
	audio_player.bus = audio_bus;
	self.add_child(audio_player);
	
	self.body_shape_entered.connect(_body_shape_entered);
	self.body_shape_exited.connect(_body_shape_exited);
	
func _body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int):
	if (!body):
		return;
	
	if (!body.is_in_group("AudioTarget")):
		return;
	
	audio_player.play(_last_audio_pos);
	is_entity_inside = true;
	on_entity_enter.emit();
		
func _body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int):
	if (!body):
		return;
	
	if (!body.is_in_group("AudioTarget")):
		return;

	is_entity_inside = false;
	on_entity_exit.emit();

func _process(delta: float) -> void:
	if (!audio_player):
		return;
		
	if (is_entity_inside):
		audio_player.volume_db = lerpf(audio_player.volume_db, fade_in_volume, delta * fade_in_speed);
		return;
	
	audio_player.volume_db = lerpf(audio_player.volume_db, fade_out_volume, delta * fade_out_speed);
	if (audio_player.playing && audio_player.volume_db <= -70.0):
		audio_player.playing = false;
		_last_audio_pos = audio_player.get_playback_position();
