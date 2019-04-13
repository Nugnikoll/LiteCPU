// buffered gpio ouput module

module gpio_out(clk, reset, read, write, ready_r, ready_w, address, data_in, data_out, port_out);

	parameter size_addr = 0;
	parameter size = 1;

	input clk;
	input reset;
	input read;
	input write;
	output reg ready_r;
	output reg ready_w;
	input [size_addr - 1:0] address;
	input [7:0] data_in;
	output [7:0] data_out;
	output [size * 8 - 1:0] port_out;

	reg [7:0] mem_block [size - 1: 0];
	reg [7:0] out_buf;

	always @(posedge clk)
		if(reset == 1)
			begin : gpio_out_for
				integer i;
				for(i = 0; i < size; i = i + 1)
					mem_block[i] <= 8'h00;
			end
		else if(write == 1)
			if(size_addr)
				mem_block[address] <= data_in;
			else
				mem_block[0] <= data_in;

	always @(posedge clk)
		begin
			ready_r <= read;
			ready_w <= write;
		end

	always @(posedge clk)
		if(read == 1)
			if(size_addr)
				out_buf <= mem_block[address];
			else
				out_buf <= mem_block[0];

	assign data_out = out_buf;

	genvar i;
	generate
		for(i = 0; i < size; i = i + 1)
			begin : gen_port_out
				assign port_out[i * 8 + 7 -: 8] = mem_block[i];
			end
	endgenerate

endmodule
