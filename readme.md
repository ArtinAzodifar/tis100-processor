# TIS‑100 in SystemVerilog

Multicycle hardware implementation of the T21 processing node from the game [TIS‑100](https://www.zachtronics.com/tis-100/).  
The design models a 3×4 grid of nodes with blocking port communication, matching the original behaviour.

---

## Architecture

Each T21 node is a 16‑bit multicycle processor with:

- 20‑bit instruction memory (1024 words)
- 16‑bit datapath: ALU (ADD/SUB), ACC, BAK, PC, OldPC, IR, temporary `A`
- 4 directional ports (`UP`, `DOWN`, `LEFT`, `RIGHT`) with handshake (`valid`/`ready`)
- Control FSM with 8 states

### Instruction Format
[19:9] immediate (11‑bit, sign‑extended)
[8] flag (1=immediate, 0=register/port)
[7:4] destination operand
[3:0] opcode


When `flag=0`, the source operand is taken from bits [12:9] (shared with immediate low bits).  
When `flag=1`, the source is the sign‑extended immediate (bits [19:9]).

**Operand codes:** `NIL(0)`, `ACC(1)`, `BAK(2)`, `UP(3)`, `DOWN(4)`, `LEFT(5)`, `RIGHT(6)`, `ANY(7)`, `LAST(8)`.

### Instruction Set

| Opcode | Mnemonic | Operation |
|--------|----------|-----------|
| 0001   | MOV      | dst = src |
| 0010   | ADD      | ACC = ACC + src |
| 0011   | SUB      | ACC = ACC – src |
| 0100   | NEG      | ACC = –ACC |
| 0101   | SAV      | BAK = ACC |
| 0110   | SWP      | ACC ↔ BAK |
| 0111   | JMP      | PC = OldPC + offset |
| 1000   | JEZ      | PC = OldPC + offset if ACC==0 |
| 1001   | JNZ      | PC = OldPC + offset if ACC!=0 |
| 1010   | JGZ      | PC = OldPC + offset if ACC>0 |
| 1011   | JLZ      | PC = OldPC + offset if ACC<0 |
| 1100   | JRO      | PC = OldPC + src |

### Datapath & Control

- Shared ALU used for `PC+1`, branch address calculation, and ALU ops.
- Pipeline registers: `aluOut` holds ALU result; `IR` latches instruction; `A` stores source operand from ports.
- Control signals: `ALUSrcA` (PC, ACC, OldPC, 0), `ALUSrcB` (A, Imm, 1, ACC), `ResultSrc` selects `aluOut` or `aluResult` for PC write‑back.
- FSM states: `FETCH`, `DECODE`, `READ_WAIT`, `EXECUTE`, `WRITE_WAIT`, `JMP_WB`, `BRANCH_WB`, `INTERNAL`.
- Blocking stalls: FSM loops in `READ_WAIT` / `WRITE_WAIT` until handshake completes.

### Top‑Level Grid

`top_tis100` instantiates a 3×4 mesh with external inputs `N1in…N4in` and outputs `N9out…N12out`.  
Wiring follows the original TIS‑100 layout (each node's `UP` connects to the node above's `DOWN`, etc.).

---

## Modules

| File            | Role |
|-----------------|------|
| `t21.sv`        | Top‑level for a single node (wraps datapath + control) |
| `controlUnit.sv`| FSM and control signal generation |
| `datapath.sv`   | Datapath integration (PC, IR, OldPC, imem, ALU, ALUOut, muxes, reg_a) |
| `dataUnit.sv`   | Operand selection, port I/O, handshake, SAV/SWP |
| `alu.sv`        | 16‑bit ADD/SUB with zero & negative flags |
| `pc.sv`, `oldPC.sv`, `ir.sv`, `reg_a.sv`, `aluOut.sv` | Registers with enable |
| `imem.sv`       | ROM with `$readmemh` (program file parameter) |
| `mux2.sv`       | Parameterised 2‑to‑1 mux |
| `top_tis100.sv` | Full 3×4 grid (used by testbench) |

All modules are synthesizable (except `$readmemh`, which can be replaced by ROM initialisation).

---

## Assembler

The python script translates all the files with `.asm` format to the txt machine code.

---

## Testing

The `tb` directory contains a self-checking test for a single t21 module.

## Simulation

There are the machine codes of all 12 nodes for each Level in `LEVELS` directory in addition to the test bench for the level.

**To simulate:**
1. Compile all `.sv` files.
2. Place program files (`N1_machine.txt` … `N12_machine.txt`) in the working directory – each contains one 20‑bit instruction per line.
3. Run the testbench – it reports pass/fail.