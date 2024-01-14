%{
/* C code and include statements can go here */
#include <stdio.h>
%}

/* Token definitions */
%token MODULE WHERE END VAL TYPE DATATYPE OF FUN MATCH WITH IF THEN ELSE RAISE TRY RECORD NONFIX IN INFIX INFIXR IMPORT LET IDENTIFIER HEX_INTEGER DECIMAL_INTEGER BINARY_INTEGER OCTAL_INTEGER HEXADECIMAL_INTEGER STRING_LITERAL OP ARROW

/* Grammar rules */
%%

module               : /* empty */
		     | MODULE alnum_identifier WHERE toplevel_decls END

toplevel_decls       : toplevel_decl
                     | toplevel_decls toplevel_decl

toplevel_decl        : value_decl
                     | type_decl
                     | datatype_decl
                     | infix_decl
                     | import_decl
                     | comment

value_decl           : VAL alnum_identifier '=' expr ';'

import_decl          : IMPORT long_identifier ';'

type_decl            : TYPE alnum_identifier '=' type_exp ';'

datatype_decl        : DATATYPE alnum_identifier '=' constructor_list ';'
constructor_list     : constructor '|' constructor_list
                     | constructor

constructor          : con_identifier OF type_exp

expr                 : pattern_list
                     | let_binding IN expr
                     | IF expr THEN expr ELSE expr
                     | match_expression
                     | function_expression
                     | RAISE expr
                     | TRY expr WITH match_expression
                     | record_literal
                     | '(' expr ')'

let_binding          : LET pattern '=' expr IN expr

infix_decl           : INFIX decimal_digit identifier infix_operator
                     | INFIXR decimal_digit identifier infix_operator
                     | NONFIX infix_operator

match_expression     : MATCH expr WITH match_clauses END
match_clauses        : match_clause '|' match_clauses
                     | match_clause

match_clause         : pattern ARROW expr

function_expression  : FUN pattern ARROW expr

type_exp             : type_atom
                     | type_atom ARROW type_exp
                     | basic_type
                     | polymorphic_type type_exp
                     | tuple_type

tuple_type           : type_exp '*' type_exp
                     | type_exp

type_atom            : alnum_identifier
                     | '(' type_exp ')'
                     | type_atom alnum_identifier
                     | record_type

basic_type           : "int"
                     | "float"
                     | "char"
                     | "string"
                     | "bool"
                     | "list"

polymorphic_type     : "'" alnum_identifier

record_type          : '{' field_list '}'
field_list           : field ',' field_list
                     | field

field                : alnum_identifier ':' type_exp

record_literal       : '{' field_bindings '}'
field_bindings       : field_binding ',' field_bindings
                     | field_binding

field_binding        : alnum_identifier '=' expr

pattern_list         : pattern '|' pattern_list
                     | pattern

pattern              : pattern_constructor
                     | identifier_pattern
                     | literal_pattern
                     | wildcard_pattern
                     | list_pattern
                     | '(' pattern_list ')'
                     | record_pattern

pattern_constructor  : con_identifier pattern_list

pattern_list         : pattern_single '|' pattern_list
                     | pattern_single

pattern_single       : identifier infix_expr
                     | list_pattern

record_pattern       : '{' field_patterns '}'
field_patterns       : field_pattern ',' field_patterns
                     | field_pattern

field_pattern        : alnum_identifier '=' pattern

identifier_pattern   : alnum_identifier
                     | long_identifier

literal_pattern      : integer_literal
                     | string_literal
                     | character_literal

wildcard_pattern     : '_'

infix_expr           : primary_expr infix_operator primary_expr

primary_expr         : identifier
                     | literal_value
                     | con_identifier primary_expr
                     | '(' primary_expr ')'
                     | prefix_operator primary_expr

prefix_operator      : symb_identifier
infix_operator       : OP symb_identifier
                     | symb_identifier

%%

/* User code can be added here */

