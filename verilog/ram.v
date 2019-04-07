// random access memory 随机访问存储器

module ram
	(clk, reset, read, write, ready_r, ready_w, address, data_in, data_out);

	parameter size_addr = 8;
	parameter size = 128;

	input clk;
	input reset;
	input [size_addr - 1:0] address;
	input [7:0] data_in;
	output [7:0] data_out;
	input read;
	input write;
	output ready_r;
	output ready_w;

	reg [7:0] mem_block [size - 1: 0];
	reg [7:0] out_buf;

	always @(posedge clk)
		begin
			if(reset)
				for(i = 0; i < size; ++i)
					mem_block[i] <= 8'h00;
			else if(write)
				mem_block[address] <= data_in;
		end

	always @(posedge clk)
		begin
			ready_r <= read;
			ready_w <= write;
		end

	always @(posedge clk)
		begin
			if(read == 1)
				out_buf <= memblock[address];
		end

	assign data_out = outbuf;

endmodule
