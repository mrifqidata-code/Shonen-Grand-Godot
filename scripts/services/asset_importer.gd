# scripts/services/asset_importer.gd
@tool
extends Node
class_name AssetImporter

signal import_completed(source: String, destination: String, success: bool)

func import_file(source_path: String, dest_relative: String = "assets/sprites/heroes/") -> void:
    # Check if running in editor
    if not Engine.is_editor_hint():
        push_warning("AssetImporter only works in editor mode")
        import_completed.emit(source_path, "", false)
        return
    
    var dest_dir = "res://" + dest_relative
    var file_name = source_path.get_file()
    var dest_path = dest_dir + file_name
    
    # Ensure destination directory exists
    var dir = DirAccess.open("res://")
    if dir:
        dir.make_dir_recursive(dest_relative)
    
    # Copy file
    var src_file = FileAccess.open(source_path, FileAccess.READ)
    if not src_file:
        push_error("Cannot open source: " + source_path)
        import_completed.emit(source_path, dest_path, false)
        return
    
    var buffer = src_file.get_buffer(src_file.get_length())
    src_file.close()
    
    var dst_file = FileAccess.open(dest_path, FileAccess.WRITE)
    if dst_file:
        dst_file.store_buffer(buffer)
        dst_file.close()
        import_completed.emit(source_path, dest_path, true)
        print("Imported: " + source_path + " → " + dest_path)
    else:
        push_error("Cannot write to: " + dest_path)
        import_completed.emit(source_path, dest_path, false)

func import_from_user(source_filename: String, dest_relative: String = "assets/sprites/heroes/") -> void:
    var source_path = "user://assets/sprites/heroes/" + source_filename
    import_file(source_path, dest_relative)

func get_user_asset_path(filename: String) -> String:
    return "user://assets/sprites/heroes/" + filename

func list_user_assets() -> Array:
    var result = []
    var dir = DirAccess.open("user://assets/sprites/heroes/")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if not dir.current_is_dir() and (file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".webp")):
                result.append(file_name)
            file_name = dir.get_next()
        dir.list_dir_end()
    return result
