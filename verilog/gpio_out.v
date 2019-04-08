// buffered gpio ouput module

module gpio_out
	#(size_addr, size)
	(clk, reset, read, write, ready_r, ready_w, address, data_in, data_out);

	parameter size_addr = 1;
	parameter size = 1;

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
		if(reset == 1)
			for(i = 0; i < size; ++i)
				mem_block[i] <= 8'h00
		else if(write == 1)
			mem_block[address] <= data_in;

	always @(posedge clk)
		begin
			ready_r <= read;
			ready_w <= write;
		end

	always @(posedge clk)
		if(read == 1)
			out_buf <= memblock[address];

	assign data_out <= outbuf;

endmodule
