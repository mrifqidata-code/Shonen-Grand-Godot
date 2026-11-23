# scripts/autoload/scene_manager.gd
extends Node

var current_scene: Node = null
var scene_cache: Dictionary = {}

func _ready():
    var root = get_tree().root
    current_scene = root.get_child(root.get_child_count() - 1)

func change_scene(scene_path: String):
    if current_scene:
        current_scene.queue_free()
    var new_scene = load(scene_path).instantiate()
    get_tree().root.call_deferred("add_child", new_scene)
    current_scene = new_scene

func change_scene_with_transition(scene_path: String):
    # Simple fade transition
    var tween = create_tween()
    tween.tween_property(current_scene, "modulate:a", 0.0, 0.3)
    tween.tween_callback(func():
        change_scene(scene_path)
        if current_scene:
            current_scene.modulate.a = 0.0
            var t2 = create_tween()
            t2.tween_property(current_scene, "modulate:a", 1.0, 0.3)
    )
