
.PHONY: all clean

all: cpu.vvp

cpu.vvp: ../verilog/cpu.v $(wildcard ../verilog/*.v)
	iverilog -I ../verilog $< -o $@

clean:
	-rm -rf *.vvp
