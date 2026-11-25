# tools/test_hero_dev.gd
# Headless smoke test for hero Grade (7 tiers) and Awaken: both spend the right
# materials and raise the hero's effective power / battle HP.
extends Node


func _ready() -> void:
	await get_tree().process_frame
	var failed := false
	if GameManager.heroes.is_empty():
		push_error("no heroes to test")
		get_tree().quit(1)
		return

	var hero: Dictionary = GameManager.heroes[0]
	var id := str(hero["id"])
	# Reset progression so the test is idempotent across runs.
	for i in range(GameManager.heroes.size()):
		if GameManager.heroes[i]["id"] == id:
			GameManager.heroes[i]["grade"] = 0
			GameManager.heroes[i]["awaken"] = 0
			GameManager.heroes[i]["level"] = 1
			GameManager.heroes[i]["limit_break"] = 0
	GameManager.save_game()
	var hero2 := GameManager.get_hero_by_id(id)
	var hp0 := BattleEngine.player_max_hp(hero2)
	var power0 := GameManager.hero_power(hero2)

	GameManager.progress["gold"] = 10000000
	GameManager.progress["hero_shards"] = 100000
	GameManager.progress["courage_essence"] = 100000
	GameManager.progress["soul_crystal"] = 100000

	var graded := 0
	for i in range(GameConfig.GRADE_COUNT):
		if GameManager.grade_hero(id):
			graded += 1
	print("graded %d times, grade=%d" % [graded, int(GameManager.get_hero_by_id(id).get("grade", 0))])
	if graded != GameConfig.GRADE_COUNT - 1:
		push_error("grade count mismatch")
		failed = true

	var awakened := 0
	for i in range(GameConfig.AWAKEN_MAX + 1):
		if GameManager.awaken_hero(id):
			awakened += 1
	print("awakened %d times, awaken=%d" % [awakened, int(GameManager.get_hero_by_id(id).get("awaken", 0))])
	if awakened != GameConfig.AWAKEN_MAX:
		push_error("awaken count mismatch")
		failed = true

	var hero3 = GameManager.get_hero_by_id(id)
	var hp1 := BattleEngine.player_max_hp(hero3)
	var power1 := GameManager.hero_power(hero3)
	print("power %d -> %d, battle hp %d -> %d" % [power0, power1, hp0, hp1])
	if power1 <= power0 or hp1 <= hp0:
		push_error("grade/awaken did not raise stats")
		failed = true

	# Materials must be spent, not free.
	if int(GameManager.progress["hero_shards"]) >= 100000:
		push_error("grade did not spend hero shards")
		failed = true

	print("hero dev test ", "FAILED" if failed else "OK")
	get_tree().quit(1 if failed else 0)