module receiver_buffer_register(
    input logic clk,
    input logic rst_n,
    input logic load_rbr,
    input logic [7:0] rx_buf_d,
    output logic rbr_empty,
    output logic [7:0] rx_buf_q
);

always_ff @(posedge clk) begin
    
    if (!rst_n) begin
        rx_buf_q <= 8'b0;
        rbr_empty <= 1;
    end
    
    else begin
        
        if (load_rbr) begin
            rx_buf_q <= rx_buf_d;
            rbr_empty <= 0;
        end

        else
            rbr_empty <= 1;

    end
    
end

endmodule