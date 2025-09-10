extends Node


#VARIABLE FOR THE ENERGY
var energy = 100

var efficiency_buff = false

#VARIABLES FOR THE QUOTA
var programmingTasks = 0
var artworkTasks = 0
var musicTasks = 0

#VARIABLES FOR TIME
var current_time = 6
var finish_time = 18
var days_left = 3

# TASK COMPLETION COUNTERS
var programming_tasks_completed = 0
var artwork_tasks_completed = 0
var music_tasks_completed = 0

# COMPLETED ART ASSETS
var completed_art_assets: Array = []  # List of completed art asset names (without extension)

# BOOL VARIABLES (for backward compatibility, but will be replaced)
var finished_programming_task = false
var finished_artwork_task = false
var finished_music_task = false

#WHEN RESETTING THE DAY
func reset_day():
	current_time = 6
	programming_tasks_completed = 0
	artwork_tasks_completed = 0
	music_tasks_completed = 0
	completed_art_assets = []
	finished_programming_task = false
	finished_artwork_task = false
	finished_music_task = false

func game_over():
	get_tree().quit()

# Helper functions for task completion
func get_total_tasks_completed():
	return programming_tasks_completed + artwork_tasks_completed + music_tasks_completed

func is_all_tasks_completed():
	return get_total_tasks_completed() >= 3  # 1 task per workstation * 3 workstations
