extends RichTextLabel

@onready var default_tab = get_node("../TabContainer/New 1")
var text_edit
var connected_editors = []
var update_timer: Timer

@onready var label_scroll_container = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	set_new_text_edit(default_tab)
	self.scroll_active = false
	update_timer = Timer.new()
	update_timer.one_shot = true
	update_timer.timeout.connect(update_word_counter)
	add_child(update_timer)

func schedule_update():
	if !update_timer.is_stopped():
		update_timer.stop()
	update_timer.start(0.5)  # 0.5 second delay
	
func set_new_text_edit(provided_text_edit):
	text_edit = provided_text_edit
	if text_edit not in connected_editors:
		text_edit.connect("caret_changed", Callable(self, "on_text_changed"))
		
		connected_editors.append(text_edit)
	update_word_counter()
	
# Connect this to your CodeEdit's "text_changed" signal
func on_text_changed():
	schedule_update()
	
func update_word_counter():

	var text = text_edit.text
	var word_count = 0
	var character_count = 0

	if text != "":
		word_count = count_words(text)
		character_count = count_characters(text)

	var formatted_text = "Word Count: %7d   | Character Count: %7d" % [word_count, character_count]
	set_text(formatted_text)



func count_words(text):
	# Split the text by whitespace and filter out empty strings
	return len(text.split(' ', true))

func count_characters(text):
	# Remove all whitespace to get the count of non-whitespace characters
	return len(text.replace(' ', ''))
