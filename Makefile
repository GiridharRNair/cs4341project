SIM_OUT=build/robot_tb.out
VCD_OUT=build/robot_tb.vcd

PYTHON?=.venv/bin/python

PHASE3_SRC_DIR=project_code
TB_SOURCES=$(PHASE3_SRC_DIR)/robot_breadboard_tb.v
RTL_SOURCES=$(filter-out $(TB_SOURCES),$(wildcard $(PHASE3_SRC_DIR)/*.v))

MARKDOWN_DIR=project_details
MARKDOWN_SOURCES=$(wildcard $(MARKDOWN_DIR)/*.md)
MARKDOWN_PDFS=$(patsubst $(MARKDOWN_DIR)/%.md,$(SUBMISSION_DIR)/%.pdf,$(MARKDOWN_SOURCES))

SUBMISSION_DIR=submission
SUBMISSION_ZIP=$(SUBMISSION_DIR)/Cohort0x01.Phase3.Verilog.zip
SUBMISSION_OUT=$(SUBMISSION_DIR)/Cohort0x01.Phase3.output.txt

.PHONY: all sim docs clean submission

all: sim


$(SIM_OUT): $(RTL_SOURCES) $(TB_SOURCES)
	mkdir -p build
	iverilog -g2012 -o $(SIM_OUT) $(RTL_SOURCES) $(TB_SOURCES)


sim: $(SIM_OUT)
	vvp $(SIM_OUT)


docs: $(MARKDOWN_PDFS)


$(SUBMISSION_DIR)/%.pdf: $(MARKDOWN_DIR)/%.md util.py
	mkdir -p $(SUBMISSION_DIR)
	$(PYTHON) util.py --output-dir $(SUBMISSION_DIR) $<

submission: $(SIM_OUT) docs
	@mkdir -p $(SUBMISSION_DIR)
	@vvp $(SIM_OUT) > $(SUBMISSION_OUT) 2>&1
	@rm -f $(SUBMISSION_ZIP)
	@cd $(PHASE3_SRC_DIR) && zip -q ../$(SUBMISSION_ZIP) *.v
	@echo "✓ Submission files created:"
	@echo "  $(SUBMISSION_ZIP)"
	@echo "  Markdown PDFs in $(SUBMISSION_DIR)"
	@echo "  $(SUBMISSION_OUT)"

clean:
	rm -rf build submission
