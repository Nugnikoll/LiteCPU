#ifndef AS_H
#define AS_H

#include <iostream>
#include <vector>
#include <string>
#include <cstdio>
//#include <cstdarg>
#include <unordered_map>

using namespace std;

extern "C" int yylex();
extern "C" void va_start(va_list ap, const char *s);
extern int yylineno; /* from lexer */
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
	reg_ip
};

struct oprand{
	op_type type;
	int num;
	char *str;
	oprand *next;
};

enum in_type{
	in_mov,
	in_add,
	in_sub,
	in_test
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
extern int size_code;

#endif
