// CPU central processing unit 中央处理器

// 地址和宽度均为8位
// 为简便起见不加入中断和流水线
// 地址总线输入和输出不做时分复用

module cpu(
	clk, // clock 时钟
	reset, // reset 复位信号

	address, // address bus 地址总线
	data_in, // data bus 输入数据总线
	data_out, // data bus 输出数据总线

	ready, // ready 完成信号
	read, // read 读信号
	write // write 写信号

);

	input clk;
	input reset;

	output [7:0] address;
	input [7:0] data_in;
	output [7:0] data_out;

	input ready;
	output read;
	output write;


	reg [7:0] ip; // instruction pointer
	reg [7:0] flags; // flags register

	// general registors
	reg [7:0] r0;
	reg [7:0] r1;
	reg [7:0] r2;
	reg [7:0] r3;
	
endmodule
