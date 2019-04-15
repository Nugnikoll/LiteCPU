//CPU central processing unit 中央处理器

//地址和宽度均为16位
//为简便起见不加入中断和流水线
//地址总线输入和输出不做时分复用

//外设和内存使用相同地址空间
//访问外部数据寻址时只支持寄存器寻址

//指令格式
//[15:14]位表示数据传输方向
//	2'b00表示由寄存器到寄存器
//	2'b01表示由外部到寄存器，使用操作数1对应的寄存器寻址
//		如果操作数1对应的寄存器是ip其实就是做了次立即数寻址，这时ip需要在执行后额外加一
//	2'b10表示由寄存器到外部，使用操作数2对应的寄存器寻址
//		如果操作数2对应的寄存器是ip其实就是执行了一次跳转指令
//	2'b11表示由外部到外部
//[13:8]位表示运算类型
//	2'b000000表示cmove或cmovz条件赋值，z标志位为1时赋值
//	2'b000001表示cmovne或cmovnz条件赋值，z标志位为0时赋值
//	2'b000010表示cmova条件赋值，c、z标志位均为0时赋值
//	2'b000011表示cmovna条件赋值，c、z标志位有一个为1时赋值
//	2'b000100表示cmovb条件赋值，c标志位为0时赋值
//	2'b000101表示cmovnb条件赋值，c标志位为1时赋值
//	2'b000110表示cmovg条件赋值，z标志位为0且s标志位与o标志位相同时赋值
//	2'b000111表示cmovng条件赋值，z标志位为1或s标志位与o标志位不同时赋值
//	2'b001000表示cmovl条件赋值，s标志位与o标志位不同时赋值
//	2'b001001表示cmovnl条件赋值，s标志位与o标志位相同时赋值
//	2'b001010表示cmovs条件赋值，s标志位为1时赋值
//	2'b001011表示cmovns条件赋值，s标志位为0时赋值
//	2'b001100表示cmovo条件赋值，o标志位为1时赋值
//	2'b001101表示cmovno条件赋值，o标志位为0时赋值
//	2'b001110表示cmovp条件赋值，p标志位为0时赋值
//	2'b001111表示cmovnp条件赋值，p标志位为1时赋值
//	2'b010000表示mov直接赋值
//	2'b010001表示not非运算
//	2'b010010表示and与运算
//	2'b010011表示or或运算
//	2'b010100表示xor异或运算
//	2'b010101表示shl逻辑左移运算
//	2'b010110表示rol循环左移运算
//	2'b010111表示shr逻辑右移运算
//	2'b011000表示ror循环右移运算
//	2'b011001表示sar算数右移运算
//	2'b011010表示add加法运算
//	2'b011011表示adc带进位加法运算
//	2'b011100表示sub减法运算
//	2'b011101表示sbb带借位减法运算
//	2'b011110表示neg数值取反运算
//	其他均为nop什么也不做
//[7:5]位表示第一个操作数对应的寄存器
//	2'b000表示对应r0
//	2'b001表示对应r1
//	2'b010表示对应r2
//	2'b011表示对应r3
//	2'b100表示对应r4
//	2'b101表示对应r5
//	2'b110表示对应r6
//	2'b111表示对应ip
//[4:2]位表示第二个操作数对应的寄存器
//	2'b000表示对应r0
//	2'b001表示对应r1
//	2'b010表示对应r2
//	2'b011表示对应r3
//	2'b100表示对应r4
//	2'b101表示对应r5
//	2'b110表示对应r6
//	2'b111表示对应ip
//[1:0]位暂时不用

`include "type.v"
`include "cpu_control.v"
`include "cpu_io_control.v"
`include "alu.v"
`include "reg_mux.v"

module cpu(
	clk, // clock 时钟
	reset, // reset 复位信号
	ready, // ready 完成信号
	read, // read 读信号
	write, // write 写信号

	address, // address bus 地址总线
	data_in, // data bus 输入数据总线
	data_out // data bus 输出数据总线
);

	input clk;
	input reset;
	input ready;
	output read;
	output write;

	output [15:0] address;
	input [15:0] data_in;
	output [15:0] data_out;

	reg [15:0] ip; // instruction pointer 指令指针寄存器
	reg [15:0] flag; // flag register 标志寄存器

	// general registors 通用寄存器
	reg [15:0] r0;
	reg [15:0] r1;
	reg [15:0] r2;
	reg [15:0] r3;
	reg [15:0] r4;
	reg [15:0] r5;
	reg [15:0] r6;

	reg [15:0] addr_buf; // address buffer 地址缓冲寄存器
	reg [15:0] data_buf; // data buffer 数据缓冲寄存器
	reg [15:0] cmd; // instruction 指令寄存器

	wire [15:0] reg_res0;
	wire [15:0] reg_res1;

	reg [15:0] op1; // operator 1 操作数1寄存器
	reg [15:0] op2; // operator 2 操作数2寄存器
	wire [15:0] op_res;
	wire [15:0] rflag;

	wire [3:0] cpu_state;
	wire [2:0] io_state;

	wire control_read;
	wire control_write;

	assign control_write = (cpu_state == `cpu_exec_store_begin);
	assign control_read = (
		cpu_state == `cpu_fetch_begin
		|| cpu_state == `cpu_exec_load_begin
	);

	assign data_out = data_buf;

	cpu_control cpu_control_u(
		.clk(clk),
		.reset(reset),
		.cmd(cmd[15:14]),
		.ready(ready),
		.cpu_state(cpu_state)
	);

	cpu_io_control cpu_io_control_u(
		.clk(clk),
		.reset(reset),
		.cpu_state(cpu_state),
		.io_state(io_state),
		.ready(ready)
	);

	assign address = addr_buf;

	assign read = (io_state == `io_read_begin);
	assign write = (io_state == `io_write_begin);

	// do some calculation
	// 运算
	alu alu_u(
		.cmd(cmd[13:8]),
		.flag(flag),
		.op1(op1),
		.op2(op2),
		.rflag(rflag),
		.result(op_res)
	);

	// select one register from r0, r1, r2, ip
	// 从r0, r1, r2, ip中选择一个寄存器，结果输出到reg_res0
	reg_mux reg_mux_u0(
		.cmd(cmd[7:5]),
		.r0(r0),
		.r1(r1),
		.r2(r2),
		.r3(r3),
		.r4(r4),
		.r5(r5),
		.r6(r6),
		.r7(ip),
		.result(reg_res0)
	);

	// select one register from r0, r1, r2, ip
	// 从r0, r1, r2, ip中选择一个寄存器，结果输出到reg_res1
	reg_mux reg_mux_u1(
		.cmd(cmd[4:2]),
		.r0(r0),
		.r1(r1),
		.r2(r2),
		.r3(r3),
		.r4(r4),
		.r5(r5),
		.r6(r6),
		.r7(ip),
		.result(reg_res1)
	);

	always @(posedge clk)
		if(cpu_state == `cpu_exec_calc && cmd[15])
			addr_buf <= op2;
		else if(control_read)
			if(cpu_state <= `cpu_fetch_end)
				addr_buf <= ip;
			else
				addr_buf <= op1;

	always @(posedge clk)
		if(reset)
			ip <= 0;
		else if(cpu_state == `cpu_fetch_end)
			ip <= ip + 16'b1;
		else if(cpu_state == `cpu_exec_end)
			if(cmd[4:2] == 3'b111)
				ip <= op2;
			else if(cmd[14] && (cmd[7:5] == 3'b111))
				ip <= ip + 16'b1;

	always @(posedge clk)
		if(reset)
			flag <= 0;
		else if(cpu_state == `cpu_exec_calc)
			flag <= rflag;

	always @(posedge clk)
		if(cpu_state == `cpu_fetch_end)
			cmd <= data_in;

	always @(posedge clk)
		if(cpu_state == `cpu_exec_begin)
			begin
				op1 <= reg_res0;
				op2 <= reg_res1;
			end
		else if(cpu_state == `cpu_exec_load_end)
			begin
				op1 <= data_buf;
				if(cmd[7:2] == 6'b111111)
					op2 <= op2 + 16'b1;
			end
		else if(cpu_state == `cpu_exec_calc)
			op2 <= op_res;

	always @(posedge clk)
		if(cpu_state == `cpu_exec_calc)
			flag <= rflag;

	always @(posedge clk)
		if(control_write)
			data_buf <= op2;
		else if(io_state == `io_read_wait)
			data_buf <= data_in;

	always @(posedge clk)
		if(cpu_state == `cpu_exec_end)
			case(cmd[4:2])
			3'b000: r0 <= op2;
			3'b001: r1 <= op2;
			3'b010: r2 <= op2;
			3'b011: r3 <= op2;
			3'b100: r4 <= op2;
			3'b101: r5 <= op2;
			3'b110: r6 <= op2;
			endcase

endmodule
