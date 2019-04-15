
.PHONY: all clean

all: computer.vcd

computer.vcd: computer.vvp
	vvp $<

computer.vvp: ../verilog/computer_tb.v $(wildcard ../verilog/*.v) ../data/rom_sum.dat
	iverilog -I ../verilog $< -o $@

clean:
	-rm -rf *.vvp
