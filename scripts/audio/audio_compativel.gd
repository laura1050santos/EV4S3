extends RefCounted

# Configure before play(): changing a stream during playback stops the player.
static func configurar(player: Node, repetir: bool = false) -> void:
	if player.stream is AudioStreamMP3:
		var copia: AudioStreamMP3 = player.stream.duplicate()
		copia.loop = repetir
		player.stream = copia
	if OS.has_feature("web"):
		player.playback_type = AudioServer.PLAYBACK_TYPE_SAMPLE
