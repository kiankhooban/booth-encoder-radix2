# Radix-2 Modified Booth Multiplier — SystemVerilog

A complete **8x8 signed binary multiplier** in SystemVerilog, built on the Radix-2 Modified Booth Encoding scheme. Four parallel Booth units generate partial products, which are summed by a final adder to produce the 16-bit result.

---

## Architecture

```
            ┌──────────────┐
  A[7:0] ──►│              │
  B[1:0] ──►│  booth_unit0 │──► pp0[8:0] ──┐
            └──────────────┘               │
            ┌──────────────┐               │
  A[7:0] ──►│              │               │
  B[3:2] ──►│  booth_unit1 │──► pp1[8:0] ──┤
            └──────────────┘               ├──► SUM ──► product[15:0]
            ┌──────────────┐               │
  A[7:0] ──►│              │               │
  B[5:4] ──►│  booth_unit2 │──► pp2[8:0] ──┤
            └──────────────┘               │
            ┌──────────────┐               │
  A[7:0] ──►│              │               │
  B[7:6] ──►│  booth_unit3 │──► pp3[8:0] ──┘
            └──────────────┘

Each booth_unit = encoder + mux
```

Each `booth_unit` examines an overlapping 3-bit window of `B`, encodes it into a partial product selection signal, and computes the partial product for that window. The four partial products are summed to produce the final result. Both `A` and `B` are treated as signed (two's complement) 8-bit integers.

---

## Module Overview

### `encoder`
Takes a 3-bit window `{b_next, b_curr, b_prev}` and outputs control signals for partial product selection.

| `b_next` | `b_curr` | `b_prev` | Operation | `zero` | `two` | `negation` |
|:--------:|:--------:|:--------:|:---------:|:------:|:-----:|:----------:|
| 0 | 0 | 0 | 0   | 1 | 0 | 0 |
| 0 | 0 | 1 | +A  | 0 | 0 | 0 |
| 0 | 1 | 0 | +A  | 0 | 0 | 0 |
| 0 | 1 | 1 | +2A | 0 | 1 | 0 |
| 1 | 0 | 0 | -2A | 0 | 1 | 1 |
| 1 | 0 | 1 | -A  | 0 | 0 | 1 |
| 1 | 1 | 0 | -A  | 0 | 0 | 1 |
| 1 | 1 | 1 | 0   | 1 | 0 | 0 |

### `mux`
Selects the partial product value based on encoder outputs.

| `negation` | `two` | `zero` | Output |
|:----------:|:-----:|:------:|:------:|
| — | — | 1 | `0` |
| 0 | 0 | 0 | `A` |
| 0 | 1 | 0 | `2A` (left shift) |
| 1 | 0 | 0 | `-A` (two's complement) |
| 1 | 1 | 0 | `-2A` |

### `booth_unit`
Wires `encoder` and `mux` together. Accepts 8-bit `A` and a 3-bit window of `B`; outputs 9-bit sign-extended partial product.

### `booth_multiplier`
Top-level 8x8 multiplier. Instantiates 4 `booth_unit`s with overlapping windows of `B`, then sums all partial products.

**Ports:**

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `A` | input | 8-bit | Multiplicand (signed) |
| `B` | input | 8-bit | Multiplier (signed) |
| `product` | output | 16-bit | Full product A × B |

**Bit-window mapping:**

| Unit | `b_prev` | `b_curr` | `b_next` |
|------|----------|----------|----------|
| u0 | `1'b0` | `B[0]` | `B[1]` |
| u1 | `B[1]` | `B[2]` | `B[3]` |
| u2 | `B[3]` | `B[4]` | `B[5]` |
| u3 | `B[5]` | `B[6]` | `B[7]` |

---

## File Structure

```
booth-encoder-radix2/
├── design.sv          # encoder, mux, booth_unit, booth_multiplier modules
├── tb_encoder.sv      # testbench — all 8 encoder input combinations
├── tb_mux.sv          # testbench — mux output verification (A=4)
├── tb_booth.sv        # testbench — booth_unit integration test (A=4)
└── tb_multiplier.sv   # testbench — full 8x8 multiplier, positive + signed cases
```

---

## Simulation

Tested on [EDA Playground](https://edaplayground.com) using **Icarus Verilog 12.0** with SystemVerilog enabled.

To simulate locally with Icarus Verilog:

```bash
# Full 8x8 multiplier
iverilog -g2012 -o sim_mult design.sv tb_multiplier.sv && vvp sim_mult

# Individual module testbenches
iverilog -g2012 -o sim_enc   design.sv tb_encoder.sv   && vvp sim_enc
iverilog -g2012 -o sim_mux   design.sv tb_mux.sv       && vvp sim_mux
iverilog -g2012 -o sim_booth design.sv tb_booth.sv     && vvp sim_booth
```

View waveforms with GTKWave:

```bash
gtkwave dump.vcd
```

### Multiplier test cases

The `tb_multiplier.sv` covers:

| A | B | Expected product |
|---|---|-----------------|
| 0 | 7 | 0 |
| 1 | 1 | 1 |
| 3 | 4 | 12 |
| 7 | 7 | 49 |
| 12 | 10 | 120 |
| 4 | 4 | 16 |
| 8 | 8 | 64 |
| 15 | 15 | 225 |
| 127 | 1 | 127 |
| -1 (0xFF) | 2 | -2 (0xFFFE) |
| 4 | -1 (0xFF) | -4 (0xFFFC) |
| -2 (0xFE) | -3 (0xFD) | 6 |
| 127 | 127 | 16129 |
| -128 (0x80) | -128 (0x80) | 16384 (0x4000) |

---

## Background

Modified Booth encoding (Radix-2) was introduced by Andrew D. Booth in 1951. It reduces the number of partial products compared to a naive shift-and-add multiplier by examining overlapping 3-bit windows of the multiplier operand — each window encodes two bits at once and may generate `0`, `±A`, or `±2A` instead of simply `0` or `A`.

This implementation is a complete **Radix-2 Booth multiplier** for 8-bit signed operands:
- 4 partial product generators (one per 2-bit group of B)
- Partial products summed with a single adder stage
- 16-bit output covers the full signed product range (−128 × −128 = 16384 to 127 × 127 = 16129)

A production-grade multiplier would replace the final adder with a **Wallace tree** or **carry-save adder array** to reduce the critical path. That is the natural next step.

---

## Author

Kian Khooban — York University, Lassonde School of Engineering
