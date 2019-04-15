%{
#include "as.h"
#include <cstdarg>

instruct* vec_ins;
instruct* vec_end;
int num_code;

unordered_map<string, int> table_label;
unordered_map<string, int> ins_dict;
%}

%union {
	in_type in_t;
	reg_type reg_t;
	int num;
	char *str;
	oprand op;
	oprand *vec_op;
	instruct ins;
	instruct *ins_list;
}

%token token_par_l;
%token token_par_r;
%token token_comma;
%token token_eol;
%token <num> token_num;
%token <reg_t> token_reg;
%token <in_t> token_cmd;
%token <str> token_label;
%token <str> token_ref;

%type <op> oprand;
%type <vec_op> oprand_list;
%type <ins> instruct;
%type <ins> instruct_line;
%type <ins_list> instruct_list;

%%

instruct_list: {
	$$ = NULL;
}
| instruct_list instruct_line token_eol {

	if(vec_ins){
		vec_end->next = new instruct($2);
		vec_end = vec_end->next;
	}else{
		vec_ins = new instruct($2);
		vec_end = vec_ins;
	}
	$$ = vec_ins;
}
| instruct_list label_list token_eol
| instruct_list token_eol
;

instruct_line: instruct {
	$$ = $1;
}
| label_list instruct {
	$$ = $2;
}
;

instruct: token_cmd oprand_list {
	oprand *p = $2;
	if(!p || !p->next){
		--yylineno;
		yyerror("missing oprand");
		++yylineno;
		exit(1);
	}
	if(p->next->next){
		--yylineno;
		yyerror("surplus oprand");
		++yylineno;
		exit(1);
	}
	if(
		p->type == op_num
		|| p->type == op_label
	){
		--yylineno;
		yyerror("invalid oprand type");
		++yylineno;
		exit(1);
	}

	$$ = instruct{$1, yylineno - 1, num_code, $2, NULL};

	++num_code;
	if(p->next->type == op_num || p->next->type == op_label){
		++num_code;
	}
}
;

label_list: token_label
| label_list token_label
;

oprand_list: oprand {
	$$ = new oprand($1);
}
| oprand_list token_comma oprand {
	$$ = new oprand($3);
	$$->next = $1;
}
;

oprand: token_num {
	$$ = oprand{op_num, $1, NULL, NULL};
}
|
token_ref {
	$$ = oprand{op_label, 0, $1, NULL};
}
| token_reg {
	$$ = oprand{op_reg, $1, NULL, NULL};
}
| token_par_l token_reg token_par_r {
	$$ = oprand{op_mem, $2, NULL, NULL};
}
;

%%

int main(int argc, char *argv[]){

	//bool flag_in = false;
	bool flag_out = false;
	yylineno = 1;

	for(int i = 1; i < argc; ++i) {
		if(flag_out){
			flag_out = false;
			if(!(yyout = fopen(argv[i], "w"))) {
				fprintf(stderr, "cannot open \"%s\"\n", argv[1]);
				return 1;
			}
		}else if(!strcmp(argv[i], "-o")){
			flag_out = true;
		}else{
			if(!(yyin = fopen(argv[i], "r"))) {
				fprintf(stderr, "cannot open \"%s\"\n", argv[1]);
				return 1;
			}
		}
	}
	if(flag_out){
		fprintf(stderr, "missing output file\n");
		return 1;
	}

	ins_dict["cmove"] = in_cmove;
	ins_dict["cmovz"] = in_cmove;
	ins_dict["cmovne"] = in_cmovne;
	ins_dict["cmovnz"] = in_cmovne;
	ins_dict["cmova"] = in_cmova;
	ins_dict["cmovna"] = in_cmovna;
	ins_dict["cmovbe"] = in_cmovna;
	ins_dict["cmovb"] = in_cmovb;
	ins_dict["cmovnc"] = in_cmovb;
	ins_dict["cmovnb"] = in_cmovnb;
	ins_dict["cmovae"] = in_cmovnb;
	ins_dict["cmovc"] = in_cmovnb;
	ins_dict["cmovg"] = in_cmovg;
	ins_dict["cmovng"] = in_cmovng;
	ins_dict["cmovle"] = in_cmovng;
	ins_dict["cmovl"] = in_cmovl;
	ins_dict["cmovnl"] = in_cmovnl;
	ins_dict["cmovge"] = in_cmovnl;
	ins_dict["cmovo"] = in_cmovo;
	ins_dict["cmovno"] = in_cmovno;
	ins_dict["cmovs"] = in_cmovs;
	ins_dict["cmovns"] = in_cmovns;
	ins_dict["cmovp"] = in_cmovp;
	ins_dict["cmovnp"] = in_cmovnp;
	ins_dict["mov"] = in_mov;
	ins_dict["not"] = in_not;
	ins_dict["and"] = in_and;
	ins_dict["or"] = in_or;
	ins_dict["xor"] = in_xor;
	ins_dict["shl"] = in_shl;
	ins_dict["rol"] = in_rol;
	ins_dict["shr"] = in_shr;
	ins_dict["ror"] = in_ror;
	ins_dict["sar"] = in_sar;
	ins_dict["add"] = in_add;
	ins_dict["adc"] = in_adc;
	ins_dict["sub"] = in_sub;
	ins_dict["sbb"] = in_sbb;
	ins_dict["neg"] = in_neg;

	yyparse();
}

void
yyerror(const char *s, ...){
	va_list ap;
	va_start(ap, s);

	fprintf(stderr, "line %d: error: ", yylineno);
	vfprintf(stderr, s, ap);
	fprintf(stderr, "\n");

	va_end(ap);
}

int locate_label(const string& label){
	if(table_label.find(label) == table_label.end()){
		return -1;
	}
	int line = table_label[label];
	for(instruct *ptr = vec_ins; ptr; ptr = ptr->next){
		if(ptr->num_line >= line){
			return ptr->num_code;
		}
	}
	return -1;
}
