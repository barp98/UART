# UART

Universal asynchronous receiver-transmitter in SystemVerilog

# Project Overview

This project is a modular UART implementation written in SystemVerilog. It was built to demonstrate the core transmit and receive behavior of a UART using a clear RTL structure and separate submodules for the main functional blocks.

The design focuses on a simple and practical UART configuration: one start bit, 8 data bits, no parity, and one stop bit. It includes both transmission and reception paths, along with supporting logic such as baud-rate generation, control FSMs, and data buffering.

The project was developed with an emphasis on readability, modularity, and simulation-based verification. Each major UART function is separated into its own module, making the design easier to understand, test, and extend in the future.

The repository also includes testbenches for simulation and waveform inspection, so the behavior of the transmitter and receiver can be verified directly in tools such as Icarus Verilog and GTKWave.

# Architecture

![UART](https://github.com/user-attachments/assets/50c97345-1fef-41ae-a439-b95d116dfffb)

This block diagram shows the high-level structure of the UART system. On the transmit side, parallel input data is first loaded into the Transmitter Hold Register, then passed to the Transmitter Shift Register, which serializes the data frame and sends it over the 1-bit serial line. On the receive side, the Receiver Shift Register samples and reconstructs the incoming serial frame, and the recovered data is then stored in the Receiver Buffer Register. The transmitter and receiver each use dedicated control logic, while the Baud Rate Generator provides the timing needed to keep both sides synchronized during data transfer.

Note that each board has both TX and RX capabilities.

# Results

<img width="1621" height="225" alt="image" src="https://github.com/user-attachments/assets/215e0f0a-53bd-4e02-be35-f23dc87bbf2d" />

The TX results demonstrate correct UART frame generation for the input data 10100101. The transmitter begins by driving the line low for the start bit, then serially outputs the data bits, and finally drives the line high for the stop bit. The observed bit changes are aligned with bclk, showing that transmission timing is properly controlled by the baud-rate generator.

<img width="1620" height="186" alt="image" src="https://github.com/user-attachments/assets/ff31c3cb-39a0-4ece-bf70-17d03d6880f0" />

The RX waveform shows correct reconstruction of the transmitted UART frame. After detecting the start bit on uart_rx, the Receiver Shift Register samples the incoming serial data on the bclk timing ticks and gradually builds the byte until the full value 10100101 is received. Once reception is complete, the data is transferred to the Receiver Buffer Register, where rx_buf_q holds the final recovered byte, confirming successful reception.

# File Structure

UART_TRANSMITTER_PROJECT/
├── docs/
│   └── UART_block_diagram.jpg
├── sim/
│   ├── sim.vvp
│   ├── simv
│   ├── uart_top_demo.vcd
│   └── uart_top_tb.vcd
├── src/
│   ├── baud_rate_generator.sv
│   ├── divisor_latch.sv
│   ├── receiver_buffer_register.sv
│   ├── receiver_shift_register.sv
│   ├── rx_control_logic.sv
│   ├── transmitter_hold_register.sv
│   ├── transmitter_shift_register.sv
│   ├── tx_control_logic.sv
│   └── uart_top.sv
├── test/
│   ├── baud_rate_generator_tb.sv
│   ├── rx_tx_tb.sv
│   └── uart_top_tb.sv
└── README.md
