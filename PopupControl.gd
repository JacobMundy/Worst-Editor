extends Control


@onready var tab_container = get_node("../../TabContainer")
@onready var parent_window = get_node("..")
var tab_idx = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$OK.connect("pressed", Callable(self, "_on_OK_pressed"))
	$CANCEL.connect("pressed", Callable(self, "_on_CANCEL_pressed"))
	$LineEdit.connect("text_submitted", Callable(self, "_on_text_submission"))
	parent_window.focus_exited.connect(Callable(self, "_on_CANCEL_pressed"))

func set_idx(tab_index: int):
	tab_idx = tab_index

func set_input_text(text):
	$LineEdit.text = text
	$LineEdit.grab_focus()
	$LineEdit.set_caret_column(len(text))

func _on_OK_pressed():
	tab_container.set_tab_title(tab_idx, $LineEdit.text)
	parent_window.visible = false

func _on_CANCEL_pressed():
	parent_window.visible = false 

func _on_text_submission(submitted_text):
	tab_container.set_tab_title(tab_idx, submitted_text)
	parent_window.visible = false
