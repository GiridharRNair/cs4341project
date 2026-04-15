# Robot Circuitry Simulation (Phase 3)

Structural Verilog implementation of a robot control breadboard. Simulates robot state (speed, heading, position, weapon type) via clocked opcode commands.

## Setup

Requirements: `iverilog` and `vvp` (Icarus Verilog)

## Build & Run

```bash
make sim
```

(Optional: `make clean` to remove build artifacts)

## Project Files

- `phase3_verilog/` — flat single-folder source layout required for submission
- `phase3_verilog/robot_breadboard.v` — top-level breadboard module
- `phase3_verilog/dff_async.v` — 1-bit D flip-flop (async reset)
- `phase3_verilog/reg_n.v` — N-bit register built from DFFs
- `phase3_verilog/decoder4to16.v`, `phase3_verilog/decoder2to4.v` — decoders
- `phase3_verilog/mux2_1.v` — 2-to-1 multiplexer
- `phase3_verilog/adder_n.v`, `phase3_verilog/twos_complement_n.v`, `phase3_verilog/splitter2.v` — arithmetic/logic modules
- `phase3_verilog/robot_breadboard_tb.v` — testbench program/stimulus

## Submission Command

```bash
make submission
```

This generates:
- `submission/Cohort0x01.Phase3.Verilog.zip`
- `submission/Cohort0x01.Phase3.output.txt`

## Opcode Commands (0-13)

| Opcode | Operation | Effect |
|--------|-----------|--------|
| 0000 | Increase speed | speed += 1 |
| 0001 | Decrease speed | speed -= 1 |
| 0010 | Turn command | heading += heading_in (wraps mod 4) |
| 0011 | LED blue | led_color = 01 |
| 0100 | LED green | led_color = 10 |
| 0101 | LED red | led_color = 11 |
| 0110 | LED on | led_signal = 1 |
| 0111 | LED off | led_signal = 0 |
| 1000 | Fire on | fire_bullets = 1 |
| 1001 | Fire off | fire_bullets = 0 |
| 1010 | Move forward | Moves position based on heading and speed |
| 1011 | Move backward | Moves opposite heading based on speed |
| 1100 | Weapon update | weapon_type += heading_in (mod 4) |

Opcodes 1101-1111 are reserved (generate error status).

## Movement Semantics

When executing opcode 1010 (forward) or 1011 (backward), movement is derived from current heading and speed:
- `00` North: forward = `+Y`, backward = `-Y`
- `01` East: forward = `+X`, backward = `-X`
- `10` South: forward = `-Y`, backward = `+Y`
- `11` West: forward = `-X`, backward = `+X`

## Testbench Output Format

Each line shows one clock cycle:
```
t=<time> op=<opcode> h=<heading> | speed=<val> heading=<val> ledC=<color> led=<0/1> fire=<0/1> x=<val> y=<val> weapon=<type> status=<code> fb=<16-bit> mem=<32-bit>
```

Key fields:
- `op`, `h` — inputs sent this cycle
- `speed`, `heading`, `led*`, `fire`, `x`, `y`, `weapon` — robot state outputs
- `status` — error/warning code (00 = OK)
- `fb` — 16-bit feedback loop register (holds X:Y from prior cycle)
- `mem` — 32-bit memory register (snapshot of opcode + control/state fields)

## Status Codes

- `00` Success
- `E1` Reserved opcode used (1101-1111)
