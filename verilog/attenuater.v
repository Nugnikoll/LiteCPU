module attenuater(clk, data, result);

	input clk;
	input data;
	output result;

	reg [3:0] count_h;
	reg [3:0] count_l;
	wire flag_h;
	wire flag_l;
	reg flag;
	reg flag_buf;
	
	localparam [3:0] delay = 4'b1000;
	
	initial
		begin
			count_h = 4'b0;
			count_l = 4'b0;
			flag = 0;
			flag_buf = 0;
		end
	
	always @(posedge clk)
		if(data == 1)
			if(count_h == delay)
				count_h <= count_h;
			else
				count_h <= count_h + 4'b1;
		else
			count_h <= 4'b0000;

	always @(posedge clk)
		if(data == 0)
			if(count_l == delay)
				count_l <= count_l;
			else
				count_l <= count_l + 4'b1;
		else
			count_l <= 4'b0000;

	assign flag_h = (count_h == delay);
	assign flag_l = (count_l == delay);

	always @(posedge clk)
		if(flag_h)
			flag <= 1;
		else if(flag_l)
			flag <= 0;

	always @(posedge clk)
		flag_buf <= flag;

	assign result = !flag_buf && flag;

endmodule
