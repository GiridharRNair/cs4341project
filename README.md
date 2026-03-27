# Robot Circuitry (Verilog)

Implementation of a robot breadboard in structural Verilog.

## Files

- `rtl/robot_breadboard.v`: top module (breadboard)
- `rtl/*.v`: components (decoder, mux, adder, two's complement, DFF, registers)
- `tb/robot_breadboard_tb.v`: testbench program (clock + opcode sequence)
- `Makefile`: build and run commands

## Requirements

- Icarus Verilog tools: `iverilog`, `vvp`

## How To Run

```bash
make sim
```

Optional cleanup:

```bash
make clean
```

## Implemented Opcodes

- `0000`: increase speed
- `0001`: decrease speed
- `0010`: turn 90 degrees (heading +1)
- `0011`: LED blue
- `0100`: LED green
- `0101`: LED red
- `0110`: LED on
- `0111`: LED off
- `1000`: fire on
- `1001`: fire off
- `1010`: move X position
- `1011`: move Y position
- `1100` to `1111`: reserved

## Movement Mode (`heading_in`)

- `00`: add input operand
- `01`: subtract input operand
- `10`: add feedback-loop value
- `11`: hold current value

## What The Testbench Output Means

Each command prints one line:

- `op`: opcode being executed
- `a`, `b`: input operands (`data_in_a`, `data_in_b`)
- `h`: heading input / mode select
- `speed`, `heading`, `ledC`, `led`, `fire`, `x`, `y`: current robot state outputs
- `status`: status/error code
- `fb`: 16-bit feedback loop register
- `mem`: 32-bit memory register

## Status Codes

- `00`: normal
- `21`: speed decrease attempted at zero (warning)
- `31`: move command used with hold mode (`h=11`)
- `E1`: reserved opcode used
