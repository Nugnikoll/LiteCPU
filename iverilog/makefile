
.PHONY: all clean

all: computer.vvp

computer.vvp: ../verilog/computer_tb.v $(wildcard ../verilog/*.v)
	iverilog -I ../verilog $< -o $@

clean:
	-rm -rf *.vvp
