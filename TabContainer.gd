extends TabContainer

@onready var popup_window = get_node("../ChangeFileNameWindow")
@onready var popup_control = get_node("../ChangeFileNameWindow/PopupControl")
@onready var line_counter = get_node("../LineCounter")


var last_time_clicked = 0
var double_click_threshold = 0.15

# Called when the node enters the scene tree for the first time.
func _ready():
	drag_to_rearrange_enabled = true
	connect("tab_clicked", Callable(self, "_on_tab_clicked"))
	connect("tab_changed", Callable(self, "_on_tab_change"))


func _input(event):
	if Input.is_key_pressed(KEY_CTRL):
		if event.is_action_released("close_current_tab") and len(self.get_children()) > 0:
			self.get_child(current_tab).queue_free()

func _on_tab_change(tab_index):
	var text_edit = get_child(tab_index)
	line_counter.set_new_text_edit(text_edit)

func _on_tab_clicked(tab_index):
	var text_edit = get_child(tab_index)
	line_counter.set_new_text_edit(text_edit)
	
	
	# Logic for title change 
	var now = Time.get_ticks_msec() / 1000.0  # Current time in seconds
	if now - last_time_clicked < double_click_threshold:
		popup_window.visible = true
		popup_control.set_idx(tab_index)
		popup_control.set_input_text(self.get_tab_title(tab_index))
	last_time_clicked = now


