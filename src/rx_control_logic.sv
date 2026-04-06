module rx_control_logic (    
    input logic clk,
    input logic bclk,
    input logic rst_n,
    input logic rbr_empty,
    input logic rsr_busy,
    input logic rsr_data_valid,
    input logic rx_d,
    output logic load_rbr,
    output logic rsr_rx_en
);

logic [4:0] tick_counter;

typedef enum {IDLE, START, DATA, STOP, LOAD} e_state;
e_state current, next;

always_ff @(posedge clk) begin
	if(!rst_n)
		current <= IDLE;
	else
		current <= next;
end

always_ff @(posedge clk) begin
    	if(!rst_n) begin
            tick_counter <= 0;
            rsr_rx_en <= 0;
        end
end

always_ff @(posedge bclk) begin

    if(current == START) begin
		if (tick_counter < 4'h8) begin
            tick_counter <= tick_counter + 1;
        end
        else begin
            tick_counter <= 0;
        end
    end

    else if(current == DATA) begin
        if (tick_counter < 5'h10) begin
            tick_counter <= tick_counter + 1;
        end
        else begin
            tick_counter <= 0;
        end
    end

	else if (current == STOP) begin
		if (tick_counter < 5'h10) begin
            tick_counter <= tick_counter + 1;
        end
        else begin
            tick_counter <= 0;
        end
    end
end

always_comb begin
    case (current)
        IDLE: begin 
            if(!rx_d) next = START;
            else next = IDLE;
        end 
        START: begin
            if((tick_counter == 4'h7) && !rx_d) next = DATA;
            else if ((tick_counter == 4'h7) && rx_d) next = IDLE; //glitch handling
            else next = START;
        end
        DATA: begin
            if(rsr_data_valid) next = STOP;
            else next = DATA;
        end
        STOP: begin
            if((tick_counter == 5'hF) && rx_d) next = LOAD; 
            else next = STOP;
        end
        LOAD: begin
            if(!rbr_empty) next = IDLE; 
            else next = LOAD;
        end
    endcase
end


always_comb begin
    case (current)
        IDLE: begin
            rsr_rx_en = 0;
            load_rbr = 0;
        end
        START: begin
            rsr_rx_en = 0;
            load_rbr = 0;
        end
        DATA: begin
            rsr_rx_en = 1;
            load_rbr = 0;              
        end
        STOP: begin
            rsr_rx_en = 0;
            load_rbr = 0;  
        end
        LOAD: begin
            rsr_rx_en = 0;
            if (rbr_empty) load_rbr = 1;
            else load_rbr = 0;
        end
    endcase
end




endmodule