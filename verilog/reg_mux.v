// 寄存器选择模块
// select one register from r0, r1, r2, r3
// 从r0, r1, r2, r3中选择一个寄存器，结果输出到result

module reg_mux(cmd, r0, r1, r2, r3, result);

	input [1:0] cmd;
	input [7:0] r0;
	input [7:0] r1;
	input [7:0] r2;
	input [7:0] r3;
	output [7:0] result;

	assign result =
		cmd == 2'b00 ? r0:
		cmd == 2'b01 ? r1:
		cmd == 2'b10 ? r2:
		r3;

endmodule
