# scripts/services/canva_downloader.gd
extends Node
class_name CanvaDownloader

signal download_completed(file_path: String, success: bool)
signal download_progress(percent: float)

var http_request: HTTPRequest
var download_url: String = ""
var save_path: String = ""

func _ready():
    http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.request_completed.connect(_on_download_completed)

func download_file(url: String, save_to: String) -> void:
    download_url = url
    save_path = save_to
    
    # Ensure directory exists
    var dir = DirAccess.open("user://")
    if dir:
        dir.make_dir_recursive(save_to.get_base_dir().replace("user://", ""))
    
    var err = http_request.request(url)
    if err != OK:
        download_completed.emit("", false)
        push_error("Download request failed: " + str(err))

func _on_download_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
    if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
        download_completed.emit("", false)
        push_error("Download failed: result=%d, code=%d" % [result, response_code])
        return
    
    # Determine file extension from content-type or URL
    var ext = ".png"
    for h in headers:
        if h.to_lower().begins_with("content-type:"):
            var ct = h.to_lower()
            if "jpeg" in ct or "jpg" in ct:
                ext = ".jpg"
            elif "webp" in ct:
                ext = ".webp"
            elif "gif" in ct:
                ext = ".gif"
            break
    
    # If save_path has no extension, add one
    if not save_path.ends_with(ext) and not save_path.contains("."):
        save_path += ext
    
    # Save file
    var file = FileAccess.open(save_path, FileAccess.WRITE)
    if file:
        file.store_buffer(body)
        file.close()
        download_completed.emit(save_path, true)
        print("Downloaded: " + save_path + " (" + str(body.size()) + " bytes)")
    else:
        download_completed.emit("", false)
        push_error("Failed to save file: " + save_path)

func get_save_directory() -> String:
    return "user://assets/sprites/heroes/"

func ensure_directory(path: String) -> void:
    var dir = DirAccess.open("user://")
    if dir:
        var relative = path.replace("user://", "")
        dir.make_dir_recursive(relative)
