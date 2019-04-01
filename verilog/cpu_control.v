// CPU中的控制模块
// 这个模块实现为一个状态机。它的状态可以分为两阶段，
// 一阶段是取指令阶段（命名中带有fetch），另一阶段是执行指令阶段(命名中带有exec)
// 执行指令的时候有可能需要从外部读取数据，需要经历的状态命名中带有load
// 也可能需要将数据存到外部，需要经历的状态命名中带有store
// 使用ALU计算时的状态命名带有calc
// 当进行到名称带有io的状态时，需要进行向外部的读/写操作，这时模块cpu_io_control需要工作

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
