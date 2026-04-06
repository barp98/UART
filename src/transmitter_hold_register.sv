module transmitter_hold_register(
    input logic clk,
    input logic rst_n,
    input logic load_tsr,
    input logic [15:0] tx_hold_d,
    output logic thr_empty,
    output logic [15:0] tx_hold_q
);

always_ff @(posedge clk) begin
    
    if (!rst_n) begin
        
        tx_hold_q <= 16'b0;
        thr_empty <= 1;

    end
    
    else begin

        if (load_tsr && !thr_empty) begin
            thr_empty <= 1'b1;
        end
        
        else if (thr_empty) begin
            tx_hold_q <= tx_hold_d;
            thr_empty <= 1'b0;   
        end
        
    end
end
endmodule