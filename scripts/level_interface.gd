extends Control

@export var picked_player:Player
@onready var counter_label:Label = $CounterContainer/CounterLable
@onready var timer_label:Label = $SecoundContainer/TimerContainer/TimerLabel
@onready var score_label:Label = $SecoundContainer/ScoreLabel

var time:float = 500
var visual_score:int = 0

func _process(delta: float) -> void:
	time-= 0.015
	timer_label.text = rjust(str(floor(time)), 3, "0")
	
	counter_label.text = ": " + rjust(str(picked_player.coins), 2, "0")
	
	if visual_score < picked_player.score:
		var added = floor(max(2, (picked_player.score-visual_score)/10))
		visual_score = clamp(visual_score+added, 0, picked_player.score)
	score_label.text = rjust(str(visual_score), 9, "0")
	
func rjust(input_string: String, width: int, fill_char: String = " ") -> String:
	var current_length = input_string.length()
	if current_length >= width:
		return input_string
	var padding_length = width - current_length
	var padding = fill_char.repeat(padding_length)
	return padding + input_string
