# tools/test_battle_flow.gd
# Headless smoke test: opens the battle scene, presses Start Battle, prints the
# outcome and quits with a non-zero exit code on failure.
#
#   godot --headless --path <project> res://tools/test_battle_flow.tscn
extends Node

var _failed := false


func _ready() -> void:
	await get_tree().process_frame

	var packed: PackedScene = load("res://scenes/ui/battle.tscn")
	if packed == null:
		push_error("Cannot load battle scene")
		get_tree().quit(1)
		return
	var battle: Control = packed.instantiate()
	add_child(battle)
	await get_tree().process_frame

	var heroes: Array = GameManager.get_player_heroes()
	print("battle test: team size = ", heroes.size())
	if heroes.is_empty():
		push_error("player team is empty")
		_failed = true

	battle._on_start_battle()
	await get_tree().process_frame

	var result_panel: Control = battle.get_node("VBox/ResultPanel")
	var title: Label = battle.get_node("VBox/ResultPanel/VBox/ResultTitle")
	var rewards: Label = battle.get_node("VBox/ResultPanel/VBox/RewardsLabel")
	print("result panel visible = ", result_panel.visible)
	print("title = ", title.text)
	print("rewards = ", rewards.text.replace("\n", " | "))

	if not result_panel.visible:
		push_error("result panel stayed hidden after Start Battle")
		_failed = true
	if not (title.text.contains("VICTORY") or title.text.contains("DEFEAT")):
		push_error("unexpected result title: " + title.text)
		_failed = true

	# Empty-team path: clear the slots in memory (never saved) and press again.
	for slot in GameManager.get_team().get("slots", []):
		slot["hero_id"] = null
	battle._on_start_battle()
	await get_tree().process_frame
	var notice: Control = battle.no_team_box
	print("no-team notice visible = ", notice.visible)
	if not notice.visible:
		push_error("empty team should show the summon notice")
		_failed = true

	# Restore the real save so the smoke test leaves state untouched.
	GameManager.load_game()
	print("restored team size = ", GameManager.get_player_heroes().size())

	get_tree().quit(1 if _failed else 0)
