#ifndef AS_H
#define AS_H

#include <iostream>
#include <vector>
#include <string>
#include <cstdio>
#include <cstring>

#include <unordered_map>

using namespace std;

extern "C" int yylex();
extern "C" void va_start(va_list ap, const char *s);
extern int yylineno; /* from lexer */
extern FILE *yyin, *yyout;
extern unordered_map<string, int> table_label;
void yyerror(const char *s, ...);
int locate_label(const string& label);

enum op_type{
	op_reg,
	op_mem,
	op_num,
	op_label
};

enum reg_type{
	reg_r0,
	reg_r1,
	reg_r2,
	reg_r3,
	reg_r4,
	reg_r5,
	reg_r6,
	reg_ip
};

struct oprand{
	op_type type;
	int num;
	char *str;
	oprand *next;
};

enum in_type{
	in_cmove,
	in_cmovne,
	in_cmova,
	in_cmovna,
	in_cmovb,
	in_cmovnb,
	in_cmovg,
	in_cmovng,
	in_cmovl,
	in_cmovnl,
	in_cmovo,
	in_cmovno,
	in_cmovs,
	in_cmovns,
	in_cmovp,
	in_cmovnp,
	in_mov,
	in_not,
	in_and,
	in_or,
	in_xor,
	in_shl,
	in_rol,
	in_shr,
	in_ror,
	in_sar,
	in_add,
	in_adc,
	in_sub,
	in_sbb,
	in_neg
};

struct instruct{
	in_type type;
	int num_line;
	int num_code;
	oprand *vec;
	instruct *next;
};

extern instruct* vec_ins;
extern instruct* vec_end;
extern int num_code;
extern unordered_map<string, int> ins_dict;

#endif
