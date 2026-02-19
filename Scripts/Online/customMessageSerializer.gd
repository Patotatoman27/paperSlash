extends "res://addons/godot-rollback-netcode/MessageSerializer.gd"

const input_path_mapping := {
	'/root/Main/World/Player1': 1,
	'/root/Main/World/Player2': 2,
}
enum HeaderFlags {
	HAS_INPUTVECTOR = 0x01,
	JUMP_ACTION = 0x02
}

var input_path_mapping_reverse := {}

func _init() -> void:
	for key in input_path_mapping:
		input_path_mapping_reverse[input_path_mapping[key]] = key
		
func serialize_input(allInput: Dictionary) -> PackedByteArray:
	var buffer := StreamPeerBuffer.new()
	buffer.resize(16)
	
	buffer.put_32(allInput["$"])
	buffer.put_8(allInput.size()-1)
	
	for path in allInput:
		if path == "$":
			continue
		buffer.put_u8(input_path_mapping[path])
	
		var header := 0
		var input = allInput[path]
		if input.has("inputVector"):
			header |= HeaderFlags.HAS_INPUTVECTOR
		if input.get("jump", false):
			header |= HeaderFlags.JUMP_ACTION
		
		buffer.put_u8(header)
		
		if input.has("inputVector"):
			var inputVector: Vector2 = input["inputVector"]
			buffer.put_float(inputVector.x) 
			buffer.put_float(inputVector.y) 
			
	buffer.resize(buffer.get_position())
	return buffer.data_array

func unserialize_input(serialized: PackedByteArray) -> Dictionary:
	var buffer := StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	
	var allInput := {}
	
	allInput["$"] = buffer.get_u32()
	var input_count := buffer.get_u8()
	if input_count == 0:
		return allInput
	
	var path = input_path_mapping_reverse[buffer.get_u8()]
	var input := {}
	
	var header = buffer.get_u8()
	if header & HeaderFlags.HAS_INPUTVECTOR:
		input["inputVector"] = Vector2(buffer.get_float(), buffer.get_float())
	if header & HeaderFlags.JUMP_ACTION:
		input["jump"] = true
	
	allInput[path] = input
	return allInput
