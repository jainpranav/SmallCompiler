%{
#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>

int yylex(void);
void yyerror(char *);

struct info
{
	int nChild;
	char label[256];
	struct info* children;
	struct info* tail; //points beyond to last child
	struct info* next; //siblings
	char lexeme[256];
	
};

#define YYSTYPE struct info*


void AddChildrenOf (struct info* root, struct info* child);
void AddChild (struct info* root, struct info* child);
void InitTree (struct info** root, char* label);
void PrintTree (struct info* root);	

%}

%token hex_literal
%token id
%token string_literal
%token char_literal
%token decimal_literal
%token bool_literal
%token assign_op arith_op eq_op rel_op cond_op
%token CLASS PROGRAM VOID IF ELSE FOR RETURN BREAK CONTINUE CALLOUT INT BOOL


%right '='
%left '+' '-'
%left '*' '/'
%right UMINUS


%%

program	:	CLASS PROGRAM '{' field_decls '}'	{ InitTree(&$$, "program"); AddChildrenOf($$, $4); PrintTree ($$); }
	|	CLASS PROGRAM '{' method_decls '}'	{ InitTree(&$$, "program"); AddChildrenOf($$, $4); PrintTree ($$); }
	;

field_decls	:	type id next_field_decls ';' field_decls	{	InitTree (&$$, "field_decls"); 
										struct info* field_decl = NULL;
										InitTree (&field_decl, "field_decl");
										AddChild(field_decl, $1);
										AddChild(field_decl, $2);
										AddChildrenOf(field_decl, $3);
										AddChild($$, field_decl);
										AddChildrenOf($$, $5);
									}
		|	type id '[' int_literal ']' next_field_decls ';' field_decls	{	InitTree (&$$, "field_decls"); 
												struct info* field_decl = NULL;
												InitTree (&field_decl, "field_decl");
												AddChild(field_decl, $1);
												AddChild(field_decl, $2);
												AddChild(field_decl, $4);
												AddChildrenOf(field_decl, $6);
												AddChild($$, field_decl);
												AddChildrenOf($$, $8);
											}

		|	type id next_field_decls ';' method_decls	{	InitTree (&$$, "field_decls"); 
										struct info* field_decl = NULL;
										InitTree (&field_decl, "field_decl");
										AddChild(field_decl, $1);
										AddChild(field_decl, $2);
										AddChildrenOf(field_decl, $3);
										AddChild($$, field_decl);
										AddChildrenOf($$, $5);
									}
		|	type id '[' int_literal ']' next_field_decls ';' method_decls	{	InitTree (&$$, "field_decls"); 
												struct info* field_decl = NULL;
												InitTree (&field_decl, "field_decl");
												AddChild(field_decl, $1);
												AddChild(field_decl, $2);
												AddChild(field_decl, $4);
												AddChildrenOf(field_decl, $6);
												AddChild($$, field_decl);
												AddChildrenOf($$, $8);
											}
		|	type id assign_op literal ';' field_decls					{	InitTree (&$$, "field_decls");
														struct info* field_decl = NULL;
														InitTree (&field_decl, "field_decl");
														AddChild(field_decl, $1);
														AddChild(field_decl, $2);
														AddChild(field_decl, $4);
														AddChild($$, field_decl);
														AddChild($$, $6);
													}
		|	type id assign_op literal ';' method_decls					{       InitTree (&$$, "field_decls");
                                                                                                                struct info *field_decl = NULL;
                                                                                                                InitTree (&field_decl, "field_decl");
                                                                                                                AddChild(field_decl, $1);
                                                                                                                AddChild(field_decl, $2);
                                                                                                                AddChild(field_decl, $4);
                                                                                                                AddChild($$, field_decl);
                                                                                                                AddChild($$, $6);
                                                                                                        }	
		|	{	InitTree (&$$, "field_decls"); }
		;

next_field_decls	:	',' id next_field_decls 	{	InitTree (&$$, "next_field_decls");
									AddChild($$, $2);
									AddChildrenOf($$, $3);
								}									
			|	',' id '[' int_literal ']' next_field_decls	{	InitTree (&$$, "next_field_decls");
											AddChild($$, $2);
											AddChild($$, $4);
											AddChildrenOf($$, $6);
										}	
			|	{	InitTree (&$$, "next_field_decls");	}
			;


method_decls	:	type id '(' method_args ')' block method_decls	{	InitTree(&$$, "method_decls");
										struct info* method_decl = NULL;
										InitTree(&method_decl, "method_decl");
										AddChild(method_decl, $1);
										AddChild(method_decl, $2);
										AddChildrenOf(method_decl, $4);
										AddChild(method_decl, $6);
										AddChild($$, method_decl);
										AddChildrenOf($$, $7);
									}
		|	VOID id '(' method_args ')' block method_decls	{	InitTree(&$$, "method_decls");
										struct info* method_decl = NULL;
										InitTree(&method_decl, "method_decl");
										AddChild(method_decl, $2);
										AddChildrenOf(method_decl, $4);
										AddChild(method_decl, $6);
										AddChild($$, method_decl);
										AddChildrenOf($$, $7);
									}	
		|	{    InitTree(&$$, "method_decls");	}
		;


method_args	:	type id next_method_args	{	InitTree(&$$, "method_args");
								AddChild($$, $1);
								AddChild($$, $2);
								AddChildrenOf($$, $3);
							}
		|	 { InitTree(&$$, "method_args");	}
		;


next_method_args	:	',' type id next_method_args	{	InitTree(&$$, "next_method_args");
									AddChild($$, $2);
									AddChild($$, $3);
									AddChildrenOf($$, $4);
								}
			|	{ InitTree(&$$, "next_method_args");	}
			;



block	:	'{' var_decls statements '}' 	{	InitTree(&$$, "block");
							AddChildrenOf($$, $2);
							AddChildrenOf($$, $3);
						}								
		;


var_decls	:	type id next_ids ';' var_decls	{	InitTree(&$$, "var_decls");
								struct info* var_decl = NULL;
								InitTree(&var_decl, "var_decl");
								AddChild(var_decl, $1);
								AddChild(var_decl, $2);
								AddChildrenOf(var_decl, $3);
								AddChild($$, var_decl);
								AddChildrenOf($$, $5);
							}
		|	{ InitTree(&$$, "var_decls");	}
		;

next_ids	:	',' id next_ids	{	InitTree(&$$, "next_ids");
						AddChild($$, $2);
						AddChildrenOf($$, $3);
					}
		|	{ InitTree(&$$, "next_ids");	}
		;
statements	:	statement statements	{	InitTree(&$$, "statements");
							AddChild($$, $1);
							AddChildrenOf($$, $2);
						}
		|	{	InitTree(&$$, "statements");	}
		;



statement	:	location assign_op expr ';'	{	InitTree(&$$, "assign_stmt"); AddChild($$, $1); AddChild($$, $2); AddChild($$, $3);	 }
		|	method_call ';'		{	InitTree(&$$, "call_stmt"); AddChild($$, $1); 	}
		|	IF '(' expr ')' block	{	InitTree(&$$, "if_stmt"); AddChild($$, $3); AddChild($$, $5); 	}
		|	IF '(' expr ')' block ELSE block	{ InitTree(&$$, "if_stmt"); AddChild($$, $3); AddChild($$, $5); AddChild($$, $7);	}
		|	FOR id '=' expr ',' expr block	{ InitTree(&$$, "for_stmt"); AddChild($$, $2); AddChild($$, $5); AddChild($$, $6); AddChild($$, $7);	}
		|	RETURN ';'	{ InitTree(&$$, "ret_stmt"); }
		|	RETURN expr ';' 	 { InitTree(&$$, "ret_stmt"); AddChild($$, $2); }
		|	BREAK ';'	{ InitTree(&$$, "brk_stmt"); 	}
		|	CONTINUE ';'	{ InitTree(&$$, "cnt_stmt"); 	}
		|	block	{ InitTree(&$$, "blk_stmt"); AddChild($$, $1); 	}


		;
method_call	:	id '(' call_args ')'	{	InitTree(&$$, "method_call");
							AddChild($$, $1);
							AddChildrenOf($$, $3);
						}
		|	CALLOUT '(' string_literal callout_args ')'	{	InitTree(&$$, "callout_call");
										AddChild($$, $3);
										AddChildrenOf($$, $4);  
										
									}	
		;
call_args	:	expr next_call_args	{	InitTree(&$$, "call_args");
							AddChild($$, $1);
							AddChildrenOf($$, $2);
						
						}

		|	{	InitTree(&$$, "call_args"); }
		;
next_call_args	:	',' expr next_call_args		{	InitTree(&$$, "next_call_args");
								AddChild($$, $2);
								AddChildrenOf($$, $3);
							}
		|	{	InitTree(&$$, "next_call_args");	 }
		;
callout_args	:	',' string_literal callout_args	{	InitTree(&$$, "callout_args");
								AddChild($$, $2);
								AddChildrenOf($$, $3);
							}
		|	',' expr callout_args 		{	InitTree(&$$, "callout_args");
								AddChild($$, $2);
								AddChildrenOf($$, $3);
							}
		|	{ InitTree(&$$, "callout_args"); }
		;
location	:	id	{	InitTree(&$$, "location");
					AddChild($$, $1);
				}
		|	id '[' expr ']'	{	InitTree(&$$, "arr_loc");
						AddChild($$, $1);
						AddChild($$, $3);
					}
		;

expr	:	location	{	InitTree(&$$, "loc_expr"); AddChild($$, $1);	}	
	|	method_call	{	InitTree(&$$, "call_expr"); AddChild($$, $1);	}	
	|	'-' expr %prec UMINUS	{	InitTree(&$$, "neg_expr"); AddChild($$, $2);	}
	|	expr bin_op expr	{	InitTree(&$$, "bin_expr"); AddChild($$, $1);	AddChild($$, $2); AddChild($$, $3); }
	|	'!' expr		{	InitTree(&$$, "not_expr"); AddChild($$, $2);	}
	|	'(' expr ')'	{	InitTree(&$$, "nest_expr"); AddChild($$, $2);	}
	|	literal	{	InitTree(&$$, "literal_expr"); AddChild($$, $1);	}
	;

bin_op	:	arith_op	{InitTree (&$$, "bin_arith"); AddChild($$, $1);	}
	|	'-'		{InitTree (&$$, "bin_arith"); AddChild($$, $1);	}
	|	rel_op		{InitTree (&$$, "bin_rel"); AddChild($$, $1);	}
	|	eq_op		{InitTree (&$$, "bin_eq"); AddChild($$, $1);	}
	|	cond_op		{InitTree (&$$, "bin_cond"); AddChild($$, $1);	}
	;

literal	:	int_literal	{ InitTree (&$$, "int_const"); AddChild($$, $1); }
	|	char_literal	{InitTree (&$$, "char_const"); strcpy($$->lexeme, $1->lexeme); }
	|	bool_literal	{ InitTree (&$$, "bool_const"); strcpy($$->lexeme, $1->lexeme); }
	;

int_literal	:	decimal_literal	{ InitTree(&$$, "decimal_int"); strcpy($$->lexeme, $1->lexeme);	}
		|	hex_literal	{ InitTree(&$$, "hex_int"); strcpy($$->lexeme, $1->lexeme);	}
		;

type	:	INT	{ InitTree(&$$, "type"); strcpy($$->lexeme, "int");}
	|	BOOL	{ InitTree(&$$, "type"); strcpy($$->lexeme, "bool");}
	;		
		


%%
#include "lex.yy.c"

void yyerror (char *s) 
{
   
}

void AddChildrenOf (struct info* root, struct info* child)
{
	if (child->children == NULL) return;

	if (root->tail == NULL)  {
		root->children = child->children;
		root->tail = child->tail;
		root->nChild += child->nChild;
		return;
	} else {
		root->tail->next = child->children;
		root->tail = child->tail;
		root->nChild += child->nChild;
		return;
	}

}

void AddChild (struct info* root, struct info* child)
{
	if (root->tail == NULL) {
		root->children = child;
		root->tail = child;
		root->nChild ++;
		return;
	} else {
		root->tail->next = child;
		root->tail = child;
		root->nChild ++;
		return;
	}

}

void InitTree (struct info** root, char* label)
{
	
	*root = (struct info*)malloc(sizeof(struct info));
	strcpy((*root)->label, label);
	strcpy((*root)->lexeme, "");
	(*root)->nChild = 0;
	(*root)->children = NULL;
	(*root)->tail = NULL;
	(*root)->next = NULL;
}

void PrintTree (struct info* root)
{
	Print(root, 0);
}

void Print (struct info* root, int level) {
	
	int l;
	for ( l = 0; l < level; l ++) {
		printf ("    ");
	}

	printf ("%s\n", root->label);
	if (strcmp (root->lexeme, "") != 0)
	{
		for ( l = 0; l < level; l ++) {
			printf ("    ");
		}
		printf( "\t%s\n", root->lexeme);
	}
	//printf (" %d\n", root->nChild);

	struct info* children = root->children;
	level++;
	while (children != NULL)
	{
		
		Print(children, level);
		children = children->next;
	}
}



int main(void) 
{
	//yylval = (char*) malloc(1024 * sizeof(char));

	yyparse();
	return 0;
}
