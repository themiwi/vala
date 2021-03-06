/* valaaddressofexpression.vala
 *
 * Copyright (C) 2007-2008  Jürg Billeter
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
 * Represents an address-of expression in the source code, e.g. `&foo`.
 */
public class Vala.AddressofExpression : Expression {
	/**
	 * The variable whose address is to be computed.
	 */
	public Expression inner {
		get {
			return _inner;
		}
		set {
			_inner = value;
			_inner.parent_node = this;
		}
	}
	
	private Expression _inner;

	/**
	 * Creates a new address-of expression.
	 *
	 * @param inner variable whose address is to be computed
	 * @return      newly created address-of expression
	 */
	public AddressofExpression (Expression inner, SourceReference? source_reference = null) {
		this.source_reference = source_reference;
		this.inner = inner;
	}
	
	public override void accept (CodeVisitor visitor) {
		inner.accept (visitor);

		visitor.visit_addressof_expression (this);

		visitor.visit_expression (this);
	}

	public override void replace_expression (Expression old_node, Expression new_node) {
		if (inner == old_node) {
			inner = new_node;
		}
	}

	public override bool is_pure () {
		return inner.is_pure ();
	}

	public override bool check (SemanticAnalyzer analyzer) {
		if (checked) {
			return !error;
		}

		checked = true;

		if (!inner.check (analyzer)) {
			error = true;
			return false;
		}
		if (!(inner.value_type is ValueType
		      || inner.value_type is ObjectType
		      || inner.value_type is PointerType
		      || inner.value_type is GenericType)) {
			error = true;
			Report.error (source_reference, "Address-of operator not supported for this expression");
			return false;
		}

		if (inner.value_type.is_reference_type_or_type_parameter ()) {
			value_type = new PointerType (new PointerType (inner.value_type));
		} else {
			value_type = new PointerType (inner.value_type);
		}

		return !error;
	}
}
