SIM_OUT=build/robot_tb.out
VCD_OUT=build/robot_tb.vcd

PHASE3_SRC_DIR=phase3_verilog
TB_SOURCES=$(PHASE3_SRC_DIR)/robot_breadboard_tb.v
RTL_SOURCES=$(filter-out $(TB_SOURCES),$(wildcard $(PHASE3_SRC_DIR)/*.v))

SUBMISSION_DIR=submission
SUBMISSION_ZIP=$(SUBMISSION_DIR)/Cohort0x01.Phase3.Verilog.zip
SUBMISSION_OUT=$(SUBMISSION_DIR)/Cohort0x01.Phase3.output.txt

.PHONY: all sim clean submission

all: sim

sim:
	mkdir -p build
	iverilog -g2012 -o $(SIM_OUT) $(RTL_SOURCES) $(TB_SOURCES)
	vvp $(SIM_OUT)

submission: sim
	@mkdir -p $(SUBMISSION_DIR)
	@vvp $(SIM_OUT) > $(SUBMISSION_OUT) 2>&1
	@rm -f $(SUBMISSION_ZIP)
	@cd $(PHASE3_SRC_DIR) && zip -q ../$(SUBMISSION_ZIP) *.v
	@echo "✓ Submission files created:"
	@echo "  $(SUBMISSION_ZIP)"
	@echo "  $(SUBMISSION_OUT)"

clean:
	rm -rf build submission
