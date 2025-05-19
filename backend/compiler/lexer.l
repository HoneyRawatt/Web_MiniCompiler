%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

// Forward declarations
void yyerror(char *);
int yylex(void);

// Include the generated parser header
#include "parser.tab.h"
%}

%%
[ \t]           ; /* ignore whitespace */
[\n]            { yylineno++; }
"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"for"           { return FOR; }
"return"        { return RETURN; }
"int"           { return INT; }
"char"          { return CHAR; }
"void"          { return VOID; }
"main"          { return MAIN; }
"scanf"         { return SCANF; }
"printf"        { return PRINTF; }
"=="            { return EQ; }
"!="            { return NEQ; }
"<"             { return LT; }
">"             { return GT; }
"<="            { return LTE; }
">="            { return GTE; }
"&&"            { return AND; }
"||"            { return OR; }
"!"             { return NOT; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return TIMES; }
"/"             { return DIVIDE; }
"%"             { return MOD; }
"("             { return LPAREN; }
")"             { return RPAREN; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
";"             { return SEMICOLON; }
"="             { return EQUALS; }
","             { return COMMA; }
"&"             { return ADDRESS; }
[0-9]+          { yylval.num = atoi(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]*  { 
    yylval.id = strdup(yytext);
    return ID;
}
\"[^\"]*\"      { yylval.str = strdup(yytext); return STRING; }
"//".*          ; /* ignore comments */
.               { printf("Unexpected character: %s\n", yytext); }
%%

int yywrap(void) {
    return 1;
} 