module cpu_control(clk, );

	reg  cpu_state;
	parameter cpu_fetch_begin = 0;
	parameter cpu_fetch_io = 1;
	parameter cpu_fetch_end = 2;
	parameter cpu_exec_begin = 3;
	parameter cpu_exec_load_begin = 4;
	parameter cpu_exec_load_io = 5;
	parameter cpu_exec_load_end = 6;
	parameter cpu_exec_calc = 7;
	parameter cpu_exec_store_begin = 8;
	parameter cpu_exec_store_io = 9;

	always @(posedge clk)
		begin
			
		end

endmodule
