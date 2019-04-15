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
				if(yylval.num < 0 || yylval.num > 0xffff){
					yyerror("immediate constant %s overflow", yytext);
					exit(1);
				}
			return token_num;
		}
	}
	yylval.num = atoi(yytext + 1);
	if(yylval.num < 0 || yylval.num > 0xffff){
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
	}else if(!strcmp(ptr, "r3")){
		yylval.reg_t = reg_r3;
	}else if(!strcmp(ptr, "r4")){
		yylval.reg_t = reg_r4;
	}else if(!strcmp(ptr, "r5")){
		yylval.reg_t = reg_r5;
	}else if(!strcmp(ptr, "r6")){
		yylval.reg_t = reg_r6;
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
	string str = yytext;
	if(ins_dict.find(str) != ins_dict.end()){
		yylval.in_t = in_type(ins_dict[str]);
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
			result |= 1 << 14; 
		}
		if(p->type != op_reg){
			result |= 1 << 15; 
		}
		result |= ptr->type << 8;
		if(p->next->type == op_num || p->next->type == op_label){
			result |= 0x7 << 5;
		}else{
			result |= p->next->num << 5;
		}
		result |= p->num << 2;

		if(p->next->type == op_num){
			fprintf(yyout, "%04x %04x\n", result, p->next->num);
		}else if(p->next->type == op_label){
			int pos = locate_label(p->next->str);
			if(pos < 0){
				yylineno = ptr->next->num_line;
				yyerror("undefined label $%s", p->next->str);
				exit(1);
			}
			fprintf(yyout, "%04x %04x\n", result, pos);
		}else{
			fprintf(yyout, "%04x\n", result);
		}
	}
	fprintf(yyout, "\n");

	int size = 32768 - num_code;
	if(size < 0){
		yyerror("the size of code is %d\n", num_code);
		yyerror("code segment overflow\n");
		exit(1);
	}

	int size_margin = size % 16;
	if(size_margin){
		for(int i = 0; i != 16 - size_margin; ++i){
			fprintf(yyout, "     ");
		}
		for(int i = 0; i != size_margin; ++i){
			fprintf(yyout, "0000 ");
		}
		fprintf(yyout, "\n");
	}
	size /= 16;
	for(int i = 0; i != size; ++i){
		fprintf(yyout, "0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000\n");
	}

	yyterminate();
}

%%
