extends Window

@onready var search_box = $SearchPalette
@onready var command_tree = $CommandList

var command_dict = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	search_box.connect("text_changed", Callable(self, "_on_seach_box_text_changed"))
	
	# Initialize the tree columns
	command_tree.set_columns(2)
	command_tree.set_column_title(0, "Command")
	command_tree.set_column_title(1, "Key Binding")
	
	# Connect item activated signal
	command_tree.connect("item_activated", Callable(self, "_on_item_activated"))

	# Connect focus and close signals
	self.connect("close_requested", Callable(self, "close_window"))
	self.connect("focus_exited", Callable(self, "close_window"))

	# Populate all_commands dictionary and initialize the tree
	initialize_commands()

func initialize_commands():
	command_dict = {
		"CloseFile": {"name": "Close File", "binding": "Ctrl+W", "category": "File"},
		"SaveFile": {"name": "Save File", "binding": "Ctrl+S", "category": "File"},
		"OpenFile": {"name": "Open File", "binding": "Ctrl+O", "category": "File"},
		"OpenCommandPalette": {"name": "Open Command Palette", "binding": "Ctrl+Shift+P", "category": "Command"}
	}
	
	populate_tree()
	

func populate_tree():
	# Initialize Categories
	var _root = command_tree.create_item()
	command_tree.hide_root = true

	var file_category = command_tree.create_item()
	file_category.set_text(0, "File")

	var command_category = command_tree.create_item()
	command_category.set_text(0, "Command Palette")

	for command_key in command_dict.keys():
		var parent = file_category if command_dict[command_key]["category"] == "File" else command_category
		var tree_item = command_tree.create_item(parent)
		tree_item.set_text(0, command_dict[command_key]["name"])
		tree_item.set_text(1, command_dict[command_key]["binding"])

func _on_seach_box_text_changed(new_text):
	filter_commands(new_text)
	
func filter_commands(query):
	query = query.to_lower()
	command_tree.clear()
	
	# Initialize Categories 
	var _root = command_tree.create_item()
	command_tree.hide_root = true

	var file_category = command_tree.create_item()
	file_category.set_text(0, "File")

	var command_category = command_tree.create_item()
	command_category.set_text(0, "Command Palette")

	for command_key in command_dict.keys():
		var command_label = command_dict[command_key]["name"].to_lower()
		if query == "" or command_label.find(query) != -1:
			var parent = file_category if command_dict[command_key]["category"] == "File" else command_category
			var tree_item = command_tree.create_item(parent)
			tree_item.set_text(0, command_dict[command_key]["name"])
			tree_item.set_text(1, command_dict[command_key]["binding"])

func close_window():
	hide()
	search_box.clear()
