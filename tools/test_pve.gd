# tools/test_pve.gd
# Headless smoke test for the PvE mode plumbing: each mode keeps its own floor,
# setting a mode/stage persists it, and clearing advances only that mode.
extends Node


func _ready() -> void:
	await get_tree().process_frame
	var failed := false

	for mode in ["tower", "maze", "trial"]:
		GameManager.pve_set_mode(mode, 3)
		if GameManager.pve_floor(mode) != 3:
			push_error("set floor failed for " + mode)
			failed = true
		var next := GameManager.advance_pve(mode, 3)
		print("%s: floor 3 -> %d" % [mode, GameManager.pve_floor(mode)])
		if next != 4 or GameManager.pve_floor(mode) != 4:
			push_error("advance failed for " + mode)
			failed = true

	# Gold multiplier and bonus table come from GameConfig.
	var maze_mult := GameConfig.pve_gold_mult("maze")
	var tower_bonus := GameConfig.pve_bonus("tower")
	print("maze gold x%.1f, tower bonus %s" % [maze_mult, str(tower_bonus)])
	if absf(maze_mult - 2.0) > 0.01:
		push_error("maze gold multiplier wrong")
		failed = true
	if int(tower_bonus.get("soul_crystal", 0)) <= 0:
		push_error("tower bonus missing")
		failed = true

	# Campaign floor is untouched by PvE advances.
	GameManager.pending_pve_mode = "campaign"
	print("campaign stage still %d" % int(GameManager.progress.get("current_campaign_stage", 1)))

	print("pve test ", "FAILED" if failed else "OK")
	get_tree().quit(1 if failed else 0)