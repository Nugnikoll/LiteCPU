`include "computer.v"

module computer_tb;

parameter size = 7;
parameter [7:0] data_init [size - 1: 0];

reg clk;
reg reset;

initial
	begin
		clk = 1;
		reset = 0;
		#10 reset = 1;
		#10 reset = 0;
	end

always
	begin
		#1 clk = ~clk;
	end

	cpu cpu_u(
		.clk(clk),
		.reset(computer)
	);

endmodule
