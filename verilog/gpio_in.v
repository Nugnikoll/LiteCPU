// general input

module gpio_in(clk, reset, read, write, ready_r, ready_w, address, data_in, data_out, port_write, port_in);

	parameter size_addr = 0;
	parameter size = 1;

	input clk;
	input reset;
	input [size_addr - 1:0] address;
	input [7:0] data_in;
	output [7:0] data_out;
	input read;
	input write;
	output reg ready_r;
	output reg ready_w;
	input [size - 1:0] port_write;
	input [size * 8 - 1:0] port_in;

	reg [size - 1:0] wait_r;
	wire [7:0] out_buf;
	reg [7:0] mem_block [size - 1: 0];

	always @(posedge clk)
		begin
			if(reset)
				begin : mem_for
					integer i;
					for(i = 0; i < size; i = i + 1)
						mem_block[i] <= 8'h00;
				end
			else if(write)
				if(size_addr)
					mem_block[address] <= data_in;
				else
					mem_block[0] <= data_in;
			else
				begin : port_write_for
					integer i;
					for(i = 0; i < size; i = i + 1)
						if(port_write[i])
							mem_block[i] <= port_in[i * 8 + 7 -: 8];
				end
		end

	always @(posedge clk)
		if(size_addr)
			begin : wait_r_for
				integer i;
				for(i = 0; i < size; i = i + 1)
					if(port_write[i])
						wait_r[i] <= 0;
					else if(address == i && read)
							wait_r[i] <= 1;
			end
		else
			if(port_write[0])
				wait_r[0] <= 0;
			else if(read)
				wait_r[0] <= 1;

	always @(posedge clk)
		ready_w <= write;

	always @(posedge clk)
		if(size_addr)
			ready_r <= (read || wait_r[address]) && port_write;
		else
			ready_r <= (read || wait_r[0]) && port_write;

//	always @(posedge clk)
//		if(size_addr)
//			out_buf <= mem_block[address];
//		else
//			out_buf <= mem_block[0];

	assign out_buf = size_addr ? mem_block[address] : mem_block[0];

	assign data_out = out_buf;

endmodule
