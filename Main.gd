extends Node2D

@onready var tab_container = $TabContainer
@onready var add_tab_button = $AddTabButton 
@onready var line_counter = $LineCounter
@onready var root = get_tree().root

var tab_number = 1

signal request_close_tab


func _ready():
	# Connect the button's signal to a method
	add_tab_button.connect("pressed", Callable(self, "_on_AddTabButton_pressed"))
	root.connect("size_changed", Callable(self,"_on_window_resized"))


func _on_window_resized():
	var tab_container_size = Vector2(root.size.x - 40, root.size.y)
	var line_counter_size = Vector2(40, root.size.y)
	tab_container.size = tab_container_size
	line_counter.size = line_counter_size
	

func _on_AddTabButton_pressed():
	# Logic to add a new tab to the TabContainer
	var new_tab = TextEdit.new()
	tab_number += 1
	new_tab.name = "New "  + str(tab_number)
	line_counter.set_new_text_edit(new_tab)
	tab_container.add_child(new_tab)
	tab_container.call_deferred("set_current_tab", tab_container.get_tab_count() - 1)  # Switch to the new tab
