extends Label

@onready var default_tab = get_node("../TabContainer/New 1")
var text_edit
var connected_editors = []

# Called when the node enters the scene tree for the first time.
func _ready():
	set_new_text_edit(default_tab)

func set_new_text_edit(provided_text_edit):
	text_edit = provided_text_edit
	if text_edit not in connected_editors:
		text_edit.connect("caret_changed", Callable(self, "update_line_count"))
		connected_editors.append(text_edit)
	update_line_count()

func update_line_count():
	var string_list = ""
	var line_count = text_edit.get_line_count()
	for i in range(0, line_count):
		string_list += str(i + 1) + "\n"
	self.set_text(string_list)
