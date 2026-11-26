# tools/test_decompose.gd
extends Node


func _ready() -> void:
	await get_tree().process_frame
	var failed := false
	# Seed a spare R hero.
	var tpl := HeroesData.get_template_by_id("sakura")
	if tpl.is_empty():
		push_error("template missing"); get_tree().quit(1); return
	var h = HeroesData.create_hero_from_template(tpl)
	h["rarity"] = "R"
	GameManager.add_hero(h)
	var shards_before := int(GameManager.progress.get("hero_shards", 0))
	var removed := GameManager.decompose_heroes("R")
	print("decomposed %d R heroes, shards +%d" % [removed, int(GameManager.progress.get("hero_shards", 0)) - shards_before])
	if removed < 1:
		push_error("decompose removed none"); failed = true

	# Material conversion.
	GameManager.progress["courage_essence"] = 25
	var ok := GameManager.convert_material("courage_essence", 10)
	print("convert 10 courage: %s" % ok)
	if not ok:
		push_error("convert failed"); failed = true

	# Daily market.
	var goods := GameManager.market_goods()
	print("market goods: %d" % goods.size())
	if goods.size() != GameConfig.DAILY_MARKET_SIZE:
		push_error("market size wrong"); failed = true
	var bought_before := int(GameManager.progress.get("hero_shards", 0))
	var good_ok := GameManager.buy_market_good(0)
	print("buy market good 0: %s" % good_ok)
	if not good_ok:
		push_error("market buy failed"); failed = true
	# second buy same index fails
	if GameManager.buy_market_good(0):
		push_error("double buy allowed"); failed = true

	print("decompose test ", "FAILED" if failed else "OK")
	get_tree().quit(1 if failed else 0)