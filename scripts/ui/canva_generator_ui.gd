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
var current_design_id: String = ""

func _ready():
    $VBox/BackBtn.pressed.connect(func(): SceneManager.change_scene("res://scenes/main.tscn"))
    
    canva_service = CanvaService.new()
    add_child(canva_service)
    canva_service.auth_status_changed.connect(_on_auth_status)
    canva_service.design_created.connect(_on_design_created)
    canva_service.design_exported.connect(_on_design_exported)
    canva_service.error_occurred.connect(_on_error)
    
    auth_btn.pressed.connect(func(): canva_service.open_auth_url())
    check_btn.pressed.connect(func(): canva_service.check_auth_status())
    create_btn.pressed.connect(_on_create_design)
    export_btn.pressed.connect(_on_export_design)
    
    log("Ready. Connect Canva first.")

func log(msg: String):
    log_label.text = "Log: " + msg

func _on_auth_status(authenticated: bool):
    if authenticated:
        auth_label.text = "Status: ✅ Connected"
        log("Canva connected!")
    else:
        auth_label.text = "Status: ❌ Not connected"
        log("Not connected. Click Connect Canva.")

func _on_create_design():
    var title = name_input.text.strip_edges()
    if title.is_empty():
        title = "Shonen Grand Asset"
    var w = int(width_input.value)
    var h = int(height_input.value)
    log("Creating design: %s (%dx%d)..." % [title, w, h])
    canva_service.create_design(title, w, h)

func _on_design_created(data: Dictionary):
    if data.has("design_id"):
        current_design_id = data["design_id"]
    elif data.has("id"):
        current_design_id = data["id"]
    log("Design created: " + current_design_id)
    export_btn.disabled = false

func _on_export_design():
    if current_design_id.is_empty():
        log("No design to export. Create one first.")
        return
    log("Exporting design...")
    canva_service.export_design(current_design_id, "png")

func _on_design_exported(data: Dictionary):
    if data.has("downloadUrl"):
        log("Exported! Download: " + data["downloadUrl"])
        OS.shell_open(data["downloadUrl"])
    else:
        log("Export complete. Check Canva.")

func _on_error(msg: String):
    log("Error: " + msg)
