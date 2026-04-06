`timescale 1ns/1ps
`include "src/uart_top.sv"

module uart_top_tb;

    logic        clk;
    logic        rst_n;
    logic        data_stb;
    logic [15:0] data_bus_in;
    logic [15:0] dvl_d;
    logic        uart_rx;
    logic [7:0]  rx_buf_q;
    logic        uart_tx;

    uart_top dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .data_stb    (data_stb),
        .data_bus_in (data_bus_in),
        .dvl_d       (dvl_d),
        .uart_rx     (uart_rx),
        .rx_buf_q    (rx_buf_q),
        .uart_tx     (uart_tx)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // TX -> RX loopback
    assign uart_rx = uart_tx;

    initial begin
        $dumpfile("sim/uart_top_demo.vcd");
        $dumpvars(0, uart_top_tb);

        rst_n       = 1'b0;
        data_stb    = 1'b0;
        data_bus_in = 16'h0000;
        dvl_d       = 16'd10;

        repeat (8) @(posedge clk);
        rst_n = 1'b1;
        repeat (8) @(posedge clk);

        // one transmitted byte
        @(negedge clk);
        data_bus_in = 16'h00A5;
        data_stb    = 1'b1;

        @(posedge clk);
        @(negedge clk);
        data_stb    = 1'b0;

        // wait for full TX and RX completion
        repeat (220) @(posedge dut.bclk);

        $display("TX sent = %02h", data_bus_in[7:0]);
        $display("RX got  = %02h", rx_buf_q);

        $finish;
    end

endmodule