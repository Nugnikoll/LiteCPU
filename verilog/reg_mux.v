// 寄存器选择模块
// select one register from r0, r1, r2, r3
// 从r0, r1, r2, r3中选择一个寄存器，结果输出到result

module reg_mux(cmd, r0, r1, r2, r3, r4, r5, r6, r7, result);

	input [2:0] cmd;
	input [15:0] r0;
	input [15:0] r1;
	input [15:0] r2;
	input [15:0] r3;
	input [15:0] r4;
	input [15:0] r5;
	input [15:0] r6;
	input [15:0] r7;
	output [15:0] result;

	assign result =
		cmd == 3'b000 ? r0:
		cmd == 3'b001 ? r1:
		cmd == 3'b010 ? r2:
		cmd == 3'b011 ? r3:
		cmd == 3'b100 ? r4:
		cmd == 3'b101 ? r5:
		cmd == 3'b110 ? r6:
		r7;

endmodule
