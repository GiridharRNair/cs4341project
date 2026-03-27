SIM_OUT=build/robot_tb.out
VCD_OUT=build/robot_tb.vcd

RTL_SOURCES=$(wildcard rtl/*.v)
TB_SOURCES=tb/robot_breadboard_tb.v

.PHONY: all sim clean

all: sim

sim:
	mkdir -p build
	iverilog -g2012 -o $(SIM_OUT) $(RTL_SOURCES) $(TB_SOURCES)
	vvp $(SIM_OUT)

clean:
	rm -rf build
