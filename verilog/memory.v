module memory
	#(size, delay_read, delay_write)
	(clk, reset, address, data_in, data_out, read, write, ready_r, ready_w);

	parameter size = 256;

	input clk;
	input reset;
	input address;
	input data_in;
	output data_out;
	input read;
	input write;
	output ready_r;
	output ready_w;

	reg [7:0] mem_block [size - 1: 0];
	reg [7:0] out_buf;

	always @(posedge clk)
		begin
			if(reset == 1)
				for(i = 0; i < size; ++i)
					mem_block[i] <= 8'h00
			else if(write == 1)
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

	assign data_out <= outbuf;

endmodule
