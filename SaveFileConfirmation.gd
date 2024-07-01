extends Window


@onready var yes_button = $Control/Yes
@onready var no_button = $Control/No
@onready var cancel_button = $Control/Cancel
@onready var save_label = $Control/Label

@onready var tab_container = get_node("../TabContainer")
@onready var save_file_dialog = get_node("../SaveFileDialog")
# Called when the node enters the scene tree for the first time.
func _ready():
	yes_button.connect("button_up", Callable(self, "_on_yes_button_up"))
	no_button.connect("button_up", Callable(self, "_on_no_button_up"))
	cancel_button.connect("button_up", Callable(self, "_on_cancel_button_up"))
	connect("close_requested", Callable(self, "_on_cancel_button_up"))


func _on_yes_button_up():
	self.visible = false
	save_file_dialog.current_file = tab_container.get_child(tab_container.current_tab).name
	save_file_dialog.popup_centered()

func _on_no_button_up():
	self.visible = false
	tab_container.close_file(true)

func _on_cancel_button_up():
	self.visible = false
