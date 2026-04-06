module baud_rate_generator (
    input logic clk,
    input logic rst_n, 
    input logic [15:0] oversample_factor, 
    input logic [15:0] divisor,
    output logic bclk
);

logic [15:0] baud_counter;
logic bclk_reg;


always @(posedge clk or negedge rst_n) //reconsider
    begin
        if (!rst_n) begin
            baud_counter <= 0;
            bclk_reg <= 0;
        end

        else if (baud_counter != divisor) begin
            baud_counter <= baud_counter + 1;
            bclk_reg <= 0;
        end

        else if (baud_counter == divisor) begin
            baud_counter <= 0;
            bclk_reg <= 1;
        end
    end

assign bclk = bclk_reg;
endmodule