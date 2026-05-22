## sound_manager.gd - Simple audio manager (placeholder, no actual audio files needed)
extends Node

var master_bus: int
var sfx_bus: int
var music_bus: int

func _ready() -> void:
	master_bus = AudioServer.get_bus_index("Master")
	sfx_bus = AudioServer.get_bus_index("SFX") if AudioServer.get_bus_index("SFX") >= 0 else master_bus
	music_bus = AudioServer.get_bus_index("Music") if AudioServer.get_bus_index("Music") >= 0 else master_bus

func play_sfx(pitch_variation: float = 0.1) -> void:
	# Placeholder: can be extended when audio files are added
	pass

func set_volume(bus_index: int, volume_db: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, volume_db)

func mute_all(muted: bool) -> void:
	AudioServer.set_bus_mute(master_bus, muted)
