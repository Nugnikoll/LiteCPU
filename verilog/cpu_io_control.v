// 用于控制CPU向外界读写数据的模块

`include "type.v"

module cpu_io_control(clk, reset, ready, cpu_state, io_state);

	input clk;
	input reset;
	input ready;
	input [3:0] cpu_state;
	output reg [2:0] io_state;

	always @(posedge clk)
		if(reset)
			io_state <= `io_idle;
		else
			case(io_state)
			`io_idle:
				if(cpu_state == `cpu_exec_store_begin)
					io_state <= `io_write_begin;
				else if(
					cpu_state == `cpu_fetch_begin
					|| cpu_state == `cpu_exec_load_begin
				)
					io_state <= `io_read_begin;
			`io_read_begin:
				io_state <= `io_read_wait;
			`io_read_wait:
				if(ready == 1)
					io_state <= `io_idle;
			`io_write_begin:
				io_state <= `io_write_wait;
			`io_write_wait:
				if(ready == 1)
					io_state <= `io_idle;
			default:
				io_state <= `io_idle;
			endcase

endmodule
