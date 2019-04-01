// 用于控制CPU向外界读写数据的模块

module cpu_io_control(clk, );

	reg [2:0] ;
	parameter io_idle = 0;
	parameter io_addr_read = 1;
	parameter io_wait_read = 2;
	parameter io_addr_write = 3;
	parameter io_wait_write = 4;

	always @(posedge clk)
		begin
			
		end

endmodule
