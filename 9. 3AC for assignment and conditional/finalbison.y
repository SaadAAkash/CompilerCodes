%{

#include <stdio.h>
#include <stdlib.h>

#define YYSTYPE char*


int indxakash;
int labelakash;
char *curPlaceakash;

int idx=1;

void next_name(char name[]){
	
	name[0]= 't';
	sprintf(name+1,"%d",idx);
	
	idx++;
}

int var_count=0, expr_count=0,count=0,current_level=0,global_print_level=0,global_print_count=0,global_print_expr=0;
char all_vars[1000][1000];
char all_exprs[1000][1000]; 
char all_guards[1000][1000];
char others[1000][1000];

int level[1000][2];

/* 
program → stmts |eof
stmts → stmt | stmts ; stmt
stmt → ε | selection | iteration |assignment
selection → if alts fi
iteration → do alts od
alts → alt |alts :: alt
alt → guard ? stmts
guard → expr
assignment → vars := exprs;
vars → id |vars , id
exprs → expr | exprs , expr
expr → disjunction
disjunction → conjunction | disjunction or conjunction
conjunction → negation | conjunction & negation
negation → relation| ~ relation
relation → sum
|sum < sum
|sum <= sum
|sum = sum
|sum ~= sum
|sum>= sum
|sum> sum
sum → term | - term | sum + term | sum - term
term → factor | term * factor | term / factor
factor → true | false | integer | real | id | ( expr )
*/

%}

%token ID INTEGER REAL TRUE FALSE
%token ADD SUB MUL DIV OP CP
%token SEMICOLON COMMA ASSGN
%token OR AND NOT EQL NEQL LESS LEQL GREATER GEQL
%token IF FI QUES ELS

%%

program : stmts {
	
}
;

stmts : stmt {$$=$1;}
| stmts SEMICOLON stmt{$$=$1;}
;

stmt : {$$=$$;}
| selection {$$=$1;} 
| assignment {$$=$1;}
;

selection : IF  alts FI {
	
	//printf("%s\n",others[global_print_count++]);
		
		
//	printf("if %s GOTO L%d\n",strdup($2),global_print_level);
	
//	printf("GOTO L%d\n",current_level);
	
	int flag=0;
	while(global_print_level<current_level){
	
		printf("L%d:\n",global_print_level);
		
		
		printf("	%s\n",others[global_print_count++]);
		
		char temp[10];
		int k=0;
		while(others[global_print_count-1][k]!='='){
			temp[k]=others[global_print_count-1][k];
			k++;
		}
		temp[k-1]=0;
		
		printf("	if %s GOTO L%d\n",temp,global_print_level+1);	
		
		printf("	GOTO L%d\n",global_print_level+2);
		
		printf("L%d:\n",global_print_level+1);	
	
		flag=1;
		int j;	
		for(j=global_print_count;j<level[global_print_level][0];j++){
			printf("	%s\n",others[j]);
			global_print_count++;		
		}
		
		int i;
		for(i=global_print_expr;i<level[global_print_level][1];i++){
			printf("	%s = %s\n",all_vars[i],all_exprs[i]);		
			global_print_expr++;
		}
		
		printf("	GOTO L%d\n",current_level);
		global_print_level+=2;
	}
	printf("L%d:\n",current_level);
}
;

alts: alt {$$=$1;}
| alts ELS alt {$$=$1;}
;

alt : guard QUES stmts {
	
	level[current_level][0]=count;
	level[current_level][1]=expr_count;
	current_level+=2;
	
	$$=$1;
	}
;

guard : expr {
	
	$$ = $1;
}
;


assignment: vars ASSGN exprs	{ 
		//printf("assignment -> vars := exprs ;\n"); 
	/*	int j;
		
		for(j=0;j<count;j++){
			
				printf("%s\n",others[j]);		
		}
		
		if(var_count!=expr_count){
			printf("Syntax error\n");
		}else{
			
			int i;
			for(i=0;i<var_count;i++){
				printf("%s = %s\n",all_vars[i],all_exprs[i]);}		
			}
	*/	
		}		
		
;

vars: ID	{ //printf("vars->ID\n");
strcpy(all_vars[var_count++],strdup($1));  $$ = $1;}
| vars COMMA ID { strcpy(all_vars[var_count++],strdup($3)); $$ = $1;} 
;

exprs: expr	{// printf("exprs->expr\n");
 strcpy(all_exprs[expr_count++],strdup($1));  $$ = $1;}
| exprs COMMA expr {strcpy(all_exprs[expr_count++],strdup($3)); $$ = $1;} 
;


expr: disjunction	{ $$ = $1;}
;

disjunction: conjunction { $$ = $1;}
| disjunction OR conjunction { 
	char str[10]; 
	next_name(str); 
//	strcpy(all_vars[var_count++],str);
	
	char temp[1000];
	memset(temp,0,sizeof(temp));
	strcat(temp,str);
	strcat(temp," = ");
	strcat(temp,strdup($1));
	strcat(temp," | ");
	strcat(temp,strdup($3));	
	strcpy(others[count++],temp);
	
//	printf("%s = %s | %s \n", str, $1, $3);
//	printf("dis->dis or con\n"); 
	$$ = strdup(str); 
	}
;

conjunction: negation { $$ = $1;}
| conjunction AND negation { 
	char str[10]; 
	next_name(str); 
	
	char temp[1000];
	memset(temp,0,sizeof(temp));
	strcat(temp,str);
	strcat(temp," = ");
	strcat(temp,strdup($1));
	strcat(temp," & ");
	strcat(temp,strdup($3));	
	strcpy(others[count++],temp);
	
//	printf("%s = %s & %s \n", str, $1, $3); 
	$$ = strdup(str); 
	}
;


negation: relation { $$ = $1;}
| NOT relation { char str[10]; 
	next_name(str); 
	//printf("%s = ~%s\n", str, $2);
	
	char temp[1000];
	memset(temp,0,sizeof(temp));
	strcat(temp,str);
	strcat(temp," = ");
	strcat(temp," ~");
	strcat(temp,strdup($2));	
	strcpy(others[count++],temp);
	
	$$ = strdup(str); 
	}
;


relation: sum	{ $$ = $1; }
| sum LESS sum { 
	char str[10]; 
	next_name(str); 
	//printf("%s = %s < %s \n", str, $1, $3); 
	
	char temp[1000];
	memset(temp,0,sizeof(temp));
	strcat(temp,str);
	strcat(temp," = ");
	strcat(temp,strdup($1));
	strcat(temp," < ");
	strcat(temp,strdup($3));	
	strcpy(others[count++],temp);
	
	$$ = strdup(str); 
	} 
| sum LEQL sum {  
	char str[10]; 
	next_name(str); 
	//printf("%s = %s <= %s \n", str, $1, $3);
	
	char temp[1000];
	memset(temp,0,sizeof(temp));
	strcat(temp,str);
	strcat(temp," = ");
	strcat(temp,strdup($1));
	strcat(temp," <= ");
	strcat(temp,strdup($3));	
	strcpy(others[count++],temp);
	 
	$$ = strdup(str); 
	} 
| sum GREATER sum { 
	char str[10]; 
	next_name(str); 
	//printf("%s = %s > %s \n", str, $1, $3);
	
	char temp[1000];
	memset(temp,0,sizeof(temp));
	strcat(temp,str);
	strcat(temp," = ");
	strcat(temp,strdup($1));
	strcat(temp," > ");
	strcat(temp,strdup($3));	
	strcpy(others[count++],temp);
	
	 
	$$ = strdup(str); 
	} 
| sum GEQL sum {  
	char str[10]; 
	next_name(str); 
	//printf("%s = %s >= %s \n", str, $1, $3);
	
	char temp[1000];
	memset(temp,0,sizeof(temp));
	strcat(temp,str);
	strcat(temp," = ");
	strcat(temp,strdup($1));
	strcat(temp," >= ");
	strcat(temp,strdup($3));	
	strcpy(others[count++],temp);
	
	 
	$$ = strdup(str); 
	} 
| sum EQL sum { 
	char str[10]; 
	next_name(str); 
	//printf("%s = %s = %s \n", str, $1, $3);
	
	char temp[1000];
	memset(temp,0,sizeof(temp));
	strcat(temp,str);
	strcat(temp," = ");
	strcat(temp,strdup($1));
	strcat(temp," = ");
	strcat(temp,strdup($3));	
	strcpy(others[count++],temp);
	 
	$$ = strdup(str); 
	} 
| sum NEQL sum {  
	char str[10]; 
	next_name(str); 
	//printf("%s = %s ~= %s \n", str, $1, $3); 
	
	char temp[1000];
	memset(temp,0,sizeof(temp));
	strcat(temp,str);
	strcat(temp," = ");
	strcat(temp,strdup($1));
	strcat(temp," ~= ");
	strcat(temp,strdup($3));	
	strcpy(others[count++],temp);
	
	
	$$ = strdup(str); 
	} 
;


sum: term	{ $$ = $1; }
| SUB term {  
	char str[100]; 
	str[0] = '-'; 
	sprintf(str+1,"%s",$2); 
	$$ = str; 
	}
| sum ADD term {
	char str[10]; 
	next_name(str); 
	//printf("%s = %s + %s \n", str, $1, $3);
	
	char temp[1000];
	memset(temp,0,sizeof(temp));
	strcat(temp,str);
	strcat(temp," = ");
	strcat(temp,strdup($1));
	strcat(temp," + ");
	strcat(temp,strdup($3));	
	strcpy(others[count++],temp);
	
	 
	$$ = strdup(str); 
	} 
| sum SUB term {  
	char str[10]; 
	next_name(str); 
	//printf("%s = %s - %s \n", str, $1, $3); 
	
	char temp[1000];
	memset(temp,0,sizeof(temp));
	strcat(temp,str);
	strcat(temp," = ");
	strcat(temp,strdup($1));
	strcat(temp," - ");
	strcat(temp,strdup($3));	
	strcpy(others[count++],temp);
	
	$$ = strdup(str); 
	} 
;

term: factor {  $$ = $1; }
| term MUL factor { 
	char str[100]; 
	next_name(str); 
	//printf("%s = %s * %s \n", str, $1, $3); 
	
	char temp[1000];
	memset(temp,0,sizeof(temp));
	strcat(temp,str);
	strcat(temp," = ");
	strcat(temp,strdup($1));
	strcat(temp," * ");
	strcat(temp,strdup($3));	
	strcpy(others[count++],temp);
	
	
	$$ = strdup(str); 
	}
| term DIV factor {  
	char str[100]; 
	next_name(str); 
	//printf("%s = %s / %s \n", str, $1, $3);
	
	char temp[1000];
	memset(temp,0,sizeof(temp));
	strcat(temp,str);
	strcat(temp," = ");
	strcat(temp,strdup($1));
	strcat(temp," / ");
	strcat(temp,strdup($3));	
	strcpy(others[count++],temp);
	
	 
	$$ = strdup(str); 
	}
; 


factor: TRUE { $$ = $1;}
| FALSE	{$$ = $1;}
| INTEGER {$$ = $1;}
| REAL {$$ = $1;}
| ID {$$ = $1;}
| OP expr CP {$$ = $2;}
;

%%

int main(){

	yyparse();
	
	return 0;
}

void yyerror(char *str){

	fprintf(stderr,"error: %s\n",str);
}
