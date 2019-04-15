// arithmetic logic unit 运算逻辑单元
// 根据命令cmd由两个操作数op1和op2计算得到result

module alu(cmd, flag, op1, op2, result, rflag);

	input [5:0] cmd;
	input [15:0] flag;
	input [15:0] op1;
	input [15:0] op2;
	output [15:0] result;
	output [15:0] rflag;

	wire flag_s = flag[15];
	wire flag_z = flag[14];
	wire flag_c = flag[13];
	wire flag_o = flag[12];
	wire flag_a = flag[11];
	wire flag_p = flag[10];
	wire [16:0] sum = {1'b0, op1} + {1'b0, op2};
	wire [16:0] sumc = {1'b0, op1} + {1'b0, op2} + {16'b0, flag_c};
	wire [15:0] sumo = {1'b0, op1[14:0]} + {1'b0, op2[14:0]};
	wire [15:0] sumoc = {1'b0, op1[14:0]} + {1'b0, op2[14:0]} + {15'b0, flag_c};
	wire [16:0] diff = {1'b0, op2} - {1'b0, op1};
	wire [16:0] diffc = {1'b0, op2} - {1'b0, op1} - {16'b0, flag_c};
	wire [15:0] diffo = {1'b0, op1[14:0]} - {1'b0, op2[14:0]};
	wire [15:0] diffoc = {1'b0, op1[14:0]} - {1'b0, op2[14:0]} - {15'b0, flag_c};

	assign result =
		cmd == 6'b000000 ? (flag_z ? op2: op1) :
		cmd == 6'b000001 ? (flag_z ? op1: op2) :
		cmd == 6'b000010 ? (flag_c || flag_z ? op2 : op1):
		cmd == 6'b000011 ? (flag_c || flag_z ? op1 : op2):
		cmd == 6'b000100 ? (flag_c ? op2 : op1):
		cmd == 6'b000101 ? (flag_c ? op1 : op2):
		cmd == 6'b000110 ? (!flag_z && (flag_c == flag_o) ? op1 : op2):
		cmd == 6'b000111 ? (!flag_z && (flag_c == flag_o) ? op2 : op1):
		cmd == 6'b001000 ? (flag_s == flag_o ? op2 : op1):
		cmd == 6'b001001 ? (flag_s == flag_o ? op1 : op2):
		cmd == 6'b001010 ? (flag_s ? op2 : op1):
		cmd == 6'b001011 ? (flag_s ? op1 : op2):
		cmd == 6'b001100 ? (flag_o ? op2 : op1):
		cmd == 6'b001101 ? (flag_o ? op1 : op2):
		cmd == 6'b001110 ? (flag_p ? op2 : op1):
		cmd == 6'b001111 ? (flag_p ? op1 : op2):
		cmd == 6'b010000 ? op1:
		cmd == 6'b010001 ? ~op1:
		cmd == 6'b010010 ? op1 & op2:
		cmd == 6'b010011 ? op1 || op2:
		cmd == 6'b010100 ? op1 ^ op2:
		cmd == 6'b010101 ? op2 << op1:
		cmd == 6'b010110 ? op2 << op1:
		cmd == 6'b010111 ? op2 >> op1:
		cmd == 6'b011000 ? op2 >> op1:
		cmd == 6'b011001 ? op2 >>> op1:
		cmd == 6'b011010 ? sum[15:0]:
		cmd == 6'b011011 ? sumc[15:0]:
		cmd == 6'b011100 ? diff[15:0]:
		cmd == 6'b011101 ? diffc[15:0]:
		cmd == 6'b011110 ? - op1:
		op2;

	assign rflag[9:0] = 10'b0;
	assign rflag[15] = (cmd >= 6'b010000) && result[15];
	assign rflag[14] = (cmd >= 6'b010000) && (result == 6'b0);
	assign rflag[13] =
		((cmd == 6'b011010) && sum[16])
		|| ((cmd == 6'b011011) && sumc[16])
		|| ((cmd == 6'b011100) && diff[16])
		|| ((cmd == 6'b011101) && diffc[16]);
	assign rflag[12] =
		((cmd == 6'b011010) && sumo[15])
		|| ((cmd == 6'b011011) && sumoc[15])
		|| ((cmd == 6'b011100) && diffo[15])
		|| ((cmd == 6'b011101) && diffoc[15]);
	assign rflag[11] = 0;
	assign rflag[10] = (cmd >= 6'b010000)
		&& (
			result[15] ^ result[14] ^ result[13] ^ result[12]
			^ result[11] ^ result[10] ^ result[9] ^ result[8]
			^ result[7] ^ result[6] ^ result[5] ^ result[4]
			^ result[3] ^ result[2] ^ result[1] ^ result[0]
		);

endmodule
