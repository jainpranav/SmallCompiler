%{
	/* 
		
		Pranav Jain 
		.____                  
		|    |    ____ ___  ___
		|    |  _/ __ \\  \/  /
		|    |__\  ___/ >    < 
		|_______ \___  >__/\_ \
		        \/   \/      \/
	*/
%}


%{ /* Declaring the constants */
	int i=0;
	int iter;	
%}
	
delim					[ \t\n]     
ws					{delim}+	
alpha					[A-Za-z_]	
digit					[0-9]		
id					{alpha}({alpha}|{digit})*  
number					{digit}+(\.{digit}+)?(E[+-]?{digit}+)?
charliteral				\'.\'
stringliteral				\".*\"
hexdigit				[0-9a-fA-F]
hexliteral				0[X|x]{hexdigit}+

%%
{ws}
class				{++i ; printf("%d CLASS\tclass\n",i);}
Program				{++i ; printf("%d PROGRAM\tprogram\n",i);}
int				{++i ; printf("%d TYPE\tint\n",i);}
boolean				{++i ; printf("%d TYPE\tboolean\n",i);}
void				{++i ; printf("%d VOID\tvoid\n",i);}
if				{++i ; printf("%d IF\tif\n",i);}
else				{++i ; printf("%d ELSE\telse\n",i);}
for				{++i ; printf("%d FOR\tfor\n",i);}
return 				{++i ; printf("%d RETURN\treturn\n",i);}
break				{++i ; printf("%d BREAK\tbreak\n",i);}
continue			{++i ; printf("%d CONTINUE\tcontinue\n",i);}
{id}				{++i ; printf("%d ID\t%s\n",i , yytext);}
{number}			{++i ; printf("%d DECIMAL_LITERAL %s\n",i , yytext);}
{hexliteral}			{++i ; printf("%d HEX_LITERAL %s\n",i , yytext);}
{charliteral}			{	++i ; printf("%d CHAR_LITERAL\t",i);
					for(iter=1;iter < yyleng-1;iter++)
					{
						printf("%c",yytext[iter]);
					}
					printf("\n");
				}
{stringliteral}			{	++i ; printf("%d STRING_LITERAL\t",i);
					for(iter=1;iter < yyleng-1;iter++)
					{
						printf("%c",yytext[iter]);
					}
					printf("\n");
				}
callout				{++i ; printf("%d CALLOUT callout\n",i);}
"true"				{++i ; printf("%d BOOL_LITERAL true\n",i);}
"false"				{++i ; printf("%d BOOL_LITERAL false\n",i);}
"="				{++i ; printf("%d ASSIGN_OP =\n",i);}
"+="				{++i ; printf("%d ASSIGN_OP +=\n",i);}
"-="				{++i ; printf("%d ASSIGN_OP -=\n",i);}
"=="				{++i ; printf("%d EQ_OP ==\n",i);}
"!="				{++i ; printf("%d EQ_OP !=\n",i);}
"+"				{++i ; printf("%d ARITH_OP +\n",i);}
"-"				{++i ; printf("%d ARITH_OP -\n",i);}
"*"				{++i ; printf("%d ARITH_OP *\n",i);}
"/"				{++i ; printf("%d ARITH_OP /\n",i);}
"%"				{++i ; printf("%d ARITH_OP %\n",i);}
"<"				{++i ; printf("%d REL_OP <\n",i);}
"<="				{++i ; printf("%d REL_OP <=\n",i);}
">"				{++i ; printf("%d REL_OP >\n",i);}
">="				{++i ; printf("%d REL_OP >=\n",i);}
"||"				{++i ; printf("%d COND_OP ||\n",i);}
"&&"				{++i ; printf("%d COND_OP &&\n",i);}
"("				{++i ; printf("%d (\n",i);}
")"				{++i ; printf("%d )\n",i);}
"["				{++i ; printf("%d [\n",i);}
"]"				{++i ; printf("%d ]\n",i);}
"{"				{++i ; printf("%d {\n",i);}
"}"				{++i ; printf("%d }\n",i);}
","				{++i ; printf("%d ,\n",i);}
";"				{++i ; printf("%d ;\n",i);}

%%
			
