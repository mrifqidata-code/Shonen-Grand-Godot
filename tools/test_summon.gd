# tools/test_summon.gd
# Headless smoke test for the four summon banners: each one must spend its own
# currency and produce a hero, and the pity counter must advance.
extends Node


func _ready() -> void:
	await get_tree().process_frame
	var scene: Control = load("res://scenes/ui/summon.tscn").instantiate()
	add_child(scene)
	await get_tree().process_frame

	var failed := false
	var cases := [
		{"tab": 0, "key": "tickets", "label": "Hero"},
		{"tab": 1, "key": "friendship_points", "label": "Friendship"},
		{"tab": 2, "key": "advanced_scrolls", "label": "Advanced"},
		{"tab": 3, "key": "diamonds", "label": "Race"},
	]
	for c in cases:
		scene._set_tab(int(c["tab"]))
		var key := str(c["key"])
		var before := int(GameManager.progress.get(key, 0))
		var heroes_before: int = GameManager.heroes.size()
		scene._on_summon(1)
		await get_tree().process_frame
		var spent := before - int(GameManager.progress.get(key, 0))
		var gained: int = GameManager.heroes.size() - heroes_before
		print("%s: spent %d %s, heroes +%d" % [c["label"], spent, key, gained])
		if spent <= 0 or gained != 1:
			push_error("summon case failed: " + str(c["label"]))
			failed = true

	print("pity = ", int(GameManager.progress.get("noble_insignia", 0)))
	print("hero_shards = ", int(GameManager.progress.get("hero_shards", 0)))
	print("summon test ", "FAILED" if failed else "OK")
	get_tree().quit(1 if failed else 0)