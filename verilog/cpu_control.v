// CPU中的控制模块
// 这个模块实现为一个状态机。它的状态可以分为两阶段，
// 一阶段是取指令阶段（命名中带有fetch），另一阶段是执行指令阶段(命名中带有exec)
// 执行指令的时候有可能需要从外部读取数据，需要经历的状态命名中带有load
// 也可能需要将数据存到外部，需要经历的状态命名中带有store
// 使用ALU计算时的状态命名带有calc
// 当进行到名称带有io的状态时，需要进行向外部的读/写操作，这时模块cpu_io_control需要工作

`include "type.v"

module cpu_control(clk, reset, cmd, ready, cpu_state);


	input clk;
	input reset;
	input [1:0] cmd;
	input ready;
	output reg [3:0] cpu_state;

	always @(posedge clk)
		begin
			if(reset)
				cpu_state <= `cpu_fetch_begin;
			else
				case(cpu_state)
				`cpu_fetch_begin:
					cpu_state <= `cpu_fetch_io;
				`cpu_fetch_io:
					if(ready)
						cpu_state <= `cpu_fetch_end;
				`cpu_fetch_end:
					cpu_state <= `cpu_exec_begin;
				`cpu_exec_begin:
					if(cmd[0])
						cpu_state <= `cpu_exec_load_begin;
					else
						cpu_state <= `cpu_exec_calc;
				`cpu_exec_load_begin:
					cpu_state <= `cpu_exec_load_io;
				`cpu_exec_load_io:
					if(ready)
						cpu_state <= `cpu_exec_load_end;
				`cpu_exec_load_end:
					cpu_state <= `cpu_exec_calc;
				`cpu_exec_calc:
					if(cmd[1])
						cpu_state <= `cpu_exec_store_begin;
					else
						cpu_state <= `cpu_fetch_begin;
				`cpu_exec_store_begin:
					cpu_state <=  `cpu_exec_store_io;
				`cpu_exec_store_io:
					if(ready)
						cpu_state <= `cpu_fetch_begin;
				default:
					cpu_state <= `cpu_fetch_begin;
				endcase
		end

endmodule
