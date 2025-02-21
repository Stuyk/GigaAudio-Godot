@icon("icon_audio_occluder_3d.svg")
extends AudioStreamPlayer3D
class_name AudioOccluder3D

# How much to reduce volume when occluded
@export var occlusion_db: float = -8.0;

# Low-pass filter cutoff when occluded
@export var cutoff_hz: float = 800;

# How fast to transition effects
@export var transition_speed: float = 5.0;

# Number of additional vertical rays
@export var extra_rays: int = 2  

# Height offset for extra rays
@export var vertical_offset: float = 1.0  

var target_volume = 0.0
var target_cutoff = 20000.0

var target: Node3D;

func _ready() -> void:
	var target_nodes = get_tree().get_nodes_in_group("AudioTarget");
	if (target_nodes.size() <= 0):
		print("[GigaAudio] AudioTarget not found. Add AudioTarget Node to Player Node.");
		return;
		
	target = target_nodes[0];

func _process(delta):
	if (!target):
		return;

	var space_state = get_world_3d().direct_space_state
	var origin = global_position
	var target_pos = target.global_position

	var rays_blocked = 0
	var total_rays = extra_rays * 2 + 1  # Middle + extra rays

	for i in range(-extra_rays, extra_rays + 1):
		var offset = Vector3(0, i * vertical_offset, 0)
		var query = PhysicsRayQueryParameters3D.create(origin + offset, target_pos + offset)
		query.collide_with_areas = false
		var result = space_state.intersect_ray(query)

		if result and not result.collider.is_in_group("AudioTarget"):
			rays_blocked += 1

	# Compute occlusion percentage
	var occlusion_factor = rays_blocked / float(total_rays)
	target_volume = lerp(0.0, occlusion_db, occlusion_factor)
	target_cutoff = lerp(20000.0, cutoff_hz, occlusion_factor)

	# Smooth transitions
	volume_db = lerp(volume_db, target_volume, delta * transition_speed)
	attenuation_filter_cutoff_hz = lerp(attenuation_filter_cutoff_hz, target_cutoff, delta * transition_speed)
