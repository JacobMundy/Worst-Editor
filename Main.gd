extends Node2D

@onready var tab_container = $TabContainer
@onready var add_tab_button = $AddTabButton 
@onready var line_counter = $LineCounter
@onready var word_counter = $WordCounter
@onready var root = get_tree().root
@onready var command_palette = $CommandPalette
@onready var command_palette_search_box = $CommandPalette/SearchPalette

var tab_number = 1

signal request_close_tab


func _ready():
	# Connect the button's signal to a method
	add_tab_button.connect("pressed", Callable(self, "_on_AddTabButton_pressed"))
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
	var tab_container_size = Vector2(window_size.x - 40, window_size.y - 30)  # Leave 30 pixels at the bottom for WordCounter
	var line_counter_size = Vector2(40, window_size.y - 30)
	var word_counter_size = Vector2(window_size.x, 30)
	var word_counter_position = Vector2(window_size.x - 400, window_size.y - 30)

	tab_container.size = tab_container_size
	line_counter.size = line_counter_size
	word_counter.size = word_counter_size
	word_counter.position = word_counter_position
	

func _on_AddTabButton_pressed():
	# Logic to add a new tab to the TabContainer
	var new_tab = TextEdit.new()
	tab_number += 1
	new_tab.name = "New "  + str(tab_number)
	line_counter.set_new_text_edit(new_tab)
	word_counter.set_new_text_edit(new_tab)
	tab_container.add_child(new_tab)
	tab_container.call_deferred("set_current_tab", tab_container.get_tab_count() - 1)  # Switch to the new tab
