%{


%}

%union {
    char *string;
}

%token <string> ALNUM_IDENT SYMB_IDENT CON_IDENT HexInteger DECIMAL_INTEGER BINARY_INTEGER OCTAL_INTEGER HEXADCIMAL_INTEGER
%token <string> FLOAT_LITERAL STRING_LITERAL CHARACTER_LITERAL



%%

CaramlProgram:        Module
                     | ToplevelDecls
                     ;

Module:              MODULE ALNUM_IDENT WHERE ToplevelDecls END
                     ;

ToplevelDecls:      ToplevelDecl
                     | Expression
                     ;

ToplevelDecl:       ValueDecl
                     | TypeDecl
                     | DatatypeDecl
                     | InfixDecl
                     | ImportDecl
                     | IncludeDecl
                     ;

LocalDecls:         LocalDecl
                     | Expression
                     ;

LocalDecl:          ValueDecl
                     | TypeDecl
                     | DatatypeDecl
                     | InfixDecl
                     | OpenDecl
                     ;

ValueDecl:          VAL ALNUM_IDENT '=' ExpressionList DOUBLE_SEMI
                     ;

OpenDecl:           OPEN ALNUM_IDENT DOUBLE_SEMI
                     ;

ImportDecl:         IMPORT ALNUM_IDENT DOUBLE_SEMI
                     ;

IncludeDecl:        INCLUDE STRING_LITERAL DOUBLE_SEMI
                     ;

TypeDecl:           TYPE ALNUM_IDENT '=' TypeExpression DOUBLE_SEMI
                     ;

DatatypeDecl:       DATATYPE ALNUM_IDENT '=' ConstructorList DOUBLE_SEMI
                     ;

RecordDecl:         RECORD ALNUM_IDENT '=' RecordType DOUBLE_SEMI
                     ;

InfixDecl:          INFIX DecimalIntegerOpt AlnumIdentOpt InfixOperator DOUBLE_SEMI
                     | INFIXR DecimalIntegerOpt AlnumIdentOpt InfixOperator DOUBLE_SEMI
                     | NONFIX InfixOperator DOUBLE_SEMI
                     ;

AlnumIdentOpt:      ALNUM_IDENTIFIER
	             |;

DecimalIntegerOpt:  DECIMAL_INTEGER
		     | ;

ExpressionList:     Expression
	             | Expression '|' ExpressionList
                     ;

Expression:         PatternList
                     | LetBinding
                     | LocalBinding
                     | ForBinding
                     | IfBinding
                     | WhileBinding
                     | WhenBinding
                     | LocalBinding
                     | TryBinding
                     | AssignBinding
                     | RaiseBinding
                     | FailwithBinding
                     | MatchExpression
                     | FunctionExpression
                     | InfixExpression
                     | PrefixExpression
                     | '(' Expression ')'
                     ;

FailwithBinding:    FAILWITH Expression
                     ;

RaiseBinding:       RAISE Expression
                     ;

AssignBinding:      ALNUM_IDENT BACK_ARROW Expression
                     ;

TryBinding:         TRY ExpressionList WITH MatchExpression
                     ;

ForBinding:         FOR Pattern IN Expression DO ExpressionList END
                     ;

WhenBinding:        WHEN Pattern DO ExpressionList END
                     ;

WhileBinding:       WHILE Pattern DO ExpressionList END
                     ;

IfBinding:          IF Pattern THEN ExpressionList ELSE ExpressionList END
                     ;

LetBinding:         LET REC_OPT Pattern '=' ExpressionList InExpressionOpt
                     ;

RecOpt:             REC
                     |;

LocalBinding:       LOCAL LocalDecls IN ExpressionList END
                     ;

MatchExpression:    MATCH Expression WITH MatchClauses END
                     ;

MatchClauses:       MatchClause
	             | MatchClause '|' MatchClauses
                     ;

MatchClause:        Pattern ARROW Expression
                     ;

FunctionExpression: FUN Pattern ARROW Expression
                     ;

PrefixExpression:   SYMB_IDENT Expression
                     ;

InfixExpression:    Expression
	             | Expression InfixOperator InfixExpression
                     ;

ConstructorList:    Constructor
	             | Constructor '|' ConstructorList
                     ;

Constructor:        CON_IDENT OF TypeExpression
                     ;

TypeExpression:     TypeAtom
                     | TypeAtom ARROW TypeExpression
                     | PolymorphicType TypeExpression
                     | TupleType
                     ;

TupleType:          TypeExpression
	             | TypeExpression '*' TupleType
                     ;

TypeAtom:           ALNUM_IDENT
                     | '(' TypeExpression ')'
                     | TypeAtom ALNUM_IDENT
                     | BasicType
                     ;

PolymorphicType:    '`' ALNUM_IDENT
                     ;

RecordType:         '{' FieldList '}'
                     ;

FieldList:          Field
	 	     | Field ';' FieldList
                     ;

Field:               ALNUM_IDENT ':' TypeExpression
                     ;

RecordLiteral:      '{' FieldBindings '}'
                     ;

FieldBindings:      FieldBinding 
	             | FieldBinding ',' FieldBindings
                     ;

FieldBinding:       ALNUM_IDENT '=' Expression
                     ;

Pattern:             PatternConstructor
                     | IdentifierPattern
                     | LiteralPattern
                     | WildcardPattern
                     | ListPattern
                     | InductivePattern
                     | '(' PatternList ')'
                     | UnitPattern
                     | TuplePattern
                     ;

PatternConstructor: CON_IDENT PatternList
                     ;

UnitPattern:        UNIT_LITERAL
                     ;

PatternList:        PatternSingle
	             | PatternSingle '|' PatternList
                     ;

PatternSingle:      Identifier InfixExpression
                     | ListPattern
                     ;

TuplePattern:       '(' ListPatternItem ')'
                     ;

ListPattern:        '[' ListPatternItem ']'
                     ;


ListPatternItem:    TypeExpression
	             | TypeExpression DOUBLE_COLON ListPatternItem
	           
	            

TuplePattern:       '(' Identifier ':' TypeExpression ')'
                     ;

InductivePattern:   Identifier 
                     | Identifier DOUBLE_COLON InductivePattern
                     ;

IdentifierPattern:  Identifier
		     | Identifier IdentifierPattern
                     ;

LiteralPattern:     LiteralValue
                     ;

WildcardPattern:    '_'
                     ;

Identifier:         ALNUM_IDENT
                     | SYMB_IDENT
                     | CON_IDENT
		     | LongIdentifier
                     ;

LongIdentifer:      Identifier
	             | Identifier '.' LongIdentifier
		     ;

LiteralValue:      IntegerLiteral
                     | STRING_LITERAL
                     | CHARACTER_LITERAL
                     | FLOAT_LITERAL
                     | ListLiteral
                     | TupleLiteral
                     | RecordLiteral
                     ;

TupleLiteral:      '(' TupleItemList ')'
	    	    ;

TupleItemList:     TupleItem
		     | TupleItem DOUBLE_COLON TupleItemList
                     ;

TupleItem:         LiteralValue
	 	     | Identifier
		     ;


ListLiteral:        '[' ListItemList ']'
                     ;

ListItemList:      ListItem 
	    	     | ListItem DOUBLE_SEMI ListItemList
                     ;

ListItem:          LiteralValue
                     | Identifier
                     ;

IntegerLiteral:    DECIMAL_INTEGER
                     | OCTAL_INTEGER
                     | HEXADCIMAL_INTEGER
                     | BINARY_INTEGER
                     ;

BasicType:         TYPE_INT
                     | TYPE_FLOAT
                     | TYPE_CHAR
                     | TYPE_STRING
                     | TYPE_BOOL
                     | TYPE_LIST
                     | TYPE_UNIT
                     | TYPE_TUPLE
                     ;


InfixOperator:     SYMB_IDENTIFIER
	             | ALNUM_IDENTIFIER
		     ;

%%

