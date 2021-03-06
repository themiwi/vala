/* valaclassregisterfunction.vala
 *
 * Copyright (C) 2006-2008  Jürg Billeter
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	Jürg Billeter <j@bitron.ch>
 */

using GLib;

/**
 * C function to register a class at runtime.
 */
public class Vala.ClassRegisterFunction : TypeRegisterFunction {
	/**
	 * Specifies the class to be registered.
	 */
	public weak Class class_reference { get; set; }

	/**
	 * Creates a new C function to register the specified class at runtime.
	 *
	 * @param cl a class
	 * @return   newly created class register function
	 */
	public ClassRegisterFunction (Class cl, CodeContext context) {
		class_reference = cl;
		this.context = context;
	}
	
	public override TypeSymbol get_type_declaration () {
		return class_reference;
	}
	
	public override string get_type_struct_name () {
		return "%sClass".printf (class_reference.get_cname ());
	}

	public override string get_base_init_func_name () {
		if (class_reference.class_constructor != null || (!context.require_glib_version (2, 24) && class_reference.has_class_private_fields)) {
			return "%s_base_init".printf (class_reference.get_lower_case_cname (null));
		} else {
			return "NULL";
		}
	}

	public override string get_class_finalize_func_name () {
		if (class_reference.static_destructor != null) {
			return "%s_class_finalize".printf (class_reference.get_lower_case_cname (null));
		} else {
			return "NULL";
		}
	}

	public override string get_base_finalize_func_name () {
		if (class_reference.class_destructor != null || (!context.require_glib_version (2, 24) && class_reference.has_class_private_fields)) {
			return "%s_base_finalize".printf (class_reference.get_lower_case_cname (null));
		} else {
			return "NULL";
		}
	}

	public override string get_class_init_func_name () {
		return "%s_class_init".printf (class_reference.get_lower_case_cname (null));
	}
	
	public override string get_instance_struct_size () {
		return "sizeof (%s)".printf (class_reference.get_cname ());
	}
	
	public override string get_instance_init_func_name () {
		return "%s_instance_init".printf (class_reference.get_lower_case_cname (null));
	}
	
	public override string get_parent_type_name () {
		return class_reference.base_class.get_type_id ();
	}

	public override string get_type_flags () {
		if (class_reference.is_abstract) {
			return "G_TYPE_FLAG_ABSTRACT";
		} else {
			return "0";
		}
	}

	public override SymbolAccessibility get_accessibility () {
		return class_reference.access;
	}

	public override string? get_gtype_value_table_init_function_name () {
		bool is_fundamental = !class_reference.is_compact && class_reference.base_class == null;
		if ( is_fundamental )
			return "%s_init".printf (class_reference.get_lower_case_cname ("value_"));

		return null;
	}

	public override string? get_gtype_value_table_free_function_name () {
		bool is_fundamental = !class_reference.is_compact && class_reference.base_class == null;
		if ( is_fundamental )
			return "%s_free_value".printf (class_reference.get_lower_case_cname ("value_"));

		return null;
	}

	public override string? get_gtype_value_table_copy_function_name () {
		bool is_fundamental = !class_reference.is_compact && class_reference.base_class == null;
		if ( is_fundamental )
			return "%s_copy_value".printf (class_reference.get_lower_case_cname ("value_"));

		return null;
	}

	public override string? get_gtype_value_table_peek_pointer_function_name () {
		bool is_fundamental = !class_reference.is_compact && class_reference.base_class == null;
		if ( is_fundamental )
			return "%s_peek_pointer".printf (class_reference.get_lower_case_cname ("value_"));

		return null;
	}

	public override string? get_gtype_value_table_collect_value_function_name () {
		bool is_fundamental = !class_reference.is_compact && class_reference.base_class == null;
		if ( is_fundamental )
			return "%s_collect_value".printf (class_reference.get_lower_case_cname ("value_"));

		return null;
	}

	public override string? get_gtype_value_table_lcopy_value_function_name () {
		bool is_fundamental = !class_reference.is_compact && class_reference.base_class == null;
		if ( is_fundamental )
			return "%s_lcopy_value".printf (class_reference.get_lower_case_cname ("value_"));

		return null;
	}

	public override CCodeFragment get_type_interface_init_declaration () {
		var frag = new CCodeFragment ();
		
		foreach (DataType base_type in class_reference.get_base_types ()) {
			if (!(base_type.data_type is Interface)) {
				continue;
			}
			
			var iface = (Interface) base_type.data_type;
			
			var iface_info_name = "%s_info".printf (iface.get_lower_case_cname (null));
			
			var ctypedecl = new CCodeDeclaration ("const GInterfaceInfo");
			ctypedecl.modifiers = CCodeModifiers.STATIC;
			ctypedecl.add_declarator (new CCodeVariableDeclarator (iface_info_name, new CCodeConstant ("{ (GInterfaceInitFunc) %s_%s_interface_init, (GInterfaceFinalizeFunc) NULL, NULL}".printf (class_reference.get_lower_case_cname (null), iface.get_lower_case_cname (null)))));
			frag.append (ctypedecl);
		}
		
		return frag;
	}

	public override CCodeFragment get_type_interface_init_statements (bool plugin) {
		var frag = new CCodeFragment ();
		
		foreach (DataType base_type in class_reference.get_base_types ()) {
			if (!(base_type.data_type is Interface)) {
				continue;
			}
			
			var iface = (Interface) base_type.data_type;
			
			var iface_info_name = "%s_info".printf (iface.get_lower_case_cname (null));
			if (!plugin) {
				var reg_call = new CCodeFunctionCall (new CCodeIdentifier ("g_type_add_interface_static"));
				reg_call.add_argument (new CCodeIdentifier ("%s_type_id".printf (class_reference.get_lower_case_cname (null))));
				reg_call.add_argument (new CCodeIdentifier (iface.get_type_id ()));
				reg_call.add_argument (new CCodeIdentifier ("&%s".printf (iface_info_name)));
				frag.append (new CCodeExpressionStatement (reg_call));
			} else {
				var reg_call = new CCodeFunctionCall (new CCodeIdentifier ("g_type_module_add_interface"));
				reg_call.add_argument (new CCodeIdentifier ("module"));
				reg_call.add_argument (new CCodeIdentifier ("%s_type_id".printf (class_reference.get_lower_case_cname (null))));
				reg_call.add_argument (new CCodeIdentifier (iface.get_type_id ()));
				reg_call.add_argument (new CCodeIdentifier ("&%s".printf (iface_info_name)));
				frag.append (new CCodeExpressionStatement (reg_call));
			}
		}
		
		return frag;
	}
}
