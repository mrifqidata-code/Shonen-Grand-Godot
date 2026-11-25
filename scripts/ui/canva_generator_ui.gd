# scripts/ui/canva_generator_ui.gd
extends Control

@onready var auth_label = $VBox/AuthPanel/VBox/AuthLabel
@onready var auth_btn = $VBox/AuthPanel/VBox/AuthBtn
@onready var check_btn = $VBox/AuthPanel/VBox/CheckBtn
@onready var name_input = $VBox/GeneratePanel/VBox/NameInput
@onready var width_input = $VBox/GeneratePanel/VBox/SizeRow/WidthInput
@onready var height_input = $VBox/GeneratePanel/VBox/SizeRow/HeightInput
@onready var create_btn = $VBox/GeneratePanel/VBox/CreateBtn
@onready var export_btn = $VBox/GeneratePanel/VBox/ExportBtn
@onready var log_label = $VBox/LogLabel

var canva_service: CanvaService
var canva_downloader: CanvaDownloader
var current_design_id: String = ""
var last_download_path: String = ""

func _ready():
    $VBox/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
    
    canva_service = CanvaService.new()
    add_child(canva_service)
    canva_service.auth_status_changed.connect(_on_auth_status)
    canva_service.design_created.connect(_on_design_created)
    canva_service.design_exported.connect(_on_design_exported)
    canva_service.error_occurred.connect(_on_error)
    
    canva_downloader = CanvaDownloader.new()
    add_child(canva_downloader)
    canva_downloader.download_completed.connect(_on_download_completed)
    
    auth_btn.pressed.connect(func(): canva_service.open_auth_url())
    check_btn.pressed.connect(func(): canva_service.check_auth_status())
    create_btn.pressed.connect(_on_create_design)
    export_btn.pressed.connect(_on_export_design)
    
    log_line("Ready. Connect Canva first.")

func log_line(msg: String):
    log_label.text = "Log: " + msg

func _on_auth_status(authenticated: bool):
    if authenticated:
        auth_label.text = "Status: ✅ Connected"
        log_line("Canva connected!")
    else:
        auth_label.text = "Status: ❌ Not connected"
        log_line("Not connected. Click Connect Canva.")

func _on_create_design():
    var title = name_input.text.strip_edges()
    if title.is_empty():
        title = "Shonen Grand Asset"
    var w = int(width_input.value)
    var h = int(height_input.value)
    log_line("Creating design: %s (%dx%d)..." % [title, w, h])
    canva_service.create_design(title, w, h)

func _on_design_created(data: Dictionary):
    if data.has("design_id"):
        current_design_id = data["design_id"]
    elif data.has("id"):
        current_design_id = data["id"]
    log_line("Design created: " + current_design_id)
    export_btn.disabled = false

func _on_export_design():
    if current_design_id.is_empty():
        log_line("No design to export. Create one first.")
        return
    log_line("Exporting design...")
    canva_service.export_design(current_design_id, "png")

func _on_design_exported(data: Dictionary):
    if data.has("downloadUrl"):
        var url = data["downloadUrl"]
        log_line("Exported! Downloading...")
        var asset_name = name_input.text.strip_edges()
        if asset_name.is_empty():
            asset_name = "asset"
        # Sanitize filename
        asset_name = asset_name.to_lower().replace(" ", "_")
        var save_path = canva_downloader.get_save_directory() + asset_name
        canva_downloader.download_file(url, save_path)
    else:
        log_line("Export complete. Check Canva.")

func _on_download_completed(file_path: String, success: bool):
    if success:
        last_download_path = file_path
        log_line("✅ Downloaded: " + file_path)
        
        # Park the download in art_inbox/ (editor only). The batch script then
        # resizes it and copies it to assets/sprites/heroes/<hero_id>/<style>.png
        if Engine.is_editor_hint():
            var importer = AssetImporter.new()
            add_child(importer)
            importer.import_completed.connect(func(src, dst, ok):
                if ok:
                    log_line("✅ Masuk art_inbox: " + dst + " → jalankan tools/import_canva_art.ps1")
                else:
                    log_line("⚠️ Import gagal (jalankan dari Editor)")
            )
            importer.import_file(file_path, "art_inbox/")
        else:
            log_line("Rename file ke <hero_id>.png lalu jalankan tools/import_canva_art.ps1")
        
        # Open file location
        if OS.get_name() == "Windows":
            OS.shell_open(file_path.get_base_dir())
    else:
        log_line("❌ Download failed")

func _on_error(msg: String):
    log_line("Error: " + msg)
