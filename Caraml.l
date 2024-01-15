%{

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <sys/types.h>

#alloc strdup_heap, strdup_alloc, strdup_realloc___UNUSED, strdup_dump
#hashfunc lex_hash___UNUSED

static char *heaply_strndup(char *string, size_t len) {
    char *alloc = (char*)strdup_alloc(len + 1);
    return memmove(&alloc[0], &string[0], len);
}

#define YYSCPY      yylval.string = heaply_strndup(&yytext[0], yyleng)

#define MAX_FILES   512

int yylex(void);
bool yywrap(void);
void yyerror(const char* message);
void print_current_position(void);

FILE *yyin = NULL;
int number_of_files = 0;
char *current_file_name = NULL;

static struct InputFiles {
    FILE *stream_buffer;
    char *file_name;
} INPUT_FILES[MAX_FILES];

int line_number = 0, column_number = 0;

%}

alnum_ident     [a-zA-Z_'][a-zA-Z0-9_']*
symb_ident      [-a-zA-Z_'!@#$%^&*+~`.]+
con_ident       [A-Z][a-z]*([A-Z][a-z]*)*

digit           [0-9]
binary_digit    [0-1]
hex_digit       [0-9a-fA-F]
oct_digit       [0-7]

blank           [ \t]
newline         [\n\r]
any_char        [^ \r\n\t]

%x COMMENT

%%

"module"            { column_number += yyleng; return MODULE; }
"where"             { column_number += yyleng; return WHERE; }
"end"               { column_number += yyleng; return END; }
"val"               { column_number += yyleng; return VAL; }
"type"              { column_number += yyleng; return TYPE; }
"datatype"          { column_number += yyleng; return DATATYPE; }
"record"            { column_number += yyleng; return RECORD; }
"of"                { column_number += yyleng; return OF; }
"fun"               { column_number += yyleng; return FUN; }
"match"             { column_number += yyleng; return MATCH; }
"with"              { column_number += yyleng; return WITH; }
"end"               { column_number += yyleng; return END; }
"if"                { column_number += yyleng; return IF; }
"then"              { column_number += yyleng; return THEN; }
"else"              { column_number += yyleng; return ELSE; }
"raise"             { column_number += yyleng; return RAISE; }
"try"               { column_number += yyleng; return TRY; }
"with"              { column_number += yyleng; return WITH; }
"record"            { column_number += yyleng; return RECORD; }
"nonfix"            { column_number += yyleng; return NONFIX; }
"in"                { column_number += yyleng; return IN; }
"infix"             { column_number += yyleng; return INFIX; }
"infixr"            { column_number += yyleng; return INFIXR; }
"import"            { column_number += yyleng; return IMPORT; }
"include"           { column_number += yyleng; return INCLUDE; }
"let"               { column_number += yyleng; return LET; }
"rec"               { column_number += yyleng; return REC; }
"open"              { column_number += yyleng; return OPEN; }
"failwith"          { column_number += yyleng; return FAILWITH; }
"when"              { column_number += yyleng; return WHEN; }
"do"                { column_number += yyleng; return DO; }
"unit"              { column_number += yyleng; return TYPE_UNIT; }
"bool"              { column_number += yyleng; return TYPE_BOOL; }
"->"                { column_number += yyleng; return ARROW; }
";;"                { column_number += yyleng; return DOUBLE_SEMI; }
"::"                { column_number += yyleng; return DOUBLE_COLON; }

{alnum_ident}        { column_number += yyleng; YYSCPY; return ALNUM_IDENT; }
{symb_ident}        { column_number += yyleng; YYSCPY; return SYMB_IDENT; }
{con_ident}         { column_number += yyleng; YYSCPY; return CON_IDENT; }
{hex_digit}+        { column_number += yyleng; YYSCPY; return HEX_INTEGER; }
{digit}+            { column_number += yyleng; YYSCPY; return DECIMAL_INTEGER; }
({binary_digit})+"B" { column_number += yyleng; YYSCPY; return BINARY_INTEGER; }
({oct_digit})+"O"   { column_number += yyleng; YYSCPY; return OCTAL_INTEGER; }
{hex_digit}+"H"     { column_number += yyleng; YYSCPY; return HEXADECIMAL_INTEGER; }

{digit}+"."{digit}+ { column_number += yyleng; YYSCPY; return FLOAT_LITERAL; }

["]([^"]+)["]       { column_number += yyleng; YYSCPY; return STRING_LITERAL; }
"#\""([^"]{1,2})["] { column_number += yyleng; YYSCPY; return CHARACTER_LITERAL; }

{blank}+            { column_number += yyleng; }
{newline}+          { line_number += yyleng; column_number = 0; }
";;".*              { column_number += yyleng; }

"(*"                { BEGIN(COMMENT); }
<COMMENT>.          { column_number++; }
<COMMENT>\n         { line_number++; column_number = 0; }
<COMMENT>"*)"       { BEGIN(INITIAL); }

{any_char}          { column_number++; return *yytext; }

<<EOF>>             yyterminate();

%%

void yyerror(const char *message) {
    fprintf(stderr, "Error occurred during scanning of %s: %s\n",
            current_file_name, message);
    print_current_position();
    exit(EXIT_FAILURE);
}

void print_current_position(void) {
    fprintf(stderr, "...At position: Line %d, Column %d\n",
            line_number, column_number);
}

int yywrap() {
    static int current_file_index = 0;
    if (current_file_index < number_of_files) {
        fclose(yyin);
        yyin = INPUT_FILES[current_file_index].stream_buffer;
        return false;
    } else {
        return true;
    }
}


