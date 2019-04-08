`include "computer.v"

module computer_tb;

reg clk;
reg reset;
wire port_out;

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

	computer computer_u(
		.clk(clk),
		.reset(reset),
		.port_out()
	);

endmodule
