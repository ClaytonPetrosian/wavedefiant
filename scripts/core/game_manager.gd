## GameManager.gd - Global game state manager (autoload singleton)
## Handles game state, player stats, score tracking, and scene transitions.
extends Node

# --- Game States ---
enum GameState { MENU, PLAYING, PAUSED, LEVEL_UP, GAME_OVER, UPGRADE_SELECT }

var current_state: GameState = GameState.MENU

# --- Persistent Stats ---
var high_score: int = 0
var total_waves_cleared: int = 0
var games_played: int = 0

# --- Current Run ---
var current_score: int = 0
var current_wave: int = 0
var current_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 10

# --- Signals ---
signal state_changed(new_state: GameState)
signal score_updated(new_score: int)
signal wave_changed(new_wave: int)
signal level_up_triggered(level: int)
signal game_over_triggered(final_score: int, final_wave: int)

func _ready() -> void:
	_load_save_data()

func change_state(new_state: GameState) -> void:
	current_state = new_state
	state_changed.emit(new_state)
	get_tree().paused = (new_state == GameState.PAUSED or new_state == GameState.LEVEL_UP or new_state == GameState.UPGRADE_SELECT)

func add_score(amount: int) -> void:
	current_score += amount
	score_updated.emit(current_score)

func add_wave() -> void:
	current_wave += 1
	wave_changed.emit(current_wave)

func add_xp(amount: int) -> void:
	current_xp += amount
	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		current_level += 1
		xp_to_next_level = int(xp_to_next_level * 1.4)
		level_up_triggered.emit(current_level)
		change_state(GameState.LEVEL_UP)

func trigger_game_over() -> void:
	if current_score > high_score:
		high_score = current_score
	games_played += 1
	if current_wave > total_waves_cleared:
		total_waves_cleared = current_wave
	_save_data()
	game_over_triggered.emit(current_score, current_wave)
	change_state(GameState.GAME_OVER)

func reset_run() -> void:
	current_score = 0
	current_wave = 0
	current_level = 1
	current_xp = 0
	xp_to_next_level = 10
	score_updated.emit(0)
	wave_changed.emit(0)

# --- Save/Load ---
func _load_save_data() -> void:
	var save_file = FileAccess.open("user://save_data.json", FileAccess.READ)
	if save_file:
		var json = JSON.parse_string(save_file.get_as_text())
		save_file.close()
		if json:
			high_score = json.get("high_score", 0)
			total_waves_cleared = json.get("total_waves_cleared", 0)
			games_played = json.get("games_played", 0)

func _save_data() -> void:
	var save_file = FileAccess.open("user://save_data.json", FileAccess.WRITE)
	if save_file:
		var data = {
			"high_score": high_score,
			"total_waves_cleared": total_waves_cleared,
			"games_played": games_played
		}
		save_file.store_string(JSON.stringify(data, "\t"))
		save_file.close()
