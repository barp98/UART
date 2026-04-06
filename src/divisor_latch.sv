module divisor_latch(
    input logic clk,
    input logic rst_n,
    input logic [15:0] dvl_d,
    output logic [15:0] dvl_q
);

always_ff @(posedge clk) begin
    
    if (!rst_n) dvl_q <= 16'b0;
    else dvl_q <= dvl_d;
    
end

endmodule