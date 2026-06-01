# Radix-2 Modified Booth Encoder — SystemVerilog

A hardware implementation of the **Radix-2 Modified Booth Encoding** scheme in SystemVerilog. This is the core partial-product generation stage used in high-speed binary multipliers.

---

## What It Does

Booth encoding reduces the number of partial products in a multiplier by examining overlapping 3-bit windows of the multiplier operand. Instead of shifting and adding for every bit, the encoder determines whether each partial product should be `0`, `+A`, `-A`, `+2A`, or `-2A`.

This implementation consists of three modules:

```
encoder ──┐
          ├──► booth_unit ──► p_product [8:0]
mux    ───┘
```

---

## Module Overview

### `encoder`
Takes a 3-bit sliding window `{b_next, b_curr, b_prev}` from the multiplier and outputs control signals.

| `b_next` | `b_curr` | `b_prev` | Operation | `zero` | `two` | `negation` |
|:--------:|:--------:|:--------:|:---------:|:------:|:-----:|:----------:|
| 0 | 0 | 0 | 0         | 1 | 0 | 0 |
| 0 | 0 | 1 | +A        | 0 | 0 | 0 |
| 0 | 1 | 0 | +A        | 0 | 0 | 0 |
| 0 | 1 | 1 | +2A       | 0 | 1 | 0 |
| 1 | 0 | 0 | -2A       | 0 | 1 | 1 |
| 1 | 0 | 1 | -A        | 0 | 0 | 1 |
| 1 | 1 | 0 | -A        | 0 | 0 | 1 |
| 1 | 1 | 1 | 0         | 1 | 0 | 0 |

### `mux`
Selects the correct partial product value for 8-bit input `A` based on encoder outputs.

| `negation` | `two` | `zero` | Output        |
|:----------:|:-----:|:------:|:-------------:|
| —  | —  | 1 | `0`           |
| 0  | 0  | 0 | `A`           |
| 0  | 1  | 0 | `2A` (left shift) |
| 1  | 0  | 0 | `-A` (two's complement) |
| 1  | 1  | 0 | `-2A`         |

### `booth_unit`
Top-level module. Wires `encoder` and `mux` together to produce a 9-bit sign-extended partial product.

**Ports:**

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `A` | input | 8-bit | Multiplicand |
| `b_prev` | input | 1-bit | Previous multiplier bit |
| `b_curr` | input | 1-bit | Current multiplier bit |
| `b_next` | input | 1-bit | Next multiplier bit |
| `p_product` | output | 9-bit | Partial product |

---

## File Structure

```
booth-encoder-radix2/
├── design.sv       # encoder, mux, booth_unit modules
├── tb_encoder.sv   # testbench — exhaustive test of all 8 encoder input combinations
├── tb_mux.sv       # testbench — mux output verification with A=4
└── tb_booth.sv     # testbench — end-to-end booth_unit integration test
```

---

## Simulation

Tested on [EDA Playground](https://edaplayground.com) using **Icarus Verilog 12.0** with SystemVerilog enabled.

To simulate locally with Icarus Verilog:

```bash
# Encoder testbench
iverilog -g2012 -o sim_enc design.sv tb_encoder.sv && vvp sim_enc

# Mux testbench
iverilog -g2012 -o sim_mux design.sv tb_mux.sv && vvp sim_mux

# Full booth unit testbench
iverilog -g2012 -o sim_booth design.sv tb_booth.sv && vvp sim_booth
```

Waveforms are dumped to `dump.vcd` and can be viewed with GTKWave:

```bash
gtkwave dump.vcd
```

---

## Background

Modified Booth encoding (Radix-2) was introduced by Andrew D. Booth in 1951. It is a foundational technique in digital arithmetic — virtually every modern CPU multiplier uses some variant of this algorithm to reduce the partial product count and minimize power consumption and area.

This implementation covers the **partial product generation unit** (one booth cell). A full multiplier would instantiate multiple `booth_unit`s, accumulate the partial products using a Wallace tree or carry-save adder array, and produce the final product.

---

## Author

Kian Khooban — York University, Lassonde School of Engineering
