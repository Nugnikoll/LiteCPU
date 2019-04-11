%{
#include "as.h"

instruct* vec_ins;
instruct* vec_end;
int num_code;

unordered_map<string, int> table_label;
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
		|| (p->next->type != op_reg && p->type == op_mem)
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

	yyparse();
}

void
yyerror(const char *s, ...){
	//va_list ap;
	//va_start(ap, s);

	fprintf(stderr, "line %d: error: ", yylineno);
	//vfprintf(stderr, s, ap);
	fprintf(stderr, s);
	fprintf(stderr, "\n");

	//va_end(ap);
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
