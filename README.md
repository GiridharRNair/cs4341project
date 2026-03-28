# Robot Circuitry Simulation (Phase 2)

Structural Verilog implementation of a robot control breadboard. Simulates robot state (speed, heading, position, weapon type) via clocked opcode commands.

## Project Overview

This is a clocked circuit simulator where:
- A testbench sends 4-bit opcodes to a breadboard module each clock cycle
- The breadboard performs the corresponding action (speed change, LED control, movement, weapon selection)
- Robot state registers (speed, heading, LED, position, weapon type) update synchronously
- Current state + status codes are printed each cycle

Design follows structural Verilog principles: all components (decoders, multiplexers, adders, registers from D flip-flops) are separate modules instantiated in the top-level breadboard.

## Setup

Requirements: `iverilog` and `vvp` (Icarus Verilog)

## Build & Run

```bash
make sim
```

(Optional: `make clean` to remove build artifacts)

## Project Files

- `rtl/robot_breadboard.v` — top-level breadboard module
- `rtl/dff_async.v` — 1-bit D flip-flop (async reset)
- `rtl/reg_n.v` — N-bit register built from DFFs
- `rtl/decoder4to16.v`, `rtl/decoder2to4.v` — decoders
- `rtl/mux2_1.v` — 2-to-1 multiplexer
- `rtl/adder_n.v`, `rtl/twos_complement_n.v`, `rtl/splitter2.v` — arithmetic/logic modules
- `tb/robot_breadboard_tb.v` — testbench program

## Opcode Commands (0-13)

| Opcode | Operation | Effect |
|--------|-----------|--------|
| 0000 | Increase speed | speed += 1 |
| 0001 | Decrease speed | speed -= 1 |
| 0010 | Turn 90 degrees | heading += 1 (wraps mod 4) |
| 0011 | LED blue | led_color = 01 |
| 0100 | LED green | led_color = 10 |
| 0101 | LED red | led_color = 11 |
| 0110 | LED on | led_signal = 1 |
| 0111 | LED off | led_signal = 0 |
| 1000 | Fire on | fire_bullets = 1 |
| 1001 | Fire off | fire_bullets = 0 |
| 1010 | Move X | Updates X position (mode-driven) |
| 1011 | Move Y | Updates Y position (mode-driven) |
| 1100 | Cycle weapon | weapon_type += 1 (0→1→2→3→0) |

Opcodes 1101-1111 are reserved (generate error status).

## Movement Mode (heading_in bits)

When executing opcode 1010 or 1011, the 2-bit `heading_in` selects movement behavior:
- `00` Add input operand (data_in_a for X, data_in_b for Y)
- `01` Subtract input operand (via two's complement)
- `10` Add feedback-loop value (current X or Y from prior cycle)
- `11` Hold current position (status warning issued)

## Testbench Output Format

Each line shows one clock cycle:
```
t=<time> op=<opcode> a=<data_A> b=<data_B> h=<heading> | speed=<val> heading=<val> ledC=<color> led=<0/1> fire=<0/1> x=<val> y=<val> weapon=<type> status=<code> fb=<16-bit> mem=<32-bit>
```

Key fields:
- `op`, `a`, `b`, `h` — inputs sent this cycle
- `speed`, `heading`, `led*`, `fire`, `x`, `y`, `weapon` — robot state outputs
- `status` — error/warning code (00 = OK)
- `fb` — 16-bit feedback loop register (holds X:Y from prior cycle)
- `mem` — 32-bit memory register (snapshot of opcode + inputs + weapon state)

## Status Codes

- `00` Success
- `21` Speed underflow (attempted to decrease below 0)
- `31` Move command with hold mode (no position change)
- `E1` Reserved opcode used (1101-1111)
