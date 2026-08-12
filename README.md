# Asynchronous FIFO Design & Verification

This repository contains a Verilog implementation of an **Asynchronous FIFO (First-In, First-Out)** architecture. It enables safe multi-bit data transfers across independent clock domains (`wclk` and `rclk`) using Gray code pointer encoding and 2-stage DFF synchronizers to mitigate metastability[cite: 7, 8, 9, 10].

---

## Technical Specifications

| Parameter | Value | Description |
| :--- | :--- | :--- |
| **Data Width** | 8 bits | Output/Input payload size[cite: 6, 7] |
| **FIFO Depth** | 8 entries | Memory array size ($2^3$) |
| **Pointer Width** | 4 bits | 3 bits for address indexing + 1 MSB for wrap-around check[cite: 7, 8, 10] |
| **Write Clock Domain** | `wclk` (10 ns period) | Asynchronous write clock[cite: 6, 7] |
| **Read Clock Domain** | `rclk` (20 ns period) | Asynchronous read clock[cite: 6, 7] |

---

## Architecture Overview

The design consists of the top-level module `fifo.v` that integrates four primary functional blocks:

* **Dual-Clock RAM Block (`fifo`)**: An $8 \times 8$-bit register array that handles synchronous data writes on `wclk` and registered outputs on `rclk`.
* **Write Domain (`write_side.v`)**: Manages binary write pointers (`b_wptr`), converts them to Gray code (`g_wptr`), and evaluates the `full` flag by comparing the next local Gray pointer with the synchronized read pointer[cite: 10].
* **Read Domain (`read_side.v`)**: Manages binary read pointers (`b_rptr`), converts them to Gray code (`g_rptr`), and evaluates the `empty` flag[cite: 8].
* **Pointer Synchronizer (`synchronizer.v`)**: Employs a 2-stage Flip-Flop (2-FF) cross-domain synchronizer to safely pass Gray-coded pointers between clock domains[cite: 7, 9].

---

## File Structure

.
├── fifo.v            # Top-level module interconnecting write, read, and synchronizer modules
├── write_side.v      # Write pointer logic and clocked full flag generator
├── read_side.v       # Read pointer logic and combinational empty flag generator
├── synchronizer.v    # 2-stage D-Flip-Flop cross-domain pointer synchronizer
└── async_fifo_tb.v   # Testbench with asynchronous clock domains and burst verification

---

## Output Waveform of Used Testbench

<img width="1574" height="808" alt="Screenshot 2026-08-13 004516" src="https://github.com/user-attachments/assets/6a720662-fe84-4be3-bdd6-22ebfc6cfb4f" />
