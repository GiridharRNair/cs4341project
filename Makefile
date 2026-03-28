SIM_OUT=build/robot_tb.out
VCD_OUT=build/robot_tb.vcd

RTL_SOURCES=$(wildcard rtl/*.v)
TB_SOURCES=tb/robot_breadboard_tb.v

COHORT?=Cohort

.PHONY: all sim clean submission

all: sim

sim:
	mkdir -p build
	iverilog -g2012 -o $(SIM_OUT) $(RTL_SOURCES) $(TB_SOURCES)
	vvp $(SIM_OUT)

submission: sim
	@mkdir -p submission
	@vvp $(SIM_OUT) > submission/$(COHORT).Phase2.output.txt 2>&1
	@cd rtl && zip -q ../submission/$(COHORT).Phase2.Verilog.zip *.v && cd ../tb && zip -q ../submission/$(COHORT).Phase2.Verilog.zip *.v && cd ..
	@echo "✓ Submission files created:"
	@echo "  submission/$(COHORT).Phase2.Verilog.zip"
	@echo "  submission/$(COHORT).Phase2.output.txt"

clean:
	rm -rf build submission
