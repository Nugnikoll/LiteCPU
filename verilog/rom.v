// read-only memory 只读存储器

module rom
	#(size_addr, size, data_init)
	(clk, read, ready, address, data);

	parameter size_addr = 8;
	parameter size = 256;
	parameter data_init;

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

	assign data <= outbuf;

endmodule;
