extends Control

@export var picked_player:Player
@onready var counter_label:Label = $CounterContainer/CounterLable
@onready var timer_label:Label = $SecoundContainer/TimerContainer/TimerLabel
@onready var score_label:Label = $SecoundContainer/ScoreLabel

var time:float = 500
var visual_score:int = 0

func _process(delta: float) -> void:
	time-= 0.015
	timer_label.text = str(floor(time))
	
	counter_label.text = str(picked_player.coins)
	
	if visual_score < picked_player.score:
		var added = floor(max(2, (picked_player.score-visual_score)/10))
		visual_score = clamp(visual_score+added, 0, picked_player.score)
	score_label.text = str(visual_score)
	
