`include "src/baud_rate_generator.sv"
`include "src/divisor_latch.sv"
`include "src/transmitter_hold_register.sv"
`include "src/transmitter_shift_register.sv"
`include "src/tx_control_logic.sv"
`include "src/rx_control_logic.sv"
`include "src/receiver_buffer_register.sv"
`include "src/receiver_shift_register.sv"

module uart_top(
    input logic clk,
    input logic rst_n,
    input logic data_stb,
    input logic [15:0] data_bus_in,
    input logic [15:0] dvl_d,
    input logic uart_rx,
    output logic [7:0] rx_buf_q,
    output logic uart_tx
);

wire        bclk;
wire        load_tsr;
wire        thr_empty;
wire [15:0] dvl_q;
wire [15:0] tx_hold_q;
wire        tsr_busy;
wire        tsr_tx_en;
wire [7:0]  rsr_q;
wire        rsr_rx_en;
wire        load_rbr;
wire        rsr_data_valid;
wire        rbr_empty;
wire        rsr_busy;


    baud_rate_generator baud_rate_generator (
        .clk        (clk),
        .rst_n      (rst_n), 
        .divisor    (dvl_q[15:0]),
        .bclk       (bclk)
    );

    divisor_latch divisor_latch (
        .clk        (clk),
        .rst_n      (rst_n), 
        .dvl_d      (dvl_d),
        .dvl_q      (dvl_q)
    );
    
    //....RX....//

    rx_control_logic rx_control_logic (
        .clk            (clk),
        .bclk           (bclk),
        .rst_n          (rst_n),
        .rbr_empty      (rbr_empty),
        .rsr_data_valid (rsr_data_valid),
        .rsr_busy       (rsr_busy),
        .rx_d           (uart_rx),
        .load_rbr       (load_rbr),
        .rsr_rx_en      (rsr_rx_en)
    );

    receiver_shift_register receiver_shift_register (
        .clk       (clk),
        .rst_n     (rst_n),
        .bclk      (bclk),
        .rsr_rx_en (rsr_rx_en),
        .rsr_d     (uart_rx),
        .rsr_busy  (rsr_busy),
        .rsr_data_valid (rsr_data_valid),
        .rsr_q     (rsr_q)
    );

    receiver_buffer_register receiver_buffer_register (
        .clk            (clk),
        .rst_n          (rst_n),
        .load_rbr       (load_rbr),
        .rx_buf_d       (rsr_q),
        .rbr_empty      (rbr_empty),
        .rx_buf_q       (rx_buf_q)
    );
    
    //....TX....//

    tx_control_logic tx_control_logic (
        .clk       (clk),
        .bclk      (bclk),
        .rst_n     (rst_n),
        .thr_empty (thr_empty),
        .data_stb  (data_stb),
        .tsr_busy  (tsr_busy),
        .load_tsr  (load_tsr),
        .tsr_tx_en (tsr_tx_en)
    );

    transmitter_hold_register transmitter_hold_register (
        .clk       (clk),
        .rst_n     (rst_n),
        .load_tsr  (load_tsr),
        .tx_hold_d (data_bus_in),
        .thr_empty (thr_empty),
        .tx_hold_q (tx_hold_q)
    );

    transmitter_shift_register transmitter_shift_register (
        .clk         (clk),
        .bclk        (bclk),
        .rst_n       (rst_n),
        .tsr_tx_en   (tsr_tx_en),
        .tsr_d       (tx_hold_q),
        .tsr_busy    (tsr_busy),
        .tsr_q       (uart_tx)
    );


endmodule