%{
#include <stdio.h>
%}

%token MODULE WHERE END VAL TYPE DATATYPE OF FUN MATCH WITH IF THEN ELSE RAISE TRY RECORD NONFIX IN INFIX INFIXR IMPORT LET IDENTIFIER HEX_INTEGER DECIMAL_INTEGER BINARY_INTEGER OCTAL_INTEGER HEXADECIMAL_INTEGER STRING_LITERAL OP ARROW CHARACTER_LITERAL SYMB_IDENTIFIER ALNUM_IDENTIFIER CON_IDENTIFIER FAILWITH TYPE_INT TYPE_FLOAT TYPE_CHAR TYPE_STRING TYPE_LIST TYPE_BOOL

%%

module               : /* empty */
		     | MODULE ALNUM_IDENTIFIER WHERE toplevel_decls END ';'
		     ;

toplevel_decls       : toplevel_decls toplevel_decl
		     | toplevel_decl

toplevel_decl        : value_decl
                     | type_decl
                     | datatype_decl
                     | infix_decl
                     | import_decl
                     ;

value_decl           : VAL ALNUM_IDENTIFIER '=' expr ';'
		     ;

import_decl          : IMPORT long_identifier ';'
		     ;

type_decl            : TYPE ALNUM_IDENTIFIER '=' type_exp ';'
		     ;

datatype_decl        : DATATYPE ALNUM_IDENTIFIER '=' constructor_list ';'
		     ;

constructor_list     : constructor '|' constructor_list
                     | constructor
		     ;

constructor          : CON_IDENTIFIER OF type_exp
		     ;

expr                 : pattern_list
                     | let_binding IN expr
                     | IF expr THEN expr ELSE expr
                     | match_expression
                     | function_expression
		     | FAILWITH expr
		     | RAISE expr
                     | TRY expr WITH match_expression
                     | record_literal
                     | '(' expr ')'
		     ;

let_binding          : LET pattern '=' expr in_expr_opt

in_expr_opt	     : /* empty */
		     | IN expr

infix_decl           : INFIX digit_opt alnum_ident_opt infix_operator
                     | INFIXR digit_opt alnum_ident_opt infix_operator
                     | NONFIX infix_operator

digit_opt	     : /* empty */
	       	     | '0'
		     | '1' 
		     | '2'
		     | '3'
		     | '4'
		     | '5'
		     | '6'
		     | '7'
		     | '8'
		     | '9'

alnum_ident_opt	     : /* empty */
		     | ALNUM_IDENTIFIER
		     ;

match_expression     : MATCH expr WITH match_clauses END
		     ;

match_clauses        : match_clause '|' match_clauses
                     | match_clause
		     ;

match_clause         : pattern ARROW expr
		     ;

function_expression  : FUN pattern ARROW expr
		     ;

type_exp             : type_atom
                     | type_atom ARROW type_exp
                     | basic_type
                     | polymorphic_type type_exp
                     | tuple_type
		     ;

tuple_type           : type_exp '*' type_exp
                     | type_exp
		     ;

type_atom            : ALNUM_IDENTIFIER
                     | '(' type_exp ')'
                     | type_atom ALNUM_IDENTIFIER
                     | record_type
		     ;

basic_type           : TYPE_INT
                     | TYPE_FLOAT
                     | TYPE_CHAR
                     | TYPE_STRING
                     | TYPE_BOOL
                     | TYPE_LIST
		     ;

polymorphic_type     : '`' ALNUM_IDENTIFIER
		     ;

record_type          : '{' field_list '}'
		     ;

field_list           : field ',' field_list
                     | field
		     ;

field                : ALNUM_IDENTIFIER ':' type_exp
		     ;

record_literal       : '{' field_bindings '}'
		     ;

field_bindings       : field_binding ',' field_bindings
                     | field_binding
		     ;

field_binding        : ALNUM_IDENTIFIER '=' expr
		     ;

pattern_list         : pattern '|' pattern_list
                     | pattern
		     ;

pattern              : pattern_constructor
                     | identifier_pattern
                     | literal_pattern
                     | wildcard_pattern
                     | '(' pattern_list ')'
                     | record_pattern
		     ;

pattern_constructor  : CON_IDENTIFIER pattern_list
		     ;

pattern_list         : pattern_single '|' pattern_list
                     | pattern_single
		     ;

pattern_single       : identifier infix_expr
                     | list_pattern
		     ;

record_pattern       : '{' field_patterns '}'
field_patterns       : field_pattern ',' field_patterns
                     | field_pattern
		     ;

field_pattern        : ALNUM_IDENTIFIER '=' pattern
		     ;

identifier_pattern   : ALNUM_IDENTIFIER
                     | long_identifier
		     ;

literal_pattern      : literal_value
		     ;

wildcard_pattern     : '_'
		     ;

infix_expr           : primary_expr infix_operator infix_expr
		     | primary_expr
		     ;

primary_expr         : identifier
                     | literal_value
                     | CON_IDENTIFIER primary_expr
                     | '(' primary_expr ')'
                     | prefix_operator primary_expr
		     ;

prefix_operator      : SYMB_IDENTIFIER
		     ;

infix_operator       : OP SYMB_IDENTIFIER
                     | SYMB_IDENTIFIER
		     ;

identifier	     : SYMB_IDENTIFIER
		     | ALNUM_IDENTIFIER
		     | CON_IDENTIFIER
		     | long_identifier
		     ;

long_identifier	     : ALNUM_IDENTIFIER '.' long_identifier
		     | ALNUM_IDENTIFIER

list_literal	     : '[' literal_value_list ']'

literal_value_list   : literal_value DOUBLE_SEMI literal_value_list
		     | literal_value
		     ;

literal_value	     : DECIMAL_INTEGER
		     | HEXADECIMAL_INTEGER
		     | OCTAL_INTEGER
		     | BINARY_INTEGER
		     | FLOAT_LITERAL
		     | STRING_LITERAL
		     | CHARACTER_LITERAL
		     | list_literal
		     ;

%%

/* User code can be added here */

