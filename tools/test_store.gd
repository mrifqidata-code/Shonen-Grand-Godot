# tools/test_store.gd
# Headless smoke test: buying a good spends the right currency and grants the
# reward, and the daily reward can only be claimed once per day.
extends Node


func _ready() -> void:
	await get_tree().process_frame
	var scene: Control = load("res://scenes/ui/store.tscn").instantiate()
	add_child(scene)
	await get_tree().process_frame

	var failed := false

	# Buy the first Gold-tab good.
	var item: Dictionary = GameConfig.STORE_GOODS["gold"][0]
	var key := str(item["cost_key"])
	var grant_key := str(item["grant"].keys()[0])
	GameManager.progress[key] = int(GameManager.progress.get(key, 0)) + int(item["cost"]) + 100
	GameManager.progress[grant_key] = int(GameManager.progress.get(grant_key, 0))
	var before_currency := int(GameManager.progress.get(key, 0))
	var before_grant := int(GameManager.progress.get(grant_key, 0))
	scene._on_buy(item)
	var spent := before_currency - int(GameManager.progress.get(key, 0))
	var gained := int(GameManager.progress.get(grant_key, 0)) - before_grant
	print("buy %s: spent %d %s, gained %d %s" % [item["name"], spent, key, gained, grant_key])
	if spent != int(item["cost"]) or gained <= 0:
		push_error("store buy failed")
		failed = true

	# Daily reward is once per day.
	GameManager.progress["last_daily_date"] = ""
	var first: bool = GameManager.claim_daily()
	var second: bool = GameManager.claim_daily()
	print("daily: first=%s second=%s" % [first, second])
	if not first or second:
		push_error("daily claim logic failed")
		failed = true

	# Exchange grants a hero.
	var ex: Dictionary = GameConfig.STORE_GOODS["exchange"][0]
	GameManager.progress["hero_shards"] = int(ex["cost"]) + 10
	var heroes_before: int = GameManager.heroes.size()
	scene._on_buy(ex)
	var heroes_after: int = GameManager.heroes.size()
	print("exchange: heroes +%d" % (heroes_after - heroes_before))
	if heroes_after != heroes_before + 1:
		push_error("exchange hero grant failed")
		failed = true

	print("store test ", "FAILED" if failed else "OK")
	get_tree().quit(1 if failed else 0)
