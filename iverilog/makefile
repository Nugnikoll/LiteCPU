
.PHONY: all clean

all: computer.vcd

computer.vcd: computer.vvp ../data/rom_sum.dat
	vvp $<

computer.vvp: ../verilog/computer_tb.v $(wildcard ../verilog/*.v)
	iverilog -I ../verilog $< -o $@

clean:
	-rm -rf *.vvp
