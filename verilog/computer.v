// computer 计算机模块
// 用CPU、存储器、io设备组装出一个简单的计算机
// 因为地址总线和数据总线都是8位所以地址空间总共是256byte
// 其中0x0-0x7f为ROM地址
// 0x80-0xfd为RAM地址
// 0xfe为GPIO输入设备地址
// 0xff为GPIO输出设备地址

`include "cpu.v"
`include "rom.v"
`include "ram.v"
`include "attenuater.v"
`include "gpio_in.v"
`include "gpio_out.v"

module computer (clk, reset, port_write, port_in, port_out);

	parameter path = "../data/rom_sum.dat";

	input clk;
	input reset;
	input port_write;
	input [7:0] port_in;
	output [7:0] port_out;

	wire ready;
	wire ready_rom;
	wire ready_ram;
	wire ready_ram_r;
	wire ready_ram_w;
	wire ready_gpio;
	wire ready_gpio_in;
	wire ready_gpio_in_r;
	wire ready_gpio_in_w;
	wire ready_gpio_out;
	wire ready_gpio_out_r;
	wire ready_gpio_out_w;
	wire read;
	wire write;
	wire write_ram;
	wire write_gpio_in;
	wire write_gpio_out;

	wire [7:0] address;
	wire [7:0] data_in_rom;
	wire [7:0] data_in_ram;
	wire [7:0] data_in_gpio;
	wire [7:0] data_in_gpio_in;
	wire [7:0] data_in_gpio_out;
	wire [7:0] data_in;
	wire [7:0] data_out;

	wire port_write_buf;

	assign read_rom = read && ! address[7];
	assign read_ram = read && address[7];
	assign read_gpio_in = read && (address == 8'hfe);
	assign read_gpio_out = read && (address == 8'hff); 
	assign write_ram = write && address[7];
	assign write_gpio_in = write && (address == 8'hfe);
	assign write_gpio_out = write && (address == 8'hff);
	assign data_in =
		address[7]
		? (address[6:1] == 7'h3f ? data_in_gpio : data_in_ram)
		: data_in_rom;
	assign data_in_gpio = address[0] ? data_in_gpio_out : data_in_gpio_in;
	assign ready_ram = ready_ram_r || ready_ram_w;
	assign ready =
		address[7]
		? (address[6:1] == 7'h3f ? ready_gpio : ready_ram)
		: ready_rom;
	assign ready_gpio = address[0] ? ready_gpio_out : ready_gpio_in;
	assign ready_gpio_in = ready_gpio_in_r || ready_gpio_out_w;
	assign ready_gpio_out = ready_gpio_out_r || ready_gpio_out_w;

	cpu cpu_u(
		.clk(clk),
		.reset(reset),
		.ready(ready),
		.read(read),
		.write(write),
		.address(address),
		.data_in(data_in),
		.data_out(data_out)
	);

	rom #(
		.size_addr(7),
		.size(128),
		.path(path)
	) rom_u (
		.clk(clk),
		.read(read_rom),
		.ready(ready_rom),
		.address(address[6:0]),
		.data(data_in_rom)
	);

	ram #(
		.size_addr(7),
		.size(128)
	) ram_u (
		.clk(clk),
		.reset(reset),
		.read(read_ram),
		.write(write_ram),
		.ready_r(ready_ram_r),
		.ready_w(ready_ram_w),
		.address(address[6:0]),
		.data_in(data_out),
		.data_out(data_in_ram)
	);

	gpio_in #(
		.size_addr(0),
		.size(1)
	) gpio_in_u (
		.clk(clk),
		.reset(reset),
		.read(read_gpio_in),
		.write(write_gpio_in),
		.ready_r(ready_gpio_in_r),
		.ready_w(ready_gpio_in_w),
		.address(),
		.data_in(data_out),
		.data_out(data_in_gpio_in),
		.port_write(port_write_buf),
		.port_in(port_in)
	);

	attenuater attenuater_u(
		.clk(clk),
		.data(port_write),
		.result(port_write_buf)
	);

	gpio_out #(
		.size_addr(0),
		.size(1)
	) gpio_out_u (
		.clk(clk),
		.reset(reset),
		.read(read_gpio_out),
		.write(write_gpio_out),
		.ready_r(ready_gpio_out_r),
		.ready_w(ready_gpio_out_w),
		.address(),
		.data_in(data_out),
		.data_out(data_in_gpio_out),
		.port_out(port_out)
	);

endmodule
