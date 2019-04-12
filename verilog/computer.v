`include "cpu.v"
`include "rom.v"
`include "ram.v"
`include "gpio_out.v"

module computer (clk, reset, port_out);

	input clk;
	input reset;
	output [7:0] port_out;

	wire ready;
	wire ready_rom;
	wire ready_ram;
	wire ready_ram_r;
	wire ready_ram_w;
	wire ready_gpio;
	wire ready_gpio_r;
	wire ready_gpio_w;
	wire read;
	wire write;
	wire write_ram;
	wire write_gpio;

	wire [7:0] address;
	wire [7:0] data_in_rom;
	wire [7:0] data_in_ram;
	wire [7:0] data_in_gpio;
	wire [7:0] data_in;
	wire [7:0] data_out;

	assign write_ram = write && address[7] && (address != 8'hff);
	assign write_gpio = write && (address == 8'hff);
	assign data_in =
		address[7]
		? (address[6:0] == 7'h7f ? data_in_gpio : data_in_ram)
		: data_in_rom;
	assign ready_ram = ready_ram_r || ready_ram_w;
	assign ready =
		address[7]
		? (address[6:0] == 7'h7f ? ready_gpio : ready_ram)
		: ready_rom;
	assign ready_gpio = ready_gpio_r || ready_gpio_w;

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
		.size(128)
	) rom_u (
		.clk(clk),
		.read(read),
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
		.read(read),
		.write(write_ram),
		.ready_r(ready_ram_r),
		.ready_w(ready_ram_w),
		.address(address[6:0]),
		.data_in(data_out),
		.data_out(data_in_ram)
	);

	gpio_out #(
		.size_addr(0),
		.size(1)
	) gpio_out_u (
		.clk(clk),
		.reset(reset),
		.read(read),
		.write(write_gpio),
		.ready_r(ready_gpio_r),
		.ready_w(ready_gpio_w),
		.address(),
		.data_in(data_out),
		.data_out(data_in_gpio),
		.port_out(port_out)
	);

endmodule
