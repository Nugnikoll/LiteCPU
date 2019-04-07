// read-only memory 只读存储器

module rom
	(clk, read, ready, address, data);

	parameter size_addr = 8;
	parameter size = 128;
	parameter [size * 8 - 1:0] data_init = 1024'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;

	input clk;
	input read;
	output ready;
	input [size_addr - 1:0] address;
	output [7:0] data;

	reg [7:0] mem_block [size - 1: 0];
	reg [7:0] out_buf;

	initial
		begin
			mem_block <= data_init;
		end

	always @(posedge clk)
		begin
			ready <= read;
		end

	always @(posedge clk)
		begin
			if(read == 1)
				out_buf <= memblock[address];
		end

	assign data = outbuf;

endmodule
