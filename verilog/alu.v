module alu(cmd, op1, op2, result);

	input [1:0] cmd;
	input [7:0] op1;
	output [7:0] result;

	always @(*)
		begin
			case(cmd)
				2'b00: result <= op2;
				2'b01: result <= op1 + op2;
				2'b10: result <= op1 - op2;
				2'b11: result <= {7'b0000000, op2 != 0};
			endcase
		end 

endmodule
