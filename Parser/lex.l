%{
#include <string.h>
int n = 0;
int i;
extern struct info* yylval;
%}

delim	[ \t\n]
ws	{delim}+
letter	[A-Za-z]
digit	[0-9]
hexdigit [0-9a-fA-F]
hex_literal	0[x|X]{hexdigit}+
id	{letter}({letter}|{digit})*
decimal_literal	{digit}+(\.{digit}+)?(E[+-]?{digit}+)?
stringl	\"[^\"\n]*\"
charl	'.'

%%

{ws}
"\""
"\\"
"class"	{ return CLASS; }
"Program"	{ return PROGRAM; }
"void"	{return VOID; }
"if"	{ return IF; }
"else"	{ return ELSE; }
"for"	{ return FOR;}
"return"	{ return RETURN; }
"break"	{ return BREAK; }
"continue" {return CONTINUE; }
"true"	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext); return bool_literal; }
"false"	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  return bool_literal; }
"callout"	{ return CALLOUT; }
"int"	{ return INT; }
"boolean"	{ return BOOL;}
{hex_literal}	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext); return hex_literal; }
{decimal_literal}	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  return decimal_literal; }
{id}	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "id"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL; return id; }
"="	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "assign_op"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL; return assign_op; }
"+="	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "assign_op"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL; return assign_op; }
"-="	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "assign_op"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL; return assign_op; }
"+"	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "arith_op"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL; return arith_op; }
"-"	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "arith_op"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL; return yytext[0]; }
"*"	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "arith_op"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL;return arith_op; }
"/"	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "arith_op"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL;return arith_op; }
"%"	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "arith_op"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL;return arith_op;}
"<"	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "rel_op"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL;return rel_op; }
">"	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "rel_op"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL;return rel_op; }
"<="	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "rel_op"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL;return rel_op; }
">="	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "rel_op"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL;return rel_op; }
"=="	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "eq_op"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL;return eq_op; }
"!="	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "eq_op"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL;return eq_op; }
"&&"	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "cond_op"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL;return cond_op; }
"||"	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "cond_op"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL;return cond_op; }
";"	{return yytext[0]; }
"("	{return yytext[0]; }
")"	{return yytext[0]; }
"["	{return yytext[0]; }
"]"	{return yytext[0]; }
"{"	{return yytext[0]; }
"}"	{return yytext[0]; }
","	{return yytext[0]; }
"!"	{return yytext[0]; }


{stringl}	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "string_literal"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL; printf("string literal %s\n", yylval->lexeme);  return string_literal; }
{charl}	{yylval = (struct info*)malloc(sizeof(struct info)); strcpy(yylval->lexeme, yytext);  strcpy(yylval->label, "char_literal"); yylval->nChild = 0; yylval->children = NULL; yylval->tail = NULL; yylval->next = NULL;return char_literal;  }

%%
