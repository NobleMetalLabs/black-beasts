class_name Serializeable
extends Resource

func serialize() -> Dictionary:
	return Serializeable._variant_to_deep_variant(self)

static func serialize_variant(variant : Variant) -> Variant:
	return _variant_to_deep_variant(variant)

static func _get_object_variable_names(obj : Object) -> Array[String]:
	var property_list : Array[Dictionary] = obj.get_property_list()
	var script_variables : Array[Dictionary] = property_list.filter(func get_script_variables(p : Dictionary) -> bool: return p["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE)
	var variable_names : Array[String] = []
	variable_names.assign(script_variables.map(func(p : Dictionary) -> String: return p.name))
	return variable_names

static func _object_to_dict(obj : Object) -> Dictionary:
	if not obj is Serializeable: 
		push_error("Error: Object [%s]-%s is not Serializeable." % [obj.get_script().get_global_name(), obj])
		return {}
	var obj_dict : Dictionary = {
		"class_path" : obj.get_script().resource_path,
	}
	var variable_names : Array[String] = _get_object_variable_names(obj)
	for vname : String in variable_names:
		var value : Variant = obj.get(vname)
		obj_dict[vname] = _variant_to_deep_variant(value)
	return obj_dict

static func _object_to_resource_path_dict(obj : Object) -> Dictionary:
	return {
		"resource_path" : obj.resource_path
	}

static func _dict_to_deep_dict(dict : Dictionary) -> Dictionary:
	var deep_dict : Dictionary = {}
	for key : Variant in dict.keys():
		var value : Variant = dict[key]
		deep_dict[key] = _variant_to_deep_variant(value)
	return deep_dict

static func _array_to_deep_array(array : Array) -> Array:
	var new_arr : Array = []
	for value : Variant in array:
		new_arr.append(_variant_to_deep_variant(value))
	return new_arr

static func _variant_to_deep_variant(variant : Variant) -> Variant:
	if variant is Object:
		if variant.resource_path.ends_with(".tres"): #Instantiated, resource
			return _object_to_resource_path_dict(variant)
		#if variant is NetworkMessage:
		return _object_to_dict(variant)
		#return _object_to_uid_dict(variant)
	elif variant is Dictionary:
		return _dict_to_deep_dict(variant)
	elif variant is Array:
		return _array_to_deep_array(variant)
	else:
		return variant

static func deserialize(serialized : Variant) -> Variant:
	return _deep_variant_to_variant(serialized)

static func _dict_to_object(dict : Dictionary) -> Variant:
	var path : String = dict["class_path"]
	var instance : Object = load(path).new()
	for vname : String in dict.keys():
		if vname == "class_path": continue
		var value : Variant = dict.get(vname)
		var dvalue : Variant = _deep_variant_to_variant(value)
		if value is Array:
			instance.get(vname).assign(dvalue) # Preserve typed arrays
		else:
			instance.set(vname, dvalue)
	return instance

static func _resource_path_dict_to_object(dict : Dictionary) -> Variant:
	return load(dict["resource_path"])

static func _deep_dict_to_dict(deep_dict : Dictionary) -> Dictionary:
	var dict : Dictionary = {}
	for key : Variant in deep_dict.keys():
		var value : Variant = deep_dict[key]
		dict[key] = _deep_variant_to_variant(value)
	return dict

static func _deep_array_to_array(deep_array : Array) -> Array:
	var array : Array = []
	for value : Variant in deep_array:
		array.append(_deep_variant_to_variant(value))
	return array

static func _deep_variant_to_variant(deep_variant : Variant) -> Variant:
	if deep_variant is Dictionary:
		if deep_variant.has("resource_path"):
			return _resource_path_dict_to_object(deep_variant)
		if deep_variant.has("class_path"):
			return _dict_to_object(deep_variant)
		else:
			return _deep_dict_to_dict(deep_variant)
	elif deep_variant is Array:
		return _deep_array_to_array(deep_variant)
	else:
		return deep_variant

