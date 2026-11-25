# scripts/autoload/theme_manager.gd
# Global dark-fantasy theme so every screen shares the Twilight-Chronicle-like
# look (dark panels, gold accents) without editing each scene by hand.
extends Node

func _ready() -> void:
	var theme := Theme.new()

	var gold := Color("c9a227")
	var gold_dim := Color("8a6f1a")
	var panel_bg := Color("12151f")
	var panel_border := Color("3a3f5c")
	var btn_bg := Color("1a1f2e")
	var btn_hover := Color("252b3d")
	var btn_pressed := Color("0f1219")
	var text := Color("e8e6e3")
	var text_dim := Color("a0a3ad")

	# ---- Button -----------------------------------------------------------
	var btn_normal := StyleBoxFlat.new()
	btn_normal.bg_color = btn_bg
	btn_normal.border_color = gold_dim
	btn_normal.set_border_width_all(1)
	btn_normal.set_corner_radius_all(8)
	btn_normal.set_content_margin_all(10)
	var btn_h := btn_normal.duplicate()
	btn_h.bg_color = btn_hover
	btn_h.border_color = gold
	var btn_p := btn_normal.duplicate()
	btn_p.bg_color = btn_pressed
	var btn_d := btn_normal.duplicate()
	btn_d.bg_color = Color("0e1118")
	btn_d.border_color = Color("2a2d3a")
	theme.set_stylebox("normal", "Button", btn_normal)
	theme.set_stylebox("hover", "Button", btn_h)
	theme.set_stylebox("pressed", "Button", btn_p)
	theme.set_stylebox("disabled", "Button", btn_d)
	theme.set_color("font_color", "Button", text)
	theme.set_color("font_hover_color", "Button", Color("ffffff"))
	theme.set_color("font_pressed_color", "Button", text_dim)
	theme.set_color("font_disabled_color", "Button", Color("5a5d6a"))
	theme.set_constant("outline_size", "Button", 0)

	# ---- PanelContainer ---------------------------------------------------
	var panel := StyleBoxFlat.new()
	panel.bg_color = panel_bg
	panel.border_color = panel_border
	panel.set_border_width_all(1)
	panel.set_corner_radius_all(10)
	panel.set_content_margin_all(12)
	theme.set_stylebox("panel", "PanelContainer", panel)

	# ---- Label -----------------------------------------------------------
	theme.set_color("font_color", "Label", text)

	# ---- LineEdit / SpinBox ----------------------------------------------
	var le := StyleBoxFlat.new()
	le.bg_color = Color("0a0c14")
	le.border_color = gold_dim
	le.set_border_width_all(1)
	le.set_corner_radius_all(6)
	le.set_content_margin_all(6)
	theme.set_stylebox("normal", "LineEdit", le)
	theme.set_stylebox("focus", "LineEdit", le.duplicate())
	theme.set_color("font_color", "LineEdit", text)
	theme.set_color("font_placeholder_color", "LineEdit", text_dim)

	# ---- ProgressBar -----------------------------------------------------
	var pb_bg := StyleBoxFlat.new()
	pb_bg.bg_color = Color("0a0c14")
	pb_bg.set_corner_radius_all(4)
	var pb_fill := StyleBoxFlat.new()
	pb_fill.bg_color = gold
	pb_fill.set_corner_radius_all(4)
	theme.set_stylebox("background", "ProgressBar", pb_bg)
	theme.set_stylebox("fill", "ProgressBar", pb_fill)

	# ---- ScrollContainer -------------------------------------------------
	theme.set_constant("v_scroll_bar_policy", "ScrollContainer", 1)

	get_tree().root.theme = theme
