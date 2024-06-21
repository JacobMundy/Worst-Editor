extends RichTextLabel

@onready var default_tab = get_node("../TabContainer/New 1")
var text_edit
var connected_editors = []

@onready var label_scroll_container = get_parent()
var last_self_scroll = -1
var last_text_edit_scroll = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	set_new_text_edit(default_tab)
	self.scroll_active = false
	self.add_theme_constant_override("line_separation", 4)


func set_new_text_edit(provided_text_edit):
	text_edit = provided_text_edit
	if text_edit not in connected_editors:
		var scroll_bar = text_edit.get_v_scroll_bar()
		text_edit.connect("caret_changed", Callable(self, "update_line_count"))
		scroll_bar.connect("value_changed", Callable(self, "update_line_count"))
		print(scroll_bar)
		connected_editors.append(text_edit)
	update_line_count()


func update_line_count(_value = -1):
	var string_list = ""
	var line_count = text_edit.get_line_count()
	string_list = "[right]"
	for i in range(0, line_count):
		string_list += str(i + 1) + "\n"
	string_list += "\n[/right]"
	self.set_text(string_list)
	self.scroll_to_line(text_edit.scroll_vertical)

