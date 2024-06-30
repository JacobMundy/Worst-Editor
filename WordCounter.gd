extends RichTextLabel

@onready var default_tab = get_node("../TabContainer/New 1")
var text_edit
var connected_editors = []
var update_timer: Timer
var thread: Thread
var mutex: Mutex
var exit_thread := false
var word_count := 0
var character_count := 0

@onready var label_scroll_container = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	self.scroll_active = false

	mutex = Mutex.new()
	thread = Thread.new()
	thread.start(Callable(self, "_thread_function"))
	set_new_text_edit(default_tab)

func _exit_tree():
	exit_thread = true
	thread.wait_to_finish()

func schedule_update():
	update_ui()
	
func set_new_text_edit(provided_text_edit):
	text_edit = provided_text_edit
	if text_edit not in connected_editors:
		text_edit.connect("text_changed", Callable(self, "on_text_changed"))
		
		connected_editors.append(text_edit)
	schedule_update()

# Connect this to your CodeEdit's "text_changed" signal
func on_text_changed():
	schedule_update()

func _thread_function():
	while !exit_thread:
		mutex.lock()
		var current_text = text_edit.text if text_edit else ""
		mutex.unlock()

		var local_word_count = count_words(current_text)
		var local_character_count = count_characters(current_text)

		mutex.lock()
		word_count = local_word_count
		character_count = local_character_count
		mutex.unlock()

		call_deferred("update_ui")
		OS.delay_msec(500)  # Small delay to prevent excessive CPU usage

func update_ui():
	var formatted_text = "Word Count: %7d   | Character Count: %7d" % [word_count, character_count]
	set_text(formatted_text)



func count_words(text):
	# source: https://www.reddit.com/r/godot/comments/nyi132/how_to_count_words_in_a_string_without_counting/
	# it appears to work, and it seems to work efficently at that

	var linebreak_array = text.split("\n", false)
	var lines = []
	for i in linebreak_array:
		var line = i.replace("\t", "").strip_edges()
		line = line.replace("\n","").strip_edges()
		if line:
			lines.append(line)
		
	var word_count = 0
	for i in lines:
		i = i.split(" ", false)
		word_count += i.size()

	return word_count


func count_characters(text):
	# Remove all whitespace to get the count of non-whitespace characters
	text = text.replace("\t", "")
	text = text.replace("\n", "")
	return len(text)

