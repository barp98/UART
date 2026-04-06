module receiver_shift_register(
    input logic     clk,
    input logic     rst_n,
    input logic     bclk,
    input logic     rsr_rx_en,
    input logic     rsr_d,
    output logic    rsr_busy,
    output logic    rsr_data_valid,
    output logic    [7:0] rsr_q
);

logic [4:0] ovsp_counter;
logic [4:0] bit_counter;

always_ff @(posedge clk) begin

    if (!rst_n) begin
        rsr_busy <= 0;
        ovsp_counter <= 0;
        bit_counter <= 0;
        rsr_q <= 8'b0;
        rsr_data_valid <= 0;
    end

    else begin

        rsr_data_valid <= 0;

        if (!rsr_rx_en) begin 
            if (!rsr_d) begin
                rsr_busy <= 1;
            end
            else rsr_busy <= 0;
        end

        else if (rsr_rx_en) begin
            
            rsr_busy <= 1;

            if (bclk && bit_counter < 4'h8) begin

                if (ovsp_counter < 5'hF) begin
                    ovsp_counter <= ovsp_counter + 1;
                end

                else begin
                    rsr_q [bit_counter] <= rsr_d;
                    bit_counter <= bit_counter + 1;
                    ovsp_counter <= 0;
                end

            end

            else if (bclk && bit_counter >= 4'h8) begin
                rsr_busy <= 0;
                rsr_data_valid <= 1;
                bit_counter <= 0;
                ovsp_counter <= 0;
            end
    
        end
    end
end

endmodule