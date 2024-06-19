extends Node2D

@onready var tab_container = $TabContainer
@onready var add_tab_button = $AddTabButton 
@onready var line_counter = $LineCounter

var tab_number = 1

signal request_close_tab


func _ready():
	# Connect the button's signal to a method
	add_tab_button.connect("pressed", Callable(self, "_on_AddTabButton_pressed"))

func _on_AddTabButton_pressed():
	# Logic to add a new tab to the TabContainer
	var new_tab = TextEdit.new()
	tab_number += 1
	new_tab.name = "New "  + str(tab_number)
	line_counter.set_new_text_edit(new_tab)
	tab_container.add_child(new_tab)
	tab_container.call_deferred("set_current_tab", tab_container.get_tab_count() - 1)  # Switch to the new tab
