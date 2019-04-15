`include "../verilog/computer.v"

module qcomputer (clk, reset, port_write, port_in, port_out);

	parameter path = "../data/rom_sum.dat";

	input clk;
	input reset;
	input port_write;
	input [15:0] port_in;
	output [15:0] port_out;

	wire reset_n;
	wire port_write_n;

	assign reset_n = ! reset;
	assign port_write_n = ! port_write;

	computer #(
		.path(path)
	) computer_u (
		.clk(clk),
		.reset(reset_n),
		.port_write(port_write_n),
		.port_in(port_in),
		.port_out(port_out)
	);

endmodule
