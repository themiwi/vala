/* valageniescanner.vala
 *
 * Copyright (C) 2008  Jamie McCracken, Jürg Billeter
 * Based on code by Jürg Billeter
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
 * 	Jamie McCracken jamiemcc gnome org
 */

using GLib;
using Gee;

/**
 * Lexical scanner for Genie source files.
 */
public class Vala.Genie.Scanner : Object {
	public SourceFile source_file { get; construct; }

	char* begin;
	char* current;
	char* end;

	int line;
	int column;

	int current_indent_level;
	int indent_level;
	int pending_dedents;

	TokenType last_token;
	bool parse_started;

	string _comment;

	public Scanner (SourceFile source_file) {
		this.source_file = source_file;
	}

	construct {
		begin = source_file.get_mapped_contents ();
		end = begin + source_file.get_mapped_length ();

		current = begin;

		line = 1;
		column = 1;
		current_indent_level = 0;
		indent_level = 0;
		pending_dedents = 0;

		parse_started = false;
		last_token = TokenType.NONE;
		
	}

	bool is_ident_char (char c) {
		return (c.isalnum () || c == '_');
	}

	TokenType get_identifier_or_keyword (char* begin, int len) {
		switch (len) {
		case 2:
			switch (begin[0]) {
			case 'a':
				if (matches (begin, "as")) return TokenType.AS;
				break;
			case 'd':
				if (matches (begin, "do")) return TokenType.DO;
				break;
			case 'i':
				switch (begin[1]) {
				case 'f':
					return TokenType.IF;
				case 'n':
					return TokenType.IN;
				case 's':
					return TokenType.IS;
				}
				break;
			case 'o':
				if (matches (begin, "of")) return TokenType.OF;
				
				if (matches (begin, "or")) return TokenType.OP_OR;
				break;
			case 't':
				if (matches (begin, "to")) return TokenType.TO;
				break;
			}
			break;
		case 3:
			switch (begin[0]) {
			case 'a':
				if (matches (begin, "and")) return TokenType.OP_AND;
				break;
			case 'd':
				if (matches (begin, "def")) return TokenType.DEF;
				break;
			case 'f':
				if (matches (begin, "for")) return TokenType.FOR;
				break;
			case 'g':
				if (matches (begin, "get")) return TokenType.GET;
				break;
			case 'i':
				if (matches (begin, "isa")) return TokenType.ISA;
				break;
			case 'n':
				switch (begin[1]) {
				case 'e':
					if (matches (begin, "new")) return TokenType.NEW;
					break;
				case 'o':
					if (matches (begin, "not")) return TokenType.OP_NEG;
					break;
				}
				break;
			case 'o':
				if (matches (begin, "out")) return TokenType.OUT;
				break;
			case 'r':
				if (matches (begin, "ref")) return TokenType.REF;
				break;
			case 's':
				if (matches (begin, "set")) return TokenType.SET;
				break;
			case 't':
				if (matches (begin, "try")) return TokenType.TRY;
				break;
			case 'v':
				if (matches (begin, "var")) return TokenType.VAR;
				break;
			}
			break;
		case 4:
			switch (begin[0]) {
			case 'c':
				if (matches (begin, "case")) return TokenType.CASE;
				break;
			case 'e':
				switch (begin[1]) {
				case 'l':
					if (matches (begin, "else")) return TokenType.ELSE;
					break;
				case 'n':
					if (matches (begin, "enum")) return TokenType.ENUM;
					break;
				}
				break;
			case 'i':
				if (matches (begin, "init")) return TokenType.INIT;
				break;
			case 'l':
				if (matches (begin, "lock")) return TokenType.LOCK;
				break;
			case 'n':
				if (matches (begin, "null")) return TokenType.NULL;
				break;
			case 'p':
				switch (begin[1]) {
				case 'a':
					if (matches (begin, "pass")) return TokenType.PASS;
					break;
				case 'r':
					if (matches (begin, "prop")) return TokenType.PROP;
					break;
				}
				break;
			case 's':
				if (matches (begin, "self")) return TokenType.THIS;
				break;	
			case 't':
				if (matches (begin, "true")) return TokenType.TRUE;
				break;
			case 'u':
				if (matches (begin, "uses")) return TokenType.USES;
				break;
			case 'v':
				if (matches (begin, "void")) return TokenType.VOID;
				break;
			case 'w':
				switch (begin[1]) {
				case 'e':
					if (matches (begin, "weak")) return TokenType.WEAK;
					break;
				case 'h':
					if (matches (begin, "when")) return TokenType.WHEN;
					break;
				}
				break;
			}
			break;
		case 5:
			switch (begin[0]) {
			case 'b':
				if (matches (begin, "break")) return TokenType.BREAK;
				break;
			case 'c':
				switch (begin[1]) {
				case 'l':
					if (matches (begin, "class")) return TokenType.CLASS;
					break;
				case 'o':
					if (matches (begin, "const")) return TokenType.CONST;
					break;
				}
				break;
			case 'e':
				if (matches (begin, "event")) return TokenType.EVENT;
				break;
			case 'f':
				switch (begin[1]) {
				case 'a':
					if (matches (begin, "false")) return TokenType.FALSE;
					break;
				case 'i':
					if (matches (begin, "final")) return TokenType.FINAL;
					break;
				}
				break;
			case 'p':
				if (matches (begin, "print")) return TokenType.PRINT;
				break;
			case 's':
				if (matches (begin, "super")) return TokenType.SUPER;
				break;
			case 'r':
				if (matches (begin, "raise")) return TokenType.RAISE;
				break;
			case 'w':
				if (matches (begin, "while")) return TokenType.WHILE;
				break;
			}
			break;
		case 6:
			switch (begin[0]) {
			case 'a':
				if (matches (begin, "assert")) return TokenType.ASSERT;
				break;
			case 'd':
				switch (begin[1]) {
				case 'e':
					if (matches (begin, "delete")) return TokenType.DELETE;
					break;
				case 'o':
					if (matches (begin, "downto")) return TokenType.DOWNTO;
					break;
				}
				break;
			case 'e':
				switch (begin[1]) {
				case 'x':
					switch (begin[2]) {
					case 'c':
						if (matches (begin, "except")) return TokenType.EXCEPT;
						break;
					case 't':
						if (matches (begin, "extern")) return TokenType.EXTERN;
						break;
					}
					break;
				}
				break;
			case 'i':
				if (matches (begin, "inline")) return TokenType.INLINE;
				break;
			case 'p':
				if (matches (begin, "public")) return TokenType.PUBLIC;
				break;
			case 'r':
				switch (begin[1]) {
				case 'a':
					if (matches (begin, "raises")) return TokenType.RAISES;
					break;
				case 'e':
					if (matches (begin, "return")) return TokenType.RETURN;
					break;
				}
				break;
			case 's':
				switch (begin[1]) {
				case 'i':
					if (matches (begin, "sizeof")) return TokenType.SIZEOF;
					break;
				case 't':
					switch (begin[2]) {
					case 'a':
						if (matches (begin, "static")) return TokenType.STATIC;
						break;
					case 'r':
						if (matches (begin, "struct")) return TokenType.STRUCT;
						break;
					}
					break;
				}
				break;
			case 't':
				if (matches (begin, "typeof")) return TokenType.TYPEOF;
				break;
			}
			break;
		case 7:
			switch (begin[0]) {
			case 'd':
				switch (begin[1]) {
				case 'e':
					if (matches (begin, "default")) return TokenType.DEFAULT;
					break;
				case 'y':
					if (matches (begin, "dynamic")) return TokenType.DYNAMIC;
					break;
				}
				break;
			case 'e':
				if (matches (begin, "ensures")) return TokenType.ENSURES;
				break;
			case 'f':
				switch (begin[1]) {
				case 'i':
					if (matches (begin, "finally")) return TokenType.FINALLY;
					break;
				case 'o':
					if (matches (begin, "foreach")) return TokenType.FOREACH;
					break;
				}
				break;
			case 'p':
				if (matches (begin, "private")) return TokenType.PRIVATE;
				break;
			case 'v':
				if (matches (begin, "virtual")) return TokenType.VIRTUAL;
				break;
			}
			break;
		case 8:
			switch (begin[0]) {
			case 'a':
				if (matches (begin, "abstract")) return TokenType.ABSTRACT;
				break;
			case 'c':
				if (matches (begin, "continue")) return TokenType.CONTINUE;
				break;
			case 'd':
				if (matches (begin, "delegate")) return TokenType.DELEGATE;
				break;
			case 'o':
				if (matches (begin, "override")) return TokenType.OVERRIDE;
				break;
			case 'r':
				switch (begin[2]) {
				case 'a':
					if (matches (begin, "readonly")) return TokenType.READONLY;
					break;
				case 'q':
					if (matches (begin, "requires")) return TokenType.REQUIRES;
					break;
				}
				break;
			case 'v':
				if (matches (begin, "volatile")) return TokenType.VOLATILE;
				break;
			}
			break;
		case 9:
			switch (begin[0]) {
			case 'c':
				if (matches (begin, "construct")) return TokenType.CONSTRUCT;
				break;
			case 'e':
				if (matches (begin, "exception")) return TokenType.ERRORDOMAIN;
				break;
			case 'i':
				if (matches (begin, "interface")) return TokenType.INTERFACE;
				break;
			case 'n':
				if (matches (begin, "namespace")) return TokenType.NAMESPACE;
				break;
			case 'p':
				if (matches (begin, "protected")) return TokenType.PROTECTED;
				break;
			case 'w':
				if (matches (begin, "writeonly")) return TokenType.WRITEONLY;
				break;
			}
			break;

		}
		return TokenType.IDENTIFIER;
	}

	public TokenType read_token (out SourceLocation token_begin, out SourceLocation token_end) {
		/* emit dedents if outstanding before checking any other chars */

		if (pending_dedents > 0) {
			pending_dedents--;
			indent_level--;


			token_begin.pos = current;
			token_begin.line = line;
			token_begin.column = column;

			token_end.pos = current;
			token_end.line = line;
			token_end.column = column;

			last_token = TokenType.DEDENT;

			return TokenType.DEDENT;
		}


		/* scrub whitespace (excluding newlines) and comments */
		space ();

		/* handle line continuation */
		while (current < end && current[0] == '\\' && current[1] == '\n') {
			current += 2;
		}

		/* handle non-consecutive new line once parsing is underway - EOL */
		if (newline () && parse_started && last_token != TokenType.EOL && last_token != TokenType.SEMICOLON) {
			token_begin.pos = current;
			token_begin.line = line;
			token_begin.column = column;

			token_end.pos = current;
			token_end.line = line;
			token_end.column = column;

			last_token = TokenType.EOL;

			return TokenType.EOL;
		} 


		while (skip_newlines ()) {
			token_begin.pos = current;
			token_begin.line = line;
			token_begin.column = column;

			current_indent_level = count_tabs ();

			/* if its an empty new line then ignore */
			if (current_indent_level == -1)  {
				continue;
			} 

			if (current_indent_level > indent_level) {
				indent_level = current_indent_level;

				token_end.pos = current;
				token_end.line = line;
				token_end.column = column;

				last_token = TokenType.INDENT;

				return TokenType.INDENT;
			} else if (current_indent_level < indent_level) {
				indent_level--;

				pending_dedents = (indent_level - current_indent_level);

				token_end.pos = current;
				token_end.line = line;
				token_end.column = column;

				last_token = TokenType.DEDENT;

				return TokenType.DEDENT;
			}
		}

		TokenType type;
		char* begin = current;
		token_begin.pos = begin;
		token_begin.line = line;
		token_begin.column = column;

		int token_length_in_chars = -1;

		parse_started = true;

		if (current >= end) {
			if (indent_level > 0) {
				indent_level--;

				pending_dedents = indent_level;

				type = TokenType.DEDENT;
			} else {
				type = TokenType.EOF;
			}
		} else if (current[0].isalpha () || current[0] == '_') {
			int len = 0;
			while (current < end && is_ident_char (current[0])) {
				current++;
				len++;
			}
			type = get_identifier_or_keyword (begin, len);
		} else if (current[0] == '@') {
			int len = 0;
			if (current[1] == '@') {
				token_begin.pos += 2; // @@ is not part of the identifier
				current += 2;
			} else {
				current++;
				len = 1;
			}
			while (current < end && is_ident_char (current[0])) {
				current++;
				len++;
			}
			type = TokenType.IDENTIFIER;
		} else if (current[0].isdigit ()) {
			while (current < end && current[0].isdigit ()) {
				current++;
			}
			type = TokenType.INTEGER_LITERAL;
			if (current < end && current[0].tolower () == 'l') {
				current++;
				if (current < end && current[0].tolower () == 'l') {
					current++;
				}
			} else if (current < end && current[0].tolower () == 'u') {
				current++;
				if (current < end && current[0].tolower () == 'l') {
					current++;
					if (current < end && current[0].tolower () == 'l') {
						current++;
					}
				}
			} else if (current < end && current[0] == '.') {
				current++;
				while (current < end && current[0].isdigit ()) {
					current++;
				}
				if (current < end && current[0].tolower () == 'e') {
					current++;
					if (current < end && (current[0] == '+' || current[0] == '-')) {
						current++;
					}
					while (current < end && current[0].isdigit ()) {
						current++;
					}
				}
				if (current < end && current[0].tolower () == 'f') {
					current++;
				}
				type = TokenType.REAL_LITERAL;
			} else if (current < end && current == begin + 1
			           && begin[0] == '0' && begin[1] == 'x' && begin[2].isxdigit ()) {
				// hexadecimal integer literal
				current++;
				while (current < end && current[0].isxdigit ()) {
					current++;
				}
			} else if (current < end && is_ident_char (current[0])) {
				// allow identifiers to start with a digit
				// as long as they contain at least one char
				while (current < end && is_ident_char (current[0])) {
					current++;
				}
				type = TokenType.IDENTIFIER;
			}
		} else {
			switch (current[0]) {
			case '{':
				type = TokenType.OPEN_BRACE;
				current++;
				break;
			case '}':
				type = TokenType.CLOSE_BRACE;
				current++;
				break;
			case '(':
				type = TokenType.OPEN_PARENS;
				current++;
				break;
			case ')':
				type = TokenType.CLOSE_PARENS;
				current++;
				break;
			case '[':
				type = TokenType.OPEN_BRACKET;
				current++;
				break;
			case ']':
				type = TokenType.CLOSE_BRACKET;
				current++;
				break;
			case '.':
				type = TokenType.DOT;
				current++;
				if (current < end - 1) {
					if (current[0] == '.' && current[1] == '.') {
						type = TokenType.ELLIPSIS;
						current += 2;
					}
				}
				break;
			case ':':
				type = TokenType.COLON;
				current++;
				break;
			case ',':
				type = TokenType.COMMA;
				current++;
				break;
			case ';':
				type = TokenType.SEMICOLON;
				current++;
				break;
			case '#':
				type = TokenType.HASH;
				current++;
				break;
			case '?':
				type = TokenType.INTERR;
				current++;
				break;
			case '|':
				type = TokenType.BITWISE_OR;
				current++;
				if (current < end) {
					switch (current[0]) {
					case '=':
						type = TokenType.ASSIGN_BITWISE_OR;
						current++;
						break;
					case '|':
						type = TokenType.OP_OR;
						current++;
						break;
					}
				}
				break;
			case '&':
				type = TokenType.BITWISE_AND;
				current++;
				if (current < end) {
					switch (current[0]) {
					case '=':
						type = TokenType.ASSIGN_BITWISE_AND;
						current++;
						break;
					case '&':
						type = TokenType.OP_AND;
						current++;
						break;
					}
				}
				break;
			case '^':
				type = TokenType.CARRET;
				current++;
				if (current < end && current[0] == '=') {
					type = TokenType.ASSIGN_BITWISE_XOR;
					current++;
				}
				break;
			case '~':
				type = TokenType.TILDE;
				current++;
				break;
			case '=':
				type = TokenType.ASSIGN;
				current++;
				if (current < end) {
					switch (current[0]) {
					case '=':
						type = TokenType.OP_EQ;
						current++;
						break;
					case '>':
						type = TokenType.LAMBDA;
						current++;
						break;
					}
				}
				break;
			case '<':
				type = TokenType.OP_LT;
				current++;
				if (current < end) {
					switch (current[0]) {
					case '=':
						type = TokenType.OP_LE;
						current++;
						break;
					case '<':
						type = TokenType.OP_SHIFT_LEFT;
						current++;
						if (current < end && current[0] == '=') {
							type = TokenType.ASSIGN_SHIFT_LEFT;
							current++;
						}
						break;
					}
				}
				break;
			case '>':
				type = TokenType.OP_GT;
				current++;
				if (current < end && current[0] == '=') {
					type = TokenType.OP_GE;
					current++;
				}
				break;
			case '!':
				type = TokenType.OP_NEG;
				current++;
				if (current < end && current[0] == '=') {
					type = TokenType.OP_NE;
					current++;
				}
				break;
			case '+':
				type = TokenType.PLUS;
				current++;
				if (current < end) {
					switch (current[0]) {
					case '=':
						type = TokenType.ASSIGN_ADD;
						current++;
						break;
					case '+':
						type = TokenType.OP_INC;
						current++;
						break;
					}
				}
				break;
			case '-':
				type = TokenType.MINUS;
				current++;
				if (current < end) {
					switch (current[0]) {
					case '=':
						type = TokenType.ASSIGN_SUB;
						current++;
						break;
					case '-':
						type = TokenType.OP_DEC;
						current++;
						break;
					case '>':
						type = TokenType.OP_PTR;
						current++;
						break;
					}
				}
				break;
			case '*':
				type = TokenType.STAR;
				current++;
				if (current < end && current[0] == '=') {
					type = TokenType.ASSIGN_MUL;
					current++;
				}
				break;
			case '/':
				type = TokenType.DIV;
				current++;
				if (current < end && current[0] == '=') {
					type = TokenType.ASSIGN_DIV;
					current++;
				}
				break;
			case '%':
				type = TokenType.PERCENT;
				current++;
				if (current < end && current[0] == '=') {
					type = TokenType.ASSIGN_PERCENT;
					current++;
				}
				break;
			case '\'':
			case '"':
				if (begin[0] == '\'') {
					type = TokenType.CHARACTER_LITERAL;
				} else {
					type = TokenType.STRING_LITERAL;
				}
				token_length_in_chars = 2;
				current++;
				while (current < end && current[0] != begin[0]) {
					if (current[0] == '\\') {
						current++;
						token_length_in_chars++;
						if (current < end && current[0] == 'x') {
							// hexadecimal escape character
							current++;
							token_length_in_chars++;
							while (current < end && current[0].isxdigit ()) {
								current++;
								token_length_in_chars++;
							}
						} else {
							current++;
							token_length_in_chars++;
						}
					} else if (current[0] == '\n') {
						break;
					} else {
						unichar u = ((string) current).get_char_validated ((long) (end - current));
						if (u != (unichar) (-1)) {
							current += u.to_utf8 (null);
							token_length_in_chars++;
						} else {
							Report.error (new SourceReference (source_file, line, column + token_length_in_chars, line, column + token_length_in_chars), "invalid UTF-8 character");
						}
					}
				}
				if (current < end && current[0] != '\n') {
					current++;
				} else {
					Report.error (new SourceReference (source_file, line, column + token_length_in_chars, line, column + token_length_in_chars), "syntax error, expected %c".printf (begin[0]));
				}
				break;
			default:
				unichar u = ((string) current).get_char_validated ((long) (end - current));
				if (u != (unichar) (-1)) {
					current += u.to_utf8 (null);
					Report.error (new SourceReference (source_file, line, column, line, column), "syntax error, unexpected character");
				} else {
					current++;
					Report.error (new SourceReference (source_file, line, column, line, column), "invalid UTF-8 character");
				}
				column++;
				last_token = TokenType.STRING_LITERAL;
				return read_token (out token_begin, out token_end);
			}
		}

		if (token_length_in_chars < 0) {
			column += (int) (current - begin);
		} else {
			column += token_length_in_chars;
		}

		token_end.pos = current;
		token_end.line = line;
		token_end.column = column - 1;
		
		last_token = type;

		return type;
	}

	int count_tabs ()
	{
		int tab_count = 0;

		while (current < end && current[0] == '\t') {
			current++;
			column++;
			tab_count++;
		}


		/* ignore comments and whitspace and other lines that contain no code */

		space ();

		if ((current < end) && (current[0] == '\n')) return -1;

		return tab_count;
	}

	bool matches (char* begin, string keyword) {
		char* keyword_array = keyword;
		long len = keyword.len ();
		for (int i = 0; i < len; i++) {
			if (begin[i] != keyword_array[i]) {
				return false;
			}
		}
		return true;
	}

	bool whitespace () {
		bool found = false;
		while (current < end && current[0].isspace () && current[0] != '\n' ) {
			
			found = true;
			current++;
			column++;
		}
		return found;
	}

	inline bool newline () {
		if (current[0] == '\n') {
			return true;
		}

		return false;
	}

	bool skip_newlines () {
		bool new_lines = false;

		while (newline ()) {
			current++;

			line++;
			column = 1;
			current_indent_level = 0;

			new_lines = true;
		}

		return new_lines;
	}

	bool comment () {
		if (current > end - 2
		    || current[0] != '/'
		    || (current[1] != '/' && current[1] != '*')) {
			return false;
		}

		if (current[1] == '/') {
			// single-line comment
			current += 2;
			char* begin = current;
			// skip until end of line or end of file
			while (current < end && current[0] != '\n') {
				current++;
			}
			push_comment (((string) begin).ndup ((long) (current - begin)), line == 1);

			if (current[0] == '\n') {
				current++;
				line++;
				column = 1;
				current_indent_level = 0;
			}
		} else {
			// delimited comment
			current += 2;
			char* begin = current;
			int begin_line = line;
			while (current < end - 1
			       && (current[0] != '*' || current[1] != '/')) {
				if (current[0] == '\n') {
					line++;
					column = 0;
				}
				current++;
				column++;
			}
			if (current == end - 1) {
				Report.error (new SourceReference (source_file, line, column, line, column), "syntax error, expected */");
				return true;
			}
			push_comment (((string) begin).ndup ((long) (current - begin)), begin_line == 1);
			current += 2;
			column += 2;
		}

		return true;
	}

	void space () {
		while (whitespace () || comment ()) {
		}
	}

	void push_comment (string comment_item, bool file_comment) {
		if (_comment == null) {
			_comment = comment_item;
		} else {
			_comment = "%s\n%s".printf (_comment, comment_item);
		}
		if (file_comment) {
			source_file.comment = _comment;
			_comment = null;
		}
	}

	/**
	 * Clears and returns the content of the comment stack.
	 *
	 * @return saved comment
	 */
	public string? pop_comment () {
		if (_comment == null) {
			return null;
		}

		var result = new StringBuilder (_comment);
		_comment = null;

		weak string index;
		while ((index = result.str.chr (-1, '\t')) != null) {
			result.erase (result.str.pointer_to_offset (index), 1);
		}

		return result.str;
	}
}
