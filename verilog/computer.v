`include "cpu.v"
`include "rom.v"
`include "ram.v"

module computer (clk, reset);

	input clk;
	input reset;
	wire ready;
	wire ready_rom;
	wire ready_ram;
	wire ready_ram_r;
	wire ready_ram_w;
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
	assign ready_ram = ready_ram_r || ready_ram_w;
	assign ready = address[7] ? ready_ram : ready_rom;

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
		.read(read),
		.write(write_ram),
		.ready_r(ready_ram_r),
		.ready_w(ready_ram_w),
		.address(address[6:0]),
		.data_in(data_out),
		.data_out(data_in_ram)
	);

endmodule
