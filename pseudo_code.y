%{
#define YYDEBUG 1
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void generate_code(const char* code);
void yyerror(const char *s);
int yylex();

#define MAX_IDS 100
char* identifiers[MAX_IDS]; int identifier_count = 0;
char* local_identifiers[MAX_IDS]; int local_identifier_count = 0;
char* input_vars[MAX_IDS]; int input_var_count = 0;

void store_identifier(char* id, int local) {
    if (local) {
        if (local_identifier_count < MAX_IDS)
            local_identifiers[local_identifier_count++] = strdup(id);
    } else {
        if (identifier_count < MAX_IDS)
            identifiers[identifier_count++] = strdup(id);
    }
}
void store_input_var(char* id) {
    if (input_var_count < MAX_IDS)
        input_vars[input_var_count++] = strdup(id);
}
void free_identifiers(int local) {
    int i;
    if (local) {
        for (i = 0; i < local_identifier_count; i++)
            free(local_identifiers[i]);
        local_identifier_count = 0;
    } else {
        for (i = 0; i < identifier_count; i++)
            free(identifiers[i]);
        identifier_count = 0;
    }
}
void free_input_vars() {
    int i;
    for (i = 0; i < input_var_count; i++)
        free(input_vars[i]);
    input_var_count = 0;
}

%}

%union {
    char* str;
    int num;
}

%token <str> IDENTIFIER
%token <num> NUMBER
%token START END DECLARE INPUT PRINT EQUAL FUNCTION RETURN IF ELSE WHILE DO FOR
%token '(' ')' '{' '}' ',' ';' '+' '-' '*' '/'
%token LT GT LE GE EQ NE

%left '+' '-'
%left '*' '/'
%left LT GT LE GE EQ NE

%type <str>
    identifier param_list param_defs expression function_call 
    arg_list arg_values opt_else for_init for_iter for_condition 
    statement statement_list print_list
    while_statement for_statement do_while_statement
    function_body
%type <num> number input_list global_identifier_list local_identifier_list local_declarations

%%

program: START main_declarations inputs statement_list END {
    generate_code($4);
    free($4);
    generate_code("    return 0;\n}\n");
    free_identifiers(0);
    free_input_vars();
} functions
;

main_declarations:
    DECLARE global_identifier_list {
        generate_code("#include <stdio.h>\n\nint main() {");
        int i;
        for (i = 0; i < identifier_count; i++) {
            char code[100];
            snprintf(code, sizeof(code), "    int %s = 0;", identifiers[i]);
            generate_code(code);
        }
    }
    ;

global_identifier_list:
      identifier {
        store_identifier($1, 0);
        free($1);
        $$ = 1;
      }
    | global_identifier_list ',' identifier {
        store_identifier($3, 0);
        free($3);
        $$ = $1 + 1;
      }
    ;

functions:
    functions function_def
    | /* empty */
    ;

function_def:
    FUNCTION IDENTIFIER '(' param_list ')' {
        char code[256];
        snprintf(code, sizeof(code), "int %s(%s) {", $2, $4);
        generate_code(code);
        free($2);
        free($4);
        local_identifier_count = 0;
    }
    function_body {
        generate_code($7); // <--- ADD THIS
        generate_code("}");
        free($7); // <--- ADD THIS
        free_identifiers(1);
    }
    

param_list:
      /* empty */       { $$ = strdup(""); }
    | param_defs        { $$ = $1; }
    ;

param_defs:
      identifier {
        char *tmp = (char*)malloc(strlen("int ") + strlen($1) + 1);
        sprintf(tmp, "int %s", $1);
        store_identifier($1, 1);
        free($1);
        $$ = tmp;
      }
    | param_defs ',' identifier {
        char *tmp = (char*)malloc(strlen($1) + strlen(", int ") + strlen($3) + 1);
        sprintf(tmp, "%s, int %s", $1, $3);
        store_identifier($3, 1);
        free($1); free($3);
        $$ = tmp;
      }
    ;

function_body:
    local_declarations statement_list {
        int len = strlen($2 ? $2 : "") + 2;
        char *buf = malloc(len);
        sprintf(buf, "%s", $2 ? $2 : "");
        $$ = buf;
    }
;

local_declarations:
      /* empty */ { $$ = 0; }
    | local_declarations DECLARE local_identifier_list {
        int i;
        for (i = local_identifier_count - $3; i < local_identifier_count; i++) {
            char code[100];
            snprintf(code, sizeof(code), "    int %s = 0;", local_identifiers[i]);
            generate_code(code);
        }
        $$ = $1 + $3;
    }
    ;

local_identifier_list:
      identifier {
        store_identifier($1, 1);
        free($1);
        $$ = 1;
      }
    | local_identifier_list ',' identifier {
        store_identifier($3, 1);
        free($3);
        $$ = $1 + 1;
      }
    ;

inputs:
      inputs INPUT input_list {
        int i;
        for (i = 0; i < input_var_count; i++) {
            char code[100];
            snprintf(code, sizeof(code), "    scanf(\"%%d\", &%s);", input_vars[i]);
            generate_code(code);
        }
        free_input_vars();
      }
    | /* empty */
    ;

input_list:
      identifier {
        store_input_var($1);
        free($1);
        $$ = 1;
      }
    | input_list ',' identifier {
        store_input_var($3);
        free($3);
        $$ = $1 + 1;
      }
    ;

statement_list:
      /* empty */ { $$ = strdup(""); }
    | statement_list statement {
        char *tmp = (char*)malloc(strlen($1)+strlen($2)+1);
        strcpy(tmp, $1); strcat(tmp, $2);
        free($1); free($2); $$ = tmp;
      }
    ;

statement:
      IF '(' expression ')' '{' statement_list '}' opt_else {
          int len = strlen($3)+strlen($6)+strlen($8)+32;
          char *buf = malloc(len);
          snprintf(buf, len, "if (%s) {\n%s}%s\n", $3, $6, $8);
          free($3); free($6); free($8);
          $$ = buf;
      }
    | identifier EQUAL expression {
          char code[256];
          snprintf(code, sizeof(code), "    %s = %s;\n", $1, $3);
          $$ = strdup(code);
          free($1); free($3);
      }
    | PRINT print_list { $$ = $2; }
    | while_statement  { $$ = $1; }
    | for_statement    { $$ = $1; }
    | do_while_statement { $$ = $1; }
    | RETURN expression {
          char code[256];
          snprintf(code, sizeof(code), "    return %s;\n", $2);
          $$ = strdup(code);
          free($2);
      }
    ;

opt_else:
    /* empty */ { $$ = strdup(""); }
  | ELSE statement { // Handles else if!
      int len = strlen($2) + 8;
      char *block = malloc(len);
      sprintf(block, " else %s", $2);
      $$ = block;
      free($2);
  }
  | ELSE '{' statement_list '}' {
      int len = strlen($3) + 20;
      char *block = malloc(len);
      sprintf(block, " else {\n%s}\n", $3);
      $$ = block;
      free($3);
  }
;

print_list:
      identifier {
        char code[100];
        snprintf(code, sizeof(code), "    printf(\"%%d\\n\", %s);\n", $1);
        $$ = strdup(code);
        free($1);
      }
    | print_list ',' identifier {
        char code[100];
        snprintf(code, sizeof(code), "%s    printf(\"%%d\\n\", %s);\n", $1, $3);
        free($1); free($3);
        $$ = strdup(code);
      }
    ;

while_statement:
    WHILE '(' expression ')' '{' statement_list '}' {
        int len = strlen($3) + strlen($6) + 32;
        char *buf = malloc(len);
        snprintf(buf, len, "while (%s) {\n%s}\n", $3, $6);
        free($3); free($6);
        $$ = buf;
    }
;

for_statement:
    FOR '(' for_init ';' for_condition ';' for_iter ')' '{' statement_list '}' {
        int len = strlen($3) + strlen($5) + strlen($7) + strlen($10) + 64;
        char *buf = malloc(len);
        snprintf(buf, len, "for (%s; %s; %s) {\n%s}\n", $3, $5, $7, $10);
        free($3); free($5); free($7); free($10);
        $$ = buf;
    }
;

for_init:
      identifier EQUAL expression {
          char code[256];
          snprintf(code, sizeof(code), "%s = %s", $1, $3);
          free($1); free($3);
          $$ = strdup(code);
      }
    ;

for_iter:
      identifier EQUAL expression {
          char code[256];
          snprintf(code, sizeof(code), "%s = %s", $1, $3);
          free($1); free($3);
          $$ = strdup(code);
      }
    ;

for_condition:
      expression { $$ = $1; }
    | /* empty */ { $$ = strdup(""); }
    ;

do_while_statement:
    DO '{' statement_list '}' WHILE '(' expression ')' {
        int len = strlen($7) + strlen($3) + 64;
        char *buf = malloc(len);
        snprintf(buf, len, "do {\n%s} while (%s);\n", $3, $7);
        free($3); free($7);
        $$ = buf;
    }
;

expression:
      expression '+' expression {
          char *tmp = (char*)malloc(strlen($1)+strlen($3)+8);
          sprintf(tmp, "(%s + %s)", $1, $3); free($1); free($3); $$ = tmp; }
    | expression '-' expression {
          char *tmp = (char*)malloc(strlen($1)+strlen($3)+8);
          sprintf(tmp, "(%s - %s)", $1, $3); free($1); free($3); $$ = tmp; }
    | expression '*' expression {
          char *tmp = (char*)malloc(strlen($1)+strlen($3)+8);
          sprintf(tmp, "(%s * %s)", $1, $3); free($1); free($3); $$ = tmp; }
    | expression '/' expression {
          char *tmp = (char*)malloc(strlen($1)+strlen($3)+8);
          sprintf(tmp, "(%s / %s)", $1, $3); free($1); free($3); $$ = tmp; }
    | expression LT expression {
          char *tmp = (char*)malloc(strlen($1)+strlen($3)+16);
          sprintf(tmp, "(%s < %s)", $1, $3); free($1); free($3); $$ = tmp; }
    | expression GT expression {
          char *tmp = (char*)malloc(strlen($1)+strlen($3)+16);
          sprintf(tmp, "(%s > %s)", $1, $3); free($1); free($3); $$ = tmp; }
    | expression LE expression {
          char *tmp = (char*)malloc(strlen($1)+strlen($3)+18);
          sprintf(tmp, "(%s <= %s)", $1, $3); free($1); free($3); $$ = tmp; }
    | expression GE expression {
          char *tmp = (char*)malloc(strlen($1)+strlen($3)+18);
          sprintf(tmp, "(%s >= %s)", $1, $3); free($1); free($3); $$ = tmp; }
    | expression EQ expression {
          char *tmp = (char*)malloc(strlen($1)+strlen($3)+18);
          sprintf(tmp, "(%s == %s)", $1, $3); free($1); free($3); $$ = tmp; }
    | expression NE expression {
          char *tmp = (char*)malloc(strlen($1)+strlen($3)+18);
          sprintf(tmp, "(%s != %s)", $1, $3); free($1); free($3); $$ = tmp; }
    | identifier { $$ = $1; }
    | number     { char* buffer = (char*)malloc(20);
                   snprintf(buffer, 20, "%d", $1); $$ = buffer; }
    | function_call { $$ = $1; }
    ;

function_call:
    IDENTIFIER '(' arg_list ')' {
        char code[256];
        snprintf(code, sizeof(code), "%s(%s)", $1, $3);
        $$ = strdup(code);
        free($1); free($3);
    }
    ;

arg_list:
      /* empty */ { $$ = strdup(""); }
    | arg_values { $$ = $1; }
    ;

arg_values:
      expression { $$ = $1; }
    | arg_values ',' expression {
        char *tmp = (char*)malloc(strlen($1) + strlen($3) + 3);
        sprintf(tmp, "%s, %s", $1, $3); free($1); free($3); $$ = tmp; }
    ;

identifier:
    IDENTIFIER { $$ = strdup($1); }
    ;

number:
    NUMBER { $$ = $1; }
    ;

%%

void generate_code(const char* code) {
    printf("%s\n", code);
}
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
int main() {
    yydebug = 1;
    yyparse();
    return 0;
}
