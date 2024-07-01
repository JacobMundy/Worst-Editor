extends Node2D

@onready var tab_container = $TabContainer
@onready var word_counter = $WordCounter
@onready var root = get_tree().root
@onready var command_palette = $CommandPalette
@onready var command_palette_search_box = $CommandPalette/SearchPalette

var tab_number = 1

signal request_close_tab


func _ready():
	root.connect("size_changed", Callable(self,"_on_window_resized"))
	_on_window_resized()

func _input(event):
	if Input.is_key_pressed(KEY_CTRL):
		if event.is_action_released("command_palette") and Input.is_key_pressed(KEY_SHIFT):
			if not command_palette.visible:
				command_palette.popup_centered()
				command_palette_search_box.grab_focus()
			else:
				command_palette.visible = false

func _on_window_resized():
	var window_size = root.size
	var tab_container_size = Vector2(window_size.x, window_size.y - 70)  # Leave 30 pixels at the bottom for WordCounter
	var word_counter_size = Vector2(window_size.x, 30)
	var word_counter_position = Vector2(window_size.x - 400, window_size.y - 30)

	tab_container.size = tab_container_size
	word_counter.size = word_counter_size
	word_counter.position = word_counter_position
