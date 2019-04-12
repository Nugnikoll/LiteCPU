/*
	a sample program to calculate the sum of 1, 2, 3 ... (n - 1)
	样例汇编程序：计算1到n-1的和

	汇编语法参照AT&T汇编设计
	支持单行注释和多行注释
	立即数以$开头，后面加数字，支持10进制和16进制
	寄存器以%开头
	标签以:结尾
	引用标签以$开头
	()中加寄存器表示寄存器间接寻址

	目前指令都是两个操作数
	按照AT&T汇编习惯由前向后赋值
	第一个操作数可以为寄存器、寄存器间接寻址、立即数、标签（其实还是立即数）
	第二个操作数可以为寄存器、寄存器间接寻址
	两个操作数不能同时是寄存器间接寻址
*/

label_begin:
	// input n from gpio
	mov $0xfe, %r2
	mov (%r2), %r2
	// store n in ram
	mov $0x80, %r1
	mov %r2, (%r1)
	// initial 0 -> sum -> r0
	mov $0, %r0
	// initial 0 -> i -> r1
	mov $0, %r1
label_loop:
	// sum += i
	add %r1, %r0
	// ++i
	add $1, %r1
	// n -> r2
	mov $0x80, %r2
	mov (%r2), %r2
	// (i - n == 0) -> r2
	sub %r1, %r2
	test %r2, %r2
	// if r2 == 1 then goto label_loop else goto label_end
	add %r2, %r2
	add %r2, %ip
	mov $label_end, %ip
	mov $label_loop, %ip
label_end:
	// output n to gpio
	mov $0xff, %r2
	mov %r0, (%r2)
	mov $label_begin, %ip
