%{
/* C code and include statements can go here */
%}

/* Definitions */

letter           [a-zA-Z]
digit            [0-9]
hex_digit        [0-9A-Fa-f]
newline          \n
no_double_quote  [^\"]
no_newline       [^\n]
any_char         .

/* Rules */

%%

"module"            { return MODULE;   }
"where"             { return WHERE;    }
"end"               { return END;      }
"val"               { return VAL;      }
"type"              { return TYPE;     }
"datatype"          { return DATATYPE; }
"of"                { return OF;       }
"fun"               { return FUN;      }
"match"             { return MATCH;    }
"with"              { return WITH;     }
"end"               { return END;      }
"if"                { return IF;       }
"then"              { return THEN;     }
"else"              { return ELSE;     }
"raise"             { return RAISE;    }
"try"               { return TRY;      }
"with"              { return WITH;     }
"record"            { return RECORD;   }
"nonfix"            { return NONFIX;   }
"in"                { return IN;       }
"infix"             { return INFIX;    }
"infixr"            { return INFIXR;   }
"import"            { return IMPORT;   }
"let"               { return LET;      }
"op"		    { return OP;       }
"->"		    { return ARROW;    }


{letter}{alnum_identifier}  { return IDENTIFIER; 	  }
{hex_digit}+                { return HEX_INTEGER; 	  }
{digit}+                    { return DECIMAL_INTEGER; 	  }
({binary_digit})+"B" 	    { return BINARY_INTEGER; 	  }
([0-7])+ "O"         	    { return OCTAL_INTEGER; 	  }
{hex_digit}+"H"     	    { return HEXADECIMAL_INTEGER; }
{no_double_quote}+          { return STRING_LITERAL; 	  }

{newline}               { /* ignore newlines */ }
"(*".*"*)"              { /* ignore comments */ }
";;".*                  { /* ignore comments */ }

{any_char}              { /* catch-all for unrecognized characters */ }

%%

/* User code can be added here */

