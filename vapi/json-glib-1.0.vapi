/* json-glib-1.0.vapi generated by vapigen, do not modify. */

[CCode (cprefix = "Json", lower_case_cprefix = "json_")]
namespace Json {
	[Compact]
	[CCode (ref_function = "json_array_ref", unref_function = "json_array_unref", type_id = "JSON_TYPE_ARRAY", cheader_filename = "json-glib/json-glib.h")]
	public class Array {
		[CCode (has_construct_function = false)]
		public Array ();
		public void add_array_element (owned Json.Array value);
		public void add_boolean_element (bool value);
		public void add_double_element (double value);
		public void add_element (owned Json.Node node);
		public void add_int_element (int64 value);
		public void add_null_element ();
		public void add_object_element (owned Json.Object value);
		public void add_string_element (string value);
		public unowned Json.Node dup_element (uint index_);
		public void foreach_element (Json.ArrayForeach func, void* data);
		public unowned Json.Array get_array_element (uint index_);
		public bool get_boolean_element (uint index_);
		public double get_double_element (uint index_);
		public unowned Json.Node get_element (uint index_);
		public GLib.List<weak Json.Node> get_elements ();
		public int64 get_int_element (uint index_);
		public uint get_length ();
		public bool get_null_element (uint index_);
		public unowned Json.Object get_object_element (uint index_);
		public unowned string get_string_element (uint index_);
		public void remove_element (uint index_);
		public static unowned Json.Array sized_new (uint n_elements);
	}
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public class Generator : GLib.Object {
		[CCode (has_construct_function = false)]
		public Generator ();
		public void set_root (Json.Node node);
		public string to_data (out size_t length);
		public bool to_file (string filename) throws GLib.Error;
		[NoAccessorMethod]
		public uint indent { get; set; }
		[NoAccessorMethod]
		public uint indent_char { get; set; }
		[NoAccessorMethod]
		public bool pretty { get; set; }
		[NoAccessorMethod]
		public Json.Node root { owned get; set; }
	}
	[Compact]
	[CCode (copy_function = "json_node_copy", type_id = "JSON_TYPE_NODE", cheader_filename = "json-glib/json-glib.h")]
	public class Node {
		[CCode (has_construct_function = false)]
		public Node (Json.NodeType type);
		public Json.Node copy ();
		public Json.Array dup_array ();
		public Json.Object dup_object ();
		public string dup_string ();
		public unowned Json.Array get_array ();
		public bool get_boolean ();
		public double get_double ();
		public int64 get_int ();
		public Json.NodeType get_node_type ();
		public unowned Json.Object get_object ();
		public unowned Json.Node get_parent ();
		public unowned string get_string ();
		public void get_value (out GLib.Value value);
		public GLib.Type get_value_type ();
		public bool is_null ();
		public void set_array (Json.Array array);
		public void set_boolean (bool value);
		public void set_double (double value);
		public void set_int (int64 value);
		public void set_object (Json.Object object);
		public void set_parent (Json.Node parent);
		public void set_string (string value);
		public void set_value (GLib.Value value);
		public void take_array (owned Json.Array array);
		public void take_object (owned Json.Object object);
		public unowned string type_name ();
	}
	[Compact]
	[CCode (ref_function = "json_object_ref", unref_function = "json_object_unref", type_id = "JSON_TYPE_OBJECT", cheader_filename = "json-glib/json-glib.h")]
	public class Object {
		[CCode (has_construct_function = false)]
		public Object ();
		public void add_member (string member_name, owned Json.Node node);
		public unowned Json.Node dup_member (string member_name);
		public void foreach_member (Json.ObjectForeach func, void* data);
		public unowned Json.Array get_array_member (string member_name);
		public bool get_boolean_member (string member_name);
		public double get_double_member (string member_name);
		public int64 get_int_member (string member_name);
		public unowned Json.Node get_member (string member_name);
		public GLib.List<weak string> get_members ();
		public bool get_null_member (string member_name);
		public unowned Json.Object get_object_member (string member_name);
		public uint get_size ();
		public unowned string get_string_member (string member_name);
		public GLib.List<weak Json.Node> get_values ();
		public bool has_member (string member_name);
		public void remove_member (string member_name);
		public void set_array_member (string member_name, owned Json.Array value);
		public void set_boolean_member (string member_name, bool value);
		public void set_double_member (string member_name, double value);
		public void set_int_member (string member_name, int64 value);
		public void set_member (string member_name, Json.Node node);
		public void set_null_member (string member_name);
		public void set_object_member (string member_name, owned Json.Object value);
		public void set_string_member (string member_name, string value);
	}
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public class Parser : GLib.Object {
		[CCode (has_construct_function = false)]
		public Parser ();
		public static GLib.Quark error_quark ();
		public uint get_current_line ();
		public uint get_current_pos ();
		public unowned Json.Node get_root ();
		public bool has_assignment (out unowned string variable_name);
		public bool load_from_data (string data, ssize_t length = -1) throws GLib.Error;
		public bool load_from_file (string filename) throws GLib.Error;
		public virtual signal void array_element (Json.Array array, int index_);
		public virtual signal void array_end (Json.Array array);
		public virtual signal void array_start ();
		public virtual signal void error (void* error);
		public virtual signal void object_end (Json.Object object);
		public virtual signal void object_member (Json.Object object, string member_name);
		public virtual signal void object_start ();
		public virtual signal void parse_end ();
		public virtual signal void parse_start ();
	}
	[CCode (cheader_filename = "json-glib/json-glib.h,json-glib/json-gobject.h")]
	public interface Serializable {
		public bool default_deserialize_property (string property_name, GLib.Value value, GLib.ParamSpec pspec, Json.Node property_node);
		public unowned Json.Node default_serialize_property (string property_name, GLib.Value value, GLib.ParamSpec pspec);
		public abstract bool deserialize_property (string property_name, out GLib.Value value, GLib.ParamSpec pspec, Json.Node property_node);
		public abstract Json.Node serialize_property (string property_name, GLib.Value value, GLib.ParamSpec pspec);
	}
	[CCode (cprefix = "JSON_NODE_", cheader_filename = "json-glib/json-glib.h")]
	public enum NodeType {
		OBJECT,
		ARRAY,
		VALUE,
		NULL
	}
	[CCode (cprefix = "JSON_PARSER_ERROR_", cheader_filename = "json-glib/json-glib.h")]
	public enum ParserError {
		PARSE,
		UNKNOWN
	}
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public delegate void ArrayForeach (Json.Array array, uint index_, Json.Node element_node);
	[CCode (cheader_filename = "json-glib/json-glib.h", has_target = false)]
	public delegate void* BoxedDeserializeFunc (Json.Node node);
	[CCode (cheader_filename = "json-glib/json-glib.h", has_target = false)]
	public delegate unowned Json.Node BoxedSerializeFunc (void* boxed);
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public delegate void ObjectForeach (Json.Object object, string member_name, Json.Node member_node);
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public const int MAJOR_VERSION;
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public const int MICRO_VERSION;
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public const int MINOR_VERSION;
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public const int VERSION_HEX;
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public const string VERSION_S;
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public static bool boxed_can_deserialize (GLib.Type gboxed_type, Json.NodeType node_type);
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public static bool boxed_can_serialize (GLib.Type gboxed_type, Json.NodeType node_type);
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public static void* boxed_deserialize (GLib.Type gboxed_type, Json.Node node);
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public static void boxed_register_deserialize_func (GLib.Type gboxed_type, Json.NodeType node_type, Json.BoxedDeserializeFunc deserialize_func);
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public static void boxed_register_serialize_func (GLib.Type gboxed_type, Json.NodeType node_type, Json.BoxedSerializeFunc serialize_func);
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public static unowned Json.Node boxed_serialize (GLib.Type gboxed_type, void* boxed);
	[CCode (cheader_filename = "json-glib/json-glib.h,json-glib/json-gobject.h")]
	public static GLib.Object construct_gobject (GLib.Type gtype, string data, size_t length) throws GLib.Error;
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public static unowned GLib.Object gobject_deserialize (GLib.Type gtype, Json.Node node);
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public static unowned GLib.Object gobject_from_data (GLib.Type gtype, string data, ssize_t length) throws GLib.Error;
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public static unowned Json.Node gobject_serialize (GLib.Object gobject);
	[CCode (cheader_filename = "json-glib/json-glib.h")]
	public static string gobject_to_data (GLib.Object gobject, out size_t length);
	[CCode (cheader_filename = "json-glib/json-glib.h,json-glib/json-gobject.h")]
	public static string serialize_gobject (GLib.Object gobject, out size_t length);
}
