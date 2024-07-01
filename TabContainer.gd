extends TabContainer

@onready var main = get_node("..")
@onready var popup_window = get_node("../ChangeFileNameWindow")
@onready var popup_control = get_node("../ChangeFileNameWindow/PopupControl")
@onready var word_counter = get_node("../WordCounter")
@onready var save_file_dialog = get_node("../SaveFileDialog")
@onready var open_file_dialog = get_node("../OpenFileDialog")
@onready var command_palette = get_node("../CommandPalette")
@onready var file_button_menu = get_node("../FileMenuButton")
@onready var save_file_confirmation = get_node("../SaveFileConfirmation")

# TODO: make sure user cant call tab same name 
# TODO: show error dialogs to user if something like above occurs.
var last_time_clicked = 0
var double_click_threshold = 0.15
var directories = {}
var open_tabs = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	drag_to_rearrange_enabled = true
	connect("tab_clicked", Callable(self, "_on_tab_clicked"))
	connect("tab_changed", Callable(self, "_on_tab_change"))
	save_file_dialog.connect("file_selected", Callable(self, "_on_file_selected"))
	open_file_dialog.connect("file_selected", Callable(self, "load_file"))
	file_button_menu.get_popup().connect("id_pressed", Callable(self, "_on_file_menu_item_pressed"))
	load_state()

# Detect one of the possible file commands
func _input(event):
	if Input.is_key_pressed(KEY_CTRL):
		if event.is_action_released("close_current_tab") and len(self.get_children()) > 0:
			close_file()
		elif event.is_action_released("save_file"):
			var selected_tab = self.get_child(current_tab)
			var file_path = selected_tab.name
			if file_path in directories and FileAccess.file_exists(directories[file_path]):
				save_file(directories[file_path])
			else:
				# Open the FileDialog for the user to select a save location
				save_file_dialog.set_mode(FileDialog.FILE_MODE_SAVE_FILE)
				save_file_dialog.current_file = selected_tab.name
				save_file_dialog.popup_centered()
		elif event.is_action_released("open_file"):
			open_file_dialog.popup_centered()

# Adds function to buttons on File Menu Dropdown
func _on_file_menu_item_pressed(id):
	match id:
		0:  
			_on_file_menu_new_pressed()
		1:  
			_on_file_menu_open_pressed()
		2:  
			_on_file_menu_save_pressed()
		3: 
			close_file()

func _on_file_menu_new_pressed():
	# Logic to add a new tab
	var new_tab = CodeEdit.new()
	main.tab_number += 1
	new_tab.name = "New " + str(main.tab_number)
	word_counter.set_new_text_edit(new_tab)
	add_child(new_tab)
	call_deferred("set_current_tab", get_tab_count() - 1)  # Switch to the new tab

func _on_file_menu_open_pressed():
	open_file_dialog.popup_centered()

func _on_file_menu_save_pressed():
	var selected_tab = get_child(current_tab)
	var file_path = selected_tab.name
	if file_path in directories and FileAccess.file_exists(directories[file_path]):
		save_file(directories[file_path])
	else:
		# Open the FileDialog for the user to select a save location
		save_file_dialog.set_mode(FileDialog.FILE_MODE_SAVE_FILE)
		save_file_dialog.current_file = selected_tab.name + ".txt"
		save_file_dialog.popup_centered()

# Detect close and try to save state
func _notification(what):
	if what == 1006:
		save_state()

# Saves state to static file location 
func save_state():
	var state = {
		"tabs" = {},
		"stored_directories" = {}
	}
	state["stored_directories"] = directories
	
	for i in range(self.get_child_count()):
		print(self.get_child(i).name)
		state["tabs"][self.get_child(i).name] = self.get_child(i).text
	
	var saved_state = FileAccess.open("user://tabs_state.json", FileAccess.ModeFlags.WRITE)
	if saved_state:
		saved_state.store_string(JSON.stringify(state))
		saved_state.close()
		print("file saved")

# Loads saved state from static file location
func load_state():
	var saved_state = FileAccess.open("user://tabs_state.json", FileAccess.ModeFlags.READ)
	if saved_state:
		# Load in Data from file
		var state = JSON.parse_string(saved_state.get_as_text())
		directories = state["stored_directories"]
		
		main.tab_number = len(state["tabs"])
		# Remove the default editor if there are saved tabs 
		if len(state["tabs"]) > 0:
			if "New 1" not in state["tabs"]:
				self.get_child(0).queue_free()


		# Load in the saved tabs
		for tab in state["tabs"]:
			if tab == "New 1":
				self.get_child(0).text = state["tabs"][tab]
				continue 
				
			# Create CodeEdits and change their settings
			# TODO: allow user to change settings like line-number
			# TODO: save these settings in JSON and implement them here and other places
			var text_editor = CodeEdit.new()
			text_editor.gutters_draw_line_numbers = true
			text_editor.name = tab
			text_editor.text = state["tabs"][tab]
			self.add_child(text_editor)
		
		print("saved state loaded")

func load_file(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		# Create and setup new CodeEdit
		var text_editor = CodeEdit.new()
		text_editor.name = path.get_file().get_basename()
		text_editor.text = file.get_as_text()
		
		# Set the created CodeEdit as first tab and focus it 
		self.add_child(text_editor)
		self.move_child(text_editor, 0)
		self.set_current_tab(0)

func close_file(skip_confirmation = false):
	var selected_file = self.get_child(current_tab)
	if skip_confirmation:
		selected_file.queue_free()
	elif len(self.get_children()) > 0:
		if selected_file.name in directories:
			save_file(directories[selected_file.name])
		elif len(selected_file.text) > 0:
			save_file_confirmation.popup_centered()
		else:
			selected_file.queue_free()

func _on_file_selected(path):
	save_file(path)

func save_file(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		
		var text_editor = self.get_child(current_tab)
		file.store_string(text_editor.text)
		file.close()
		
		set_tab_name(path.get_file().get_basename())
		directories[path.get_file().get_basename()] = path
		print(directories)
	else:
		print("Failed to save the file.")

func set_tab_name(new_name):
	var selected_tab = self.get_child(current_tab)
	var old_name = selected_tab.name
	
	
	# Update the directories dictionary
	if old_name in directories:
		var old_path = directories[old_name]
		var new_path = old_path.get_base_dir().path_join(new_name + "." + old_path.get_extension())

		# Attempt to rename the file
		var dir = DirAccess.open(old_path.get_base_dir())
		if dir:
			var err = dir.rename(old_path, new_path)
			if err == OK:
				# File renamed successfully
				directories[new_name] = new_path
				directories.erase(old_name)
				selected_tab.name = new_name
				set_tab_title(current_tab, new_name)
			else:
				# Failed to rename file
				print("Failed to rename file: ", error_string(err))
				return
		else:
			print("Unable to access directory")
			return
	else:
		# This tab isn't associated with a file yet, just update the tab
		selected_tab.name = new_name
		set_tab_title(current_tab, new_name)

func _on_tab_change(tab_index):
	var text_edit = get_child(tab_index)
	word_counter.set_new_text_edit(text_edit)
	word_counter.force_update_ui()

func _on_tab_clicked(tab_index):
	
	# Logic for title change 
	var now = Time.get_ticks_msec() / 1000.0  # Current time in seconds
	if now - last_time_clicked < double_click_threshold:
		popup_window.visible = true
		popup_control.set_idx(tab_index)
		popup_control.set_input_text(self.get_tab_title(tab_index))
	last_time_clicked = now


