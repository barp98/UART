module transmitter_shift_register(
    input logic     clk,
    input logic     bclk,
    input logic     rst_n,   
    input logic     tsr_tx_en,  
    input logic     [15:0] tsr_d,
    output logic    tsr_busy,
    output logic    tsr_q
);

logic [4:0] bit_counter = 0;
logic [4:0] ovsp_counter = 0;
logic tsr_q_reg;

always_ff @(posedge clk) begin
    
    if (!rst_n) begin     
        bit_counter <= 0;
        ovsp_counter <= 0;
        tsr_q_reg <= 1;
        tsr_busy <= 0;   
    end
    
    else begin

        if (tsr_tx_en && bclk) begin
            
            tsr_busy <= 1'b1;

            if (bit_counter < 1'b1) begin 
                
                if (ovsp_counter < 5'hF) begin
                    tsr_q_reg <= 1'b0;
                    ovsp_counter <= ovsp_counter + 1;
                end

                else begin
                    bit_counter <= bit_counter + 1;
                    ovsp_counter <= 0;
                end
 
            end

            else if (bit_counter >= 1'b1 && bit_counter < 4'h9) begin
               
               if (ovsp_counter < 5'hF) begin
                    tsr_q_reg <= tsr_d [bit_counter - 1];
                    ovsp_counter <= ovsp_counter + 1;
                end

                else begin
                    bit_counter <= bit_counter + 1;
                    ovsp_counter <= 0;
                end

            end

            else if (bit_counter == 4'h9) begin
                
                if (ovsp_counter < 5'hF) begin
                    tsr_q_reg <= 1'b1;
                    ovsp_counter <= ovsp_counter + 1;
                end

                else begin
                    bit_counter <= bit_counter + 1;
                    ovsp_counter <= 0;
                end
              
            end

            else begin
                tsr_busy <= 0;
                bit_counter <=0;
                ovsp_counter <= 0;
                tsr_q_reg <= 1'b1;
            end

        end

        else if (tsr_tx_en && !bclk) begin
            tsr_busy <= 1'b1;
        end
        
        else begin
                tsr_busy <= 1'b0;
                bit_counter <= 0;
                ovsp_counter <= 0;
                tsr_q_reg <= 1'b1;
            end
        
    end

end
    
assign tsr_q = tsr_q_reg;

endmodule