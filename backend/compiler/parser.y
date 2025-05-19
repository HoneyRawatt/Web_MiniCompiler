%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

void yyerror(char *);
int yylex(void);

ASTNode* create_node(char* type, char* value);
ASTNode* create_binary_node(char* type, ASTNode* left, ASTNode* right);
void free_ast(ASTNode* node);
void print_ast(ASTNode* node, int level);
%}

%union {
    int num;
    char* id;
    char* str;
    ASTNode* node;
}

%token <num> NUMBER
%token <id> ID
%token <str> STRING
%token IF ELSE WHILE FOR RETURN
%token INT CHAR VOID MAIN
%token SCANF PRINTF
%token PLUS MINUS TIMES DIVIDE MOD
%token LPAREN RPAREN LBRACE RBRACE
%token SEMICOLON EQUALS COMMA
%token EQ NEQ LT GT LTE GTE
%token AND OR NOT
%token ADDRESS

%type <node> program function_list function type param_list param
%type <node> statement_list statement declaration assignment
%type <node> if_statement while_statement return_statement
%type <node> expression term factor

%%

program: function_list { $$ = $1; }
;

function_list: function { $$ = $1; }
    | function_list function { 
        ASTNode* current = $1;
        while (current->next) current = current->next;
        current->next = $2;
        $$ = $1;
    }
;

function: type ID LPAREN param_list RPAREN LBRACE statement_list RBRACE {
    $$ = create_node("function", $2);
    $$->left = $1;
    $$->right = $4;
    $$->next = $7;
}
;

type: INT { $$ = create_node("type", "int"); }
    | CHAR { $$ = create_node("type", "char"); }
    | VOID { $$ = create_node("type", "void"); }
;

param_list: param { $$ = $1; }
    | param_list COMMA param {
        ASTNode* current = $1;
        while (current->next) current = current->next;
        current->next = $3;
        $$ = $1;
    }
    | /* empty */ { $$ = NULL; }
;

param: type ID {
    $$ = create_node("param", $2);
    $$->left = $1;
}
;

statement_list: statement { $$ = $1; }
    | statement_list statement {
        ASTNode* current = $1;
        while (current->next) current = current->next;
        current->next = $2;
        $$ = $1;
    }
;

statement: declaration { $$ = $1; }
    | assignment { $$ = $1; }
    | if_statement { $$ = $1; }
    | while_statement { $$ = $1; }
    | return_statement { $$ = $1; }
;

declaration: type ID SEMICOLON {
    $$ = create_node("declaration", $2);
    $$->left = $1;
}
    | type ID EQUALS expression SEMICOLON {
    $$ = create_node("declaration", $2);
    $$->left = $1;
    $$->right = $4;
}
;

assignment: ID EQUALS expression SEMICOLON {
    $$ = create_node("assignment", $1);
    $$->right = $3;
}
;

if_statement: IF LPAREN expression RPAREN LBRACE statement_list RBRACE {
    $$ = create_node("if", NULL);
    $$->left = $3;
    $$->right = $6;
}
    | IF LPAREN expression RPAREN LBRACE statement_list RBRACE ELSE LBRACE statement_list RBRACE {
    $$ = create_node("if-else", NULL);
    $$->left = $3;
    $$->right = create_node("if-body", NULL);
    $$->right->left = $6;
    $$->right->right = $10;
}
;

while_statement: WHILE LPAREN expression RPAREN LBRACE statement_list RBRACE {
    $$ = create_node("while", NULL);
    $$->left = $3;
    $$->right = $6;
}
;

return_statement: RETURN expression SEMICOLON {
    $$ = create_node("return", NULL);
    $$->right = $2;
}
    | RETURN SEMICOLON {
    $$ = create_node("return", NULL);
}
;

expression: term { $$ = $1; }
    | expression PLUS term { $$ = create_binary_node("+", $1, $3); }
    | expression MINUS term { $$ = create_binary_node("-", $1, $3); }
;

term: factor { $$ = $1; }
    | term TIMES factor { $$ = create_binary_node("*", $1, $3); }
    | term DIVIDE factor { $$ = create_binary_node("/", $1, $3); }
;

factor: NUMBER { $$ = create_node("number", NULL); $$->value = malloc(20); sprintf($$->value, "%d", $1); }
    | ID { $$ = create_node("id", $1); }
    | LPAREN expression RPAREN { $$ = $2; }
;

%%

ASTNode* create_node(char* type, char* value) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = strdup(type);
    node->value = value ? strdup(value) : NULL;
    node->left = node->right = node->next = NULL;
    return node;
}

ASTNode* create_binary_node(char* type, ASTNode* left, ASTNode* right) {
    ASTNode* node = create_node(type, NULL);
    node->left = left;
    node->right = right;
    return node;
}

void free_ast(ASTNode* node) {
    if (node) {
        free_ast(node->left);
        free_ast(node->right);
        free_ast(node->next);
        free(node->type);
        if (node->value) free(node->value);
        free(node);
    }
}

void print_ast(ASTNode* node, int level) {
    if (!node) return;
    
    for (int i = 0; i < level; i++) printf("  ");
    printf("%s", node->type);
    if (node->value) printf(": %s", node->value);
    printf("\n");
    
    print_ast(node->left, level + 1);
    print_ast(node->right, level + 1);
    print_ast(node->next, level);
}

void yyerror(char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(void) {
    ASTNode* ast = NULL;
    yyparse();
    if (ast) {
        print_ast(ast, 0);
        free_ast(ast);
    }
    return 0;
} 