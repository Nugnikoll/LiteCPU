%option noyywrap nodefault yylineno

%{
#include "as.h"
#include "as.tab.hh"

int oldstate;
%}

%x COMMENT

%%

"//".* ;

"/*" {
	oldstate = YY_START;
	BEGIN COMMENT;
}
<COMMENT>"*/" {
	BEGIN oldstate;
}
<COMMENT>.|\n ;
<COMMENT><<EOF>> {
	yyerror("unclosed comment");
	exit(1);
}

"(" {
	return token_par_l;
}

")" {
	return token_par_r;
}

"," {
	return token_comma;
}

\$(?:[0-9]+|0[xX][0-9a-fA-F]+) {
	if(strlen(yytext) >= 3){
		if(yytext[2] == 'x' || yytext[2] == 'X'){
			yylval.num = strtol(yytext + 1, NULL, 16);
				if(yylval.num < 0 || yylval.num > 0xff){
					yyerror("immediate constant %s overflow", yytext);
					exit(1);
				}
			return token_num;
		}
	}
	yylval.num = atoi(yytext + 1);
	if(yylval.num < 0 || yylval.num > 0xff){
		yyerror("immediate constant %s overflow", yytext);
		exit(1);
	}
	return token_num;
}

\%[a-z_][a-z_0-9]* {
	char *ptr = yytext + 1;
	if(!strcmp(ptr, "r0")){
		yylval.reg_t = reg_r0;
	}else if(!strcmp(ptr, "r1")){
		yylval.reg_t = reg_r1;
	}else if(!strcmp(ptr, "r2")){
		yylval.reg_t = reg_r2;
	}else if(!strcmp(ptr, "ip")){
		yylval.reg_t = reg_ip;
	}else{
		yyerror("invalid register name %s", yytext);
		exit(1);
	}
	return token_reg;
}

[a-z_][a-z_0-9]*: {
	string label = yytext;
	label = label.substr(0, label.size() - 1);
	if(table_label.find(label) != table_label.end()){
		yyerror("duplicated label %s", yytext);
		exit(1);
	}else{
		table_label[label] = yylineno;
	}
	return token_label;
}

\$[a-z_][a-z_0-9]* {
	yylval.str = new char[16];
	strcpy(yylval.str, yytext + 1);
	return token_ref;
}

[a-z_][a-z_0-9]* {
	if(!strcmp(yytext, "mov")){
		yylval.in_t = in_mov;
	}else if(!strcmp(yytext, "add")){
		yylval.in_t = in_add;
	}else if(!strcmp(yytext, "sub")){
		yylval.in_t = in_sub;
	}else if(!strcmp(yytext, "test")){
		yylval.in_t = in_test;
	}else{
		yyerror("undefined identifier %s", yytext);
		exit(1);
	}
	return token_cmd;
}

\n {
	return token_eol;
}

[ \t] {}

. {
	yyerror("unrecognized character %s", yytext);
	exit(1);
}

<<EOF>> {
	instruct *ptr;
	oprand *p;
	int result;

	for(ptr = vec_ins; ptr; ptr = ptr->next){
		result = 0;

		p = ptr->vec;

		if(p->next->type != op_reg){
			result |= 1 << 6; 
		}
		if(p->type != op_reg){
			result |= 1 << 7; 
		}
		result |= ptr->type << 4;
		if(p->next->type == op_num || p->next->type == op_label){
			result |= 3 << 2;
		}else{
			result |= p->next->num << 2;
		}
		result |= p->num;

		if(p->next->type == op_num){
			fprintf(yyout, "%02x %02x\n", result, p->next->num);
		}else if(p->next->type == op_label){
			int pos = locate_label(p->next->str);
			if(pos < 0){
				yylineno = ptr->next->num_line;
				yyerror("undefined label $%s", p->next->str);
				exit(1);
			}
			fprintf(yyout, "%02x %02x\n", result, pos);
		}else{
			fprintf(yyout, "%02x\n", result);
		}
	}

	yyterminate();
}

%%
