`include "cpu.v"
`include "rom.v"
`include "ram.v"

module computer (clk, reset);

	parameter size = 128;
	parameter [size * 8 - 1:0] data_init = 1024'b0;

	input clk;
	input reset;
	wire ready;
	wire read;
	wire write;
	wire write_ram;

	wire [7:0] address;
	wire [7:0] data_in_rom;
	wire [7:0] data_in_ram;
	wire [7:0] data_in;
	wire [7:0] data_out;

	assign write_ram = write && address[7];
	assign data_in = address[7] ? data_in_ram : data_in_rom;

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
		.data_init(data_init)
	) rom_u (
		.clk(clk),
		.read(read),
		.ready(ready),
		.address(address[6:0]),
		.data(data_in_rom)
	);

	ram #(
		.size_addr(7),
		.size(128)
	) ram_u (
		.clk(clk),
		.read(read),
		.write(write_ram),
		.ready(ready),
		.address(address[6:0]),
		.data_in(data_out),
		.data_out(dat_in_ram)
	);

endmodule
