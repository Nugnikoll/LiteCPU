// arithmetic logic unit 运算逻辑单元
// 根据命令cmd由两个操作数op1和op2计算得到result

module alu(cmd, op1, op2, result);

	input [1:0] cmd;
	input [7:0] op1;
	input [7:0] op2;
	output [7:0] result;

	assign result =
		cmd == 2'b00 ? op1:
		cmd == 2'b01 ? op1 + op2:
		cmd == 2'b10 ? op2 - op1:
		{7'b0000000, op1 != 0};

endmodule
