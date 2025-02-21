@icon("icon_audio_depth_3d.svg")
extends Area3D
class_name AudioDepth

## Invoked when an entity with a matching body name enters
signal on_entity_enter;

## Invoked when an entity with a matching body name exits
signal on_entity_exit;

## The audio to play when entering the stream range
@export var audio_stream: AudioStream;

## The target volume for the node when at the bottom of the Area3D
@export_range(-25.0, 10.0, 1.0) var volume_at_depth = 0.0;

## The target volume when not at depth but closer to the top of the Area3D
@export_range(-30.0, 0.0, 1.0) var min_volume = -10.0;

## The main bus to play the audio under
@export var audio_bus = "Master";

var target: Node3D;

var audio_player: AudioStreamPlayer;
var is_entity_inside = false;

var _last_audio_pos = 0.0;
var collision_shape: CollisionShape3D;
var depth_y = 0.0;

func _ready() -> void:
	for child in self.get_children():
		if (child is CollisionShape3D):
			collision_shape = child;
			break;
			
	if (!collision_shape):
		printerr("[GigaAudio] AudioDepth3D does not have a collision shape. Disabled AudioDepth3D");
		return;
		
	var shape = collision_shape.shape as BoxShape3D;
	depth_y = collision_shape.global_transform.origin.y - shape.size.y / 2;
	print(depth_y);

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
	
	target = body;
	audio_player.play(_last_audio_pos);
	is_entity_inside = true;
	on_entity_enter.emit();
		
func _body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int):
	if (!body):
		return;
	
	if (!body.is_in_group("AudioTarget")):
		return;
	
	target = null;
	is_entity_inside = false;
	on_entity_exit.emit();

func _process(delta: float) -> void:
	if (!audio_player):
		return;
		
	if (!is_entity_inside):
		audio_player.volume_db = lerpf(audio_player.volume_db, -80.0, delta * 5.0);
		if (audio_player.playing && audio_player.volume_db <= -70.0):
			audio_player.playing = false;
			_last_audio_pos = audio_player.get_playback_position();
		return;
		
	if (!target):
		return;

	audio_player.volume_db = lerpf(audio_player.volume_db, _get_audio_depth_value(), 2.0 * delta);
	
func _get_audio_depth_value() -> float:
	return clampf(lerpf(volume_at_depth, min_volume, inverse_lerp(depth_y, depth_y + 40.0, target.global_position.y)), min_volume, volume_at_depth)
