// random access memory 随机访问存储器

module ram
	(clk, reset, read, write, ready_r, ready_w, address, data_in, data_out);

	parameter size_addr = 8;
	parameter size = 128;

	input clk;
	input reset;
	input [size_addr - 1:0] address;
	input [15:0] data_in;
	output [15:0] data_out;
	input read;
	input write;
	output reg ready_r;
	output reg ready_w;

	reg [15:0] mem_block [size - 1: 0];
	reg [15:0] out_buf;

	always @(posedge clk)
		begin
			if(reset)
				begin : mem_for
					integer i;
					for(i = 0; i < size; i = i + 1)
						mem_block[i] <= 16'h0000;
				end
			else if(write)
				mem_block[address] <= data_in;
		end

	always @(posedge clk)
		begin
			ready_r <= read;
			ready_w <= write;
		end

	always @(posedge clk)
		if(read == 1)
			out_buf <= mem_block[address];

	assign data_out = out_buf;

endmodule
