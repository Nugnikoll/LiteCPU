//CPU central processing unit 中央处理器

//地址和宽度均为8位
//为简便起见不加入中断和流水线
//地址总线输入和输出不做时分复用

//外设和内存使用相同地址空间
//访问外部数据寻址时只支持寄存器寻址

//指令格式
//[7:6]位表示数据传输方向
//	2'b00表示由寄存器到寄存器
//	2'b01表示由外部到寄存器，使用操作数1对应的寄存器寻址
//		如果操作数1对应的寄存器是ip其实就是做了次立即数寻址，这时ip需要在执行后额外加一
//	2'b10表示由寄存器到外部，使用操作数2对应的寄存器寻址
//		如果操作数2对应的寄存器是ip其实就是执行了一次跳转指令
//	2'b11暂时未定义，未来可做其他用途
//[5:4]位表示运算类型
//	2'b00表示直接赋值不做额外运算
//	2'b01表示做加法
//	2'b10表示做减法
//	2'b11表示判断操作数是否为0
//[3:2]位表示第一个操作数对应的寄存器
//	2'b00表示对应r0
//	2'b01表示对应r1
//	2'b10表示对应r2
//	2'b11表示对应ip
//[1:0]位表示第二个操作数对应的寄存器
//	2'b00表示对应r0
//	2'b01表示对应r1
//	2'b10表示对应r2
//	2'b11表示对应ip

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

	output [7:0] address;
	input [7:0] data_in;
	output [7:0] data_out;

	reg [7:0] ip; // instruction pointer 指令指针寄存器

	// general registors 通用寄存器
	reg [7:0] r0;
	reg [7:0] r1;
	reg [7:0] r2;

	reg [7:0] addr_buf; // address buffer 地址缓冲寄存器
	reg [7:0] data_buf; // data buffer 数据缓冲寄存器
	reg [7:0] cmd; // instruction 指令寄存器

	wire [7:0] reg_res0;
	wire [7:0] reg_res1;

	reg [7:0] op1; // operator 1 操作数1寄存器
	reg [7:0] op2; // operator 2 操作数2寄存器
	wire [7:0] op_res;

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
		.cmd(cmd[7:6]),
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
		.cmd(cmd[5:4]),
		.op1(op1),
		.op2(op2),
		.result(op_res)
	);

	// select one register from r0, r1, r2, ip
	// 从r0, r1, r2, ip中选择一个寄存器，结果输出到reg_res0
	reg_mux reg_mux_u0(
		.cmd(cmd[3:2]),
		.r0(r0),
		.r1(r1),
		.r2(r2),
		.r3(ip),
		.result(reg_res0)
	);

	// select one register from r0, r1, r2, ip
	// 从r0, r1, r2, ip中选择一个寄存器，结果输出到reg_res1
	reg_mux reg_mux_u1(
		.cmd(cmd[1:0]),
		.r0(r0),
		.r1(r1),
		.r2(r2),
		.r3(ip),
		.result(reg_res1)
	);

	always @(posedge clk)
		if(cpu_state == `cpu_exec_calc && cmd[7:6] == 2'b10)
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
			ip <= ip + 1;
		else if(cpu_state == `cpu_exec_end)
			if(cmd[1:0] == 2'b11)
				ip <= op2;
			else if(cmd[7:6] == 2'b01 && cmd[3:2] == 2'b11)
				ip <= ip + 1;

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
			op1 <= data_buf;
		else if(cpu_state == `cpu_exec_calc)
			op2 <= op_res;

	always @(posedge clk)
		if(control_write)
			data_buf <= op2;
		else if(io_state == `io_read_wait)
			data_buf <= data_in;

	always @(posedge clk)
		if(cpu_state == `cpu_exec_end)
			case(cmd[1:0])
			2'b00: r0 <= op2;
			2'b01: r1 <= op2;
			2'b10: r2 <= op2;
			endcase

endmodule
