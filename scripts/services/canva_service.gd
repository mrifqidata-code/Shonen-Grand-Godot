# scripts/services/canva_service.gd
extends Node
class_name CanvaService

const BACKEND_URL = "http://localhost:3000"

signal auth_status_changed(authenticated: bool)
signal design_created(design_data: Dictionary)
signal asset_uploaded(asset_data: Dictionary)
signal design_exported(export_data: Dictionary)
signal error_occurred(message: String)

var http_request: HTTPRequest

func _ready():
    http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.request_completed.connect(_on_request_completed)

func _make_request(method: String, endpoint: String, body: Dictionary = {}) -> void:
    var url = BACKEND_URL + endpoint
    var headers = ["Content-Type: application/json"]
    
    var err = OK
    match method:
        "GET":
            err = http_request.request(url, headers, HTTPClient.METHOD_GET)
        "POST":
            var json_body = JSON.stringify(body)
            err = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
    
    if err != OK:
        error_occurred.emit("Failed to make request: " + str(err))

var _pending_callback: Callable = Callable()

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
    var json_str = body.get_string_from_utf8()
    var json = JSON.new()
    var parse_err = json.parse(json_str)
    
    if parse_err != OK:
        error_occurred.emit("Failed to parse response")
        return
    
    var data = json.get_data()
    
    # Determine which callback to invoke based on pending operation
    # (simplified: emit signals based on response structure)
    if data.has("authenticated"):
        auth_status_changed.emit(data["authenticated"])
    elif data.has("design_id") or data.has("id"):
        design_created.emit(data)
    elif data.has("asset_id"):
        asset_uploaded.emit(data)
    elif data.has("downloadUrl"):
        design_exported.emit(data)
    elif data.has("error"):
        error_occurred.emit(data["error"])
    else:
        # Generic success
        design_created.emit(data)

# --- Public API ---

func check_auth_status():
    _make_request("GET", "/status")

func open_auth_url():
    OS.shell_open(BACKEND_URL + "/auth")

func create_design(title: String, width: int = 512, height: int = 512):
    _make_request("POST", "/create-design", {
        "title": title,
        "width": width,
        "height": height,
    })

func upload_asset(name: String, url: String):
    _make_request("POST", "/upload-asset", {
        "name": name,
        "url": url,
    })

func export_design(design_id: String, format: String = "png"):
    _make_request("POST", "/export-design", {
        "design_id": design_id,
        "format": format,
    })

func list_designs():
    _make_request("GET", "/designs")
