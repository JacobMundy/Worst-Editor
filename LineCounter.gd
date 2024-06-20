extends TextEdit

@onready var default_tab = get_node("../TabContainer/New 1")
var text_edit
var connected_editors = []

@onready var label_scroll_container = get_parent()
var last_self_scroll = -1
var last_text_edit_scroll = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	set_new_text_edit(default_tab)
	self.add_theme_constant_override("line_spacing", 4)
	self.get_v_scroll_bar().modulate = 0

func _process(delta):
	if text_edit != null:
		# Sync the scroll position of LineCounter with text_edit
		if text_edit.scroll_vertical != last_text_edit_scroll:
			self.scroll_vertical = text_edit.scroll_vertical
			last_text_edit_scroll = text_edit.scroll_vertical

		# Sync the scroll position of text_edit with LineCounter
		if self.scroll_vertical != last_self_scroll:
			text_edit.scroll_vertical = self.scroll_vertical
			last_self_scroll = self.scroll_vertical

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
	self.scroll_vertical = text_edit.scroll_vertical
	
