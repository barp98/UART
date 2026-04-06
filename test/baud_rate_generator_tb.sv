`timescale 1ns/1ps
`include "src/baud_rate_generator.sv"

module baud_rate_generator_tb;

    logic clk;
    logic rst_n; 
    logic chip_en;
    logic [15:0] divisor;
    logic bclk;

baud_rate_generator dut (
    .clk        (clk),
    .rst_n      (rst_n),
    .chip_en    (chip_en),
    .divisor    (divisor),
    .bclk  (bclk)
);

initial clk = 0;
always #5 clk = ~clk;  // toggle clock

initial begin
    rst_n = 0;
    chip_en = 0;

end

always @(posedge clk) begin
    rst_n = 1;
    divisor = 650;
    
    #5

    chip_en = 1;

    #1000000

    chip_en = 0;

    #1000

    $finish;

end
  
`ifndef WAVE_DEPTH
  `define WAVE_DEPTH 0   // 0 = full hierarchy; or set a small int for depth
`endif
  initial begin
`ifdef FST_DUMP
    $dumpfile("baud_rate_generator_tb.fst");
`else
    $dumpfile("baud_rate_generator_tb.vcd");
`endif
    $dumpvars(`WAVE_DEPTH, baud_rate_generator_tb);
end

endmodule