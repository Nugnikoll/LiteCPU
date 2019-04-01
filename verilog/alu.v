// arithmetic logic unit 运算逻辑单元
// 根据命令cmd由两个操作数op1和op2计算得到result

module alu(cmd, op1, op2, result);

	input [1:0] cmd;
	input [7:0] op1;
	output [7:0] result;

	always @(*)
		begin
			case(cmd)
				2'b00: result <= op1;
				2'b01: result <= op1 + op2;
				2'b10: result <= op2 - op1;
				2'b11: result <= {7'b0000000, op1 != 0};
			endcase
		end 

endmodule
