`include "computer.v"

module computer_tb;

	reg clk;
	reg reset;
	reg port_write;
	reg [7:0] port_in;
	wire [7:0] port_out;

	initial
		begin
			$dumpfile("computer.vcd");
		    $dumpvars(0, computer_tb);
		end

	initial
		begin
			clk = 0;
			forever #1 clk = !clk;
		end

	initial
		begin
			reset = 0;
			#10 reset = 1;
			#10 reset = 0;
			#2000 $finish;
		end

	initial
		begin
			port_write = 0;
			port_in = 0;
		end

		computer computer_u(
			.clk(clk),
			.reset(reset),
			.port_write(port_write),
			.port_in(port_in),
			.port_out(port_out)
		);

endmodule
