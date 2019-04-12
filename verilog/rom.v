// read-only memory 只读存储器

module rom
	(clk, read, ready, address, data);

	parameter size_addr = 8;
	parameter size = 128;
	parameter path = "../data/rom_sum.dat";

	input clk;
	input read;
	output reg ready;
	input [size_addr - 1:0] address;
	output [7:0] data;

	reg [7:0] mem_block [size - 1: 0];
	reg [7:0] out_buf;

	initial
		$readmemh(path, mem_block);

	always @(posedge clk)
		ready <= read;

	always @(posedge clk)
		if(read == 1)
			out_buf <= mem_block[address];

	assign data = out_buf;

endmodule
