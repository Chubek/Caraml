%{

int lineno = 0, charno = 0;

%}


alnum_ident	 [a-zA-Z_'][a-zA-Z0-9_']*
symb_ident 	 [-a-zA-Z_'!@#$%^&*+~`.]+
con_ident	 [A-Z][a-z]*([A-Z][a-z]*)*


digit 	 	 [0-9]
binary_digit 	 [0-1]
hex_digit 	 [0-9a-fA-F]
oct_digit 	 [0-7]

newline 	 [\n]
any_char 	 .

%x COMMENT

%%

"module"            {  charno += yyleng; return MODULE;   }
"where"             {  charno += yyleng; return WHERE;    }
"end"               {  charno += yyleng; return END;      }
"val"               {  charno += yyleng; return VAL;      }
"type"              {  charno += yyleng; return TYPE;     }
"datatype"          {  charno += yyleng; return DATATYPE; }
"of"                {  charno += yyleng; return OF;       }
"fun"               {  charno += yyleng; return FUN;      }
"match"             {  charno += yyleng; return MATCH;    }
"with"              {  charno += yyleng; return WITH;     }
"end"               {  charno += yyleng; return END;      }
"if"                {  charno += yyleng; return IF;       }
"then"              {  charno += yyleng; return THEN;     }
"else"              {  charno += yyleng; return ELSE;     }
"raise"             {  charno += yyleng; return RAISE;    }
"try"               {  charno += yyleng; return TRY;      }
"with"              {  charno += yyleng; return WITH;     }
"record"            {  charno += yyleng; return RECORD;   }
"nonfix"            {  charno += yyleng; return NONFIX;   }
"in"                {  charno += yyleng; return IN;       }
"infix"             {  charno += yyleng; return INFIX;    }
"infixr"            {  charno += yyleng; return INFIXR;   }
"import"            {  charno += yyleng; return IMPORT;   }
"let"               {  charno += yyleng; return LET;      }
"op"		    {  charno += yyleng; return OP;       }
"->"		    {  charno += yyleng; return ARROW;    }


{alnum_ident}		 {  charno += yyleng; return ALNUM_IDENT;         }
{symb_ident}		 {  charno += yyleng; return SYMB_IDENT;          }
{con_ident}		 {  charno += yyleng; return CON_IDENT;           }
{hex_digit}+             {  charno += yyleng; return HEX_INTEGER; 	  }
{digit}+                 {  charno += yyleng; return DECIMAL_INTEGER; 	  }
({binary_digit})+"B" 	 {  charno += yyleng; return BINARY_INTEGER; 	  }
({oct_digit})+"O"        {  charno += yyleng; return OCTAL_INTEGER; 	  }
{hex_digit}+"H"     	 {  charno += yyleng; return HEXADECIMAL_INTEGER; }

{digit}+"."{digit}+	 {  charno += yyleng; return FLOAT_LITERAL;	  }

["]([^"]+)["]		 {  charno += yyleng; return STRING_LITERAL;	  }
"#\""([^"]{1,2})["]	 {  charno += yyleng; return CHARACTER_LITERAL;	  }


{newline}               {  lineno++;	      }
";;".*                  {  charno += yyleng;  }

"(*"		 	{ BEGIN(COMMENT);     }
<COMMENT>.		{ charno++;	      }
<COMMENT>\n		{ lineno++;	      }
<COMMENT>"*)"		{ BEGIN(INITIAL);     }

{any_char}		return *yytext;

%%

/* User code can be added here */

