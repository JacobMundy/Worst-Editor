extends RichTextLabel

@onready var default_tab = get_node("../TabContainer/New 1")
var text_edit
var connected_editors = []
var regex_word_count = RegEx.new()
var regex_character_count = RegEx.new()

@onready var label_scroll_container = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	set_new_text_edit(default_tab)
	self.scroll_active = false
	regex_word_count.compile("[\\w-]+")
	regex_character_count.compile(".")


func set_new_text_edit(provided_text_edit):
	text_edit = provided_text_edit
	if text_edit not in connected_editors:
		text_edit.connect("caret_changed", Callable(self, "update_word_counter"))
		connected_editors.append(text_edit)
	update_word_counter()

func update_word_counter():
	if !text_edit or !regex_word_count.is_valid() or !regex_character_count.is_valid():
		print("Invalid text_edit or regex")
		return

	var text = text_edit.text if text_edit else ""
	var word_count = 0
	var character_count = 0

	if text != "":
		var char_matches = regex_character_count.search_all(text)
		var word_matches = regex_word_count.search_all(text)

		if char_matches != null and word_matches != null:
			word_count = word_matches.size()
			character_count = char_matches.size()

	# Use string formatting to ensure consistent width
	var formatted_text = "Word Count: %7d | Character Count: %9d" % [word_count, character_count]
	set_text(formatted_text)

