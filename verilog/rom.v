// read-only memory 只读存储器

module rom
	(clk, read, ready, address, data);

	parameter size_addr = 8;
	parameter size = 128;

	input clk;
	input read;
	output reg ready;
	input [size_addr - 1:0] address;
	output [7:0] data;

	reg [7:0] mem_block [size - 1: 0];
	reg [7:0] out_buf;

	initial
		begin
			$readmemh("../data/rom_sum.dat", mem_block);
		end

	always @(posedge clk)
		begin
			ready <= read;
		end

	always @(posedge clk)
		begin
			if(read == 1)
				out_buf <= mem_block[address];
		end

	assign data = out_buf;

endmodule
