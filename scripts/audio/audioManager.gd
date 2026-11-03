extends Node
@onready var musica_fase_1: AudioStreamPlayer = $fase1
@onready var musica_fase_2: AudioStreamPlayer = $fase2
@onready var som__lanterna: AudioStreamPlayer2D = $"som_ Lanterna"

func tocar_musica_fase1():
	musica_fase_1.play()

func tocar_musica_fase2():
	musica_fase_2.play()
	
func tocar_som_lanterna():
	som__lanterna.play(0.2)
