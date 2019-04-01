module memory
	#(size, delay_read, delay_write)
	(clk, reset, address, data_in, data_out, read, write, ready);

	parameter size = 256;
	parameter delay_read = 2;
	parameter delay_write = 2;

	input clk;
	input reset;
	input address;
	input data_in;
	output data_out;
	input read;
	input write;
	output ready;

	reg [7:0] mem_block [size - 1: 0];

	always @(posedge clk)
		begin
			if(reset == 1)
				for(i = 0; i < size; ++i)
					mem_block[i] <= 8'h00
			else
				
		end

endmodule
