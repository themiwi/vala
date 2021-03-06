/* valalocalvariable.vala
 *
 * Copyright (C) 2006-2010  Jürg Billeter
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
 * Represents a local variable declaration in the source code.
 */
public class Vala.LocalVariable : Symbol {
	/**
	 * The optional initializer expression.
	 */
	public Expression? initializer {
		get {
			return _initializer;
		}
		set {
			_initializer = value;
			if (_initializer != null) {
				_initializer.parent_node = this;
			}
		}
	}
	
	/**
	 * The variable type.
	 */
	public DataType? variable_type {
		get { return _variable_type; }
		set {
			_variable_type = value;
			if (_variable_type != null) {
				_variable_type.parent_node = this;
			}
		}
	}

	public bool is_result { get; set; }

	/**
	 * Floating variables may only be accessed exactly once.
	 */
	public bool floating { get; set; }

	public bool captured { get; set; }

	public bool no_init { get; set; }

	private Expression? _initializer;
	private DataType? _variable_type;

	/**
	 * Creates a new local variable.
	 *
	 * @param name   name of the variable
	 * @param init   optional initializer expression
	 * @param source reference to source code
	 * @return       newly created variable declarator
	 */
	public LocalVariable (DataType? variable_type, string name, Expression? initializer = null, SourceReference? source_reference = null) {
		base (name, source_reference);
		this.variable_type = variable_type;
		this.initializer = initializer;
	}
	
	public override void accept (CodeVisitor visitor) {
		visitor.visit_local_variable (this);
	}

	public override void accept_children (CodeVisitor visitor) {
		if (initializer != null) {
			initializer.accept (visitor);
		
			visitor.visit_end_full_expression (initializer);
		}
		
		if (variable_type != null) {
			variable_type.accept (visitor);
		}
	}

	public override void replace_expression (Expression old_node, Expression new_node) {
		if (initializer == old_node) {
			initializer = new_node;
		}
	}

	public override void replace_type (DataType old_type, DataType new_type) {
		if (variable_type == old_type) {
			variable_type = new_type;
		}
	}

	public override bool check (SemanticAnalyzer analyzer) {
		if (checked) {
			return !error;
		}

		checked = true;

		if (variable_type != null) {
			variable_type.check (analyzer);
		}

		if (initializer != null) {
			initializer.target_type = variable_type;

			initializer.check (analyzer);
		}

		if (variable_type == null) {
			/* var type */

			if (initializer == null) {
				error = true;
				Report.error (source_reference, "var declaration not allowed without initializer");
				return false;
			}
			if (initializer.value_type == null) {
				error = true;
				Report.error (source_reference, "var declaration not allowed with non-typed initializer");
				return false;
			}
			if (initializer.value_type is FieldPrototype) {
				error = true;
				Report.error (initializer.source_reference, "Access to instance member `%s' denied".printf (initializer.symbol_reference.get_full_name ()));
				return false;
			}

			variable_type = initializer.value_type.copy ();
			variable_type.value_owned = true;
			variable_type.floating_reference = false;

			initializer.target_type = variable_type;
		}

		if (initializer != null && !initializer.error) {
			if (initializer.value_type == null) {
				if (!(initializer is MemberAccess) && !(initializer is LambdaExpression)) {
					error = true;
					Report.error (source_reference, "expression type not allowed as initializer");
					return false;
				}

				if (initializer.symbol_reference is Method &&
				    variable_type is DelegateType) {
					var m = (Method) initializer.symbol_reference;
					var dt = (DelegateType) variable_type;
					var cb = dt.delegate_symbol;

					/* check whether method matches callback type */
					if (!cb.matches_method (m)) {
						error = true;
						Report.error (source_reference, "declaration of method `%s' doesn't match declaration of callback `%s'".printf (m.get_full_name (), cb.get_full_name ()));
						return false;
					}

					initializer.value_type = variable_type;
				} else {
					error = true;
					Report.error (source_reference, "expression type not allowed as initializer");
					return false;
				}
			}

			if (!initializer.value_type.compatible (variable_type)) {
				error = true;
				Report.error (source_reference, "Assignment: Cannot convert from `%s' to `%s'".printf (initializer.value_type.to_string (), variable_type.to_string ()));
				return false;
			}

			if (initializer.value_type.is_disposable ()) {
				/* rhs transfers ownership of the expression */
				if (!(variable_type is PointerType) && !variable_type.value_owned) {
					/* lhs doesn't own the value */
					error = true;
					Report.error (source_reference, "Invalid assignment from owned expression to unowned variable");
					return false;
				}
			}
		}

		analyzer.current_symbol.scope.add (name, this);

		// current_symbol is a Method if this is the `result'
		// variable used for postconditions
		var block = analyzer.current_symbol as Block;
		if (block != null) {
			block.add_local_variable (this);
		}

		active = true;

		return !error;
	}
}
