# CS4341 Project

## Prerequisites

- Python 3.8 or higher
- Icarus Verilog (`iverilog`)
- VVP (Verilog simulation runtime, comes with Icarus Verilog)

Install Icarus Verilog:
```bash
# macOS
brew install icarus-verilog

# Ubuntu/Debian
sudo apt-get install iverilog

# Other systems
# Visit: http://iverilog.icarus.com/
```

## Clone Locally

```bash
git clone https://github.com/GiridharRNair/cs4341project.git
cd cs4341project
```

## Local Development

### Set Up Python Virtual Environment

```bash
# Create virtual environment
python3 -m venv .venv

# Activate virtual environment
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## Run

```bash
# Run simulation
make sim

# Clean build artifacts
make clean

# Build documentation and submission files
make submission
```


## Additional Information

The `circuitverse_project` directory includes information about the system design done in CircuitVerse. CircuitVerse has a feature to export circuits to Verilog, so this folder contains the Verilog export for AI to reference when writing the project code. The directory also contains the circuit in CircuitVerse file format (.cv).

The `project_code` directory contains the main project code.

The `project_details` directory holds information about the written portion of the project (charter, system design document, project description) in Markdown format. These will be exported to PDF for submission when executing the `make submission` command.

The `project_guidelines` directory includes all project phase guidelines for AI to reference.

The `sample_verilog_code` directory contains the professor's Verilog code for AI to reference.

The `submission` directory includes all files needed for accurate submission.

There is a Makefile in the root directory with commands (stated in the Local Development section) to run the simulation, clean build artifacts, and create submission files in the `submission` directory.

The Python script `util.py` exports all markdown files from the `project_details` directory to PDF for submission when the `make submission` command is executed. 

