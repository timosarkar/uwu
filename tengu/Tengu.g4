grammar Tengu;

prog: statement* EOF;

statement
    : importStmt
    | funcDecl
    | structDecl
    ;

importStmt: 'import' STRING ;
funcDecl: IDENT ':' 'func' '(' paramList? ')' returnType block ;
paramList: param (',' param)* ;
param: IDENT ':' IDENT ;
returnType: IDENT ;
structDecl: IDENT ':' 'struct' '{' structFields '}' ;
structFields: structField* ;
structField: IDENT ':' IDENT ;
block: '{' stmt* '}' ;
stmt: IDENT '(' IDENT ')' ; // only supports simple function call

// Lexer rules
IDENT  : [a-zA-Z_][a-zA-Z0-9_]* ;
STRING : '"' .*? '"' ;
WS     : [ \t\r\n]+ -> skip ;