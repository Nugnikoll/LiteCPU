// 用于控制CPU向外界读写数据的模块

`include "type.v"

module cpu_io_control(clk, reset, control_read, control_write, ready);

	input clk;
	input reset;
	input control_read;
	input control_write;
	input ready;

	reg [2:0] io_state;

	always @(posedge clk)
		begin
			if(reset)
				io_state <= `io_idle;
			else
				case(io_state)
				`io_idle:
					if(control_write == 1)
						io_state <= `io_write_begin;
					else if(control_read == 1)
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
		end

endmodule
