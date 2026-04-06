module tx_control_logic (    
    input logic clk,
    input logic bclk,
    input logic rst_n,
    input logic data_stb,
    input logic thr_empty,
    input logic tsr_busy,
    output logic load_tsr,
    output logic tsr_tx_en
);

logic [3:0] tick_counter;

typedef enum {IDLE, LOAD, TX} e_state;
e_state current, next;


always_ff @(posedge clk) begin
	if(!rst_n)
		current <= IDLE;
	else
		current <= next;
end

always_comb begin
    case (current)
        IDLE: begin 
            if(data_stb) next = LOAD;
            else next = IDLE;
        end
        LOAD: begin
            if(!thr_empty) next = TX;
            else next = LOAD;
        end
        TX: begin
            if(!tsr_busy) next = IDLE;
            else next = TX;
        end
    endcase
end
    
always_comb begin

    case (current)
        IDLE: begin
            load_tsr = 0;
            tsr_tx_en = 0;
        end
        LOAD: begin
            load_tsr = 1;
            tsr_tx_en = 1;
        end
        TX: begin
            tsr_tx_en = 1;
            load_tsr = 0; 
            end
    endcase
end

endmodule