`timescale 1ns/1ps
`include "src/uart_top.sv"

/*module uart_top_tb;

    logic clk;
    logic rst_n;
    logic lcr_we;
    logic data_stb;
    logic [15:0] data_bus_in;
    logic [15:0] dvl_d;
    logic uart_rx;
    logic uart_tx;

    int tx_pass = 0;
    int tx_fail = 0;
    int rx_pass = 0;
    int rx_fail = 0;

    byte test_byte;
    int i;

    uart_top dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .lcr_we      (lcr_we),
        .data_stb    (data_stb),
        .data_bus_in (data_bus_in),
        .dvl_d       (dvl_d),
        .uart_rx     (uart_rx),
        .uart_tx     (uart_tx)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    localparam int DIV_VAL = 10;

    initial begin
        $dumpfile("uart_top_tb.vcd");
        $dumpvars(0, uart_top_tb);
    end

    task automatic wait_bclk_ticks(input int n);
        int j;
        begin
            for (j = 0; j < n; j = j + 1)
                @(posedge dut.bclk);
        end
    endtask

    task automatic reset_dut;
        begin
            rst_n       = 1'b0;
            lcr_we      = 1'b0;
            data_stb    = 1'b0;
            data_bus_in = 16'h0000;
            dvl_d       = DIV_VAL;
            uart_rx     = 1'b1;

            repeat (8) @(posedge clk);
            rst_n = 1'b1;
            repeat (8) @(posedge clk);
        end
    endtask

    // keep data_bus_in stable until the next write replaces it
    task automatic write_tx_byte(input byte b);
        begin
            @(negedge clk);
            data_bus_in = {8'h00, b};
            data_stb    = 1'b1;

            @(posedge clk);
            @(negedge clk);
            data_stb    = 1'b0;
        end
    endtask

    task automatic drive_rx_byte(input byte b);
        int k;
        begin
            uart_rx = 1'b1;
            wait_bclk_ticks(32);

            uart_rx = 1'b0; // start bit
            wait_bclk_ticks(16);

            for (k = 0; k < 8; k = k + 1) begin
                uart_rx = b[k];
                wait_bclk_ticks(16);
            end

            uart_rx = 1'b1; // stop bit
            wait_bclk_ticks(16);

            uart_rx = 1'b1; // extra idle time
            wait_bclk_ticks(32);
        end
    endtask

    task automatic check_tx_byte(input byte expected);
        byte got;
        int k;
        int timeout;
        begin
            got = 8'h00;

            timeout = 0;
            while ((uart_tx !== 1'b0) && (timeout < 20000)) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 20000) begin
                $display("TX FAIL: timeout waiting for start bit, expected=%02h time=%0t", expected, $time);
                tx_fail = tx_fail + 1;
                disable check_tx_byte;
            end

            // middle of first data bit
            wait_bclk_ticks(24);

            for (k = 0; k < 8; k = k + 1) begin
                got[k] = uart_tx;
                if (k < 7)
                    wait_bclk_ticks(16);
            end

            // middle of stop bit
            wait_bclk_ticks(16);

            if (uart_tx !== 1'b1) begin
                $display("TX FAIL: bad stop bit, expected=%02h got=%02h time=%0t", expected, got, $time);
                tx_fail = tx_fail + 1;
            end
            else if (got === expected) begin
                $display("TX PASS: expected=%02h got=%02h", expected, got);
                tx_pass = tx_pass + 1;
            end
            else begin
                $display("TX FAIL: expected=%02h got=%02h", expected, got);
                tx_fail = tx_fail + 1;
            end

            wait_bclk_ticks(16);
        end
    endtask

    // RX check simplified:
    // wait after the frame, then sample the receive buffer directly
    task automatic check_rx_byte(input byte expected);
        byte got;
        begin
            wait_bclk_ticks(32);
            got = dut.rx_buf_q[7:0];

            if (got === expected) begin
                $display("RX PASS: expected=%02h got=%02h", expected, got);
                rx_pass = rx_pass + 1;
            end
            else begin
                $display("RX FAIL: expected=%02h got=%02h time=%0t", expected, got, $time);
                rx_fail = rx_fail + 1;
            end
        end
    endtask

    initial begin
        $display("====================================");
        $display("UART randomized TX/RX test starting");
        $display("====================================");

        reset_dut();

        for (i = 0; i < 100; i = i + 1) begin
            test_byte = $urandom_range(0,255);
            write_tx_byte(test_byte);
            check_tx_byte(test_byte);
            wait_bclk_ticks(32);
        end

        reset_dut();

        for (i = 0; i < 100; i = i + 1) begin
            test_byte = $urandom_range(0,255);
            drive_rx_byte(test_byte);
            check_rx_byte(test_byte);
            wait_bclk_ticks(32);
        end

        $display("====================================");
        $display("TEST SUMMARY");
        $display("TX PASS = %0d", tx_pass);
        $display("TX FAIL = %0d", tx_fail);
        $display("RX PASS = %0d", rx_pass);
        $display("RX FAIL = %0d", rx_fail);
        $display("====================================");

        if ((tx_fail == 0) && (rx_fail == 0))
            $display("OVERALL RESULT: PASS");
        else
            $display("OVERALL RESULT: FAIL");

        $finish;
    end
*/

module uart_top_tb;

    logic clk;
    logic rst_n;
    logic data_stb;
    logic [15:0] data_bus_in;
    logic [15:0] dvl_d;
    logic uart_rx;
    logic uart_tx;

    int tx_pass = 0;
    int tx_fail = 0;
    int rx_pass = 0;
    int rx_fail = 0;

    int total_pass = 0;
    int total_fail = 0;

    byte test_byte;
    int i;

    byte directed_patterns [0:11];

    uart_top dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .data_stb    (data_stb),
        .data_bus_in (data_bus_in),
        .dvl_d       (dvl_d),
        .uart_rx     (uart_rx),
        .uart_tx     (uart_tx)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    localparam int DIV_VAL = 10;

    initial begin
        $dumpfile("sim/uart_top_tb.vcd");
        $dumpvars(0, uart_top_tb);
    end

    initial begin
        directed_patterns[0]  = 8'h00;
        directed_patterns[1]  = 8'hFF;
        directed_patterns[2]  = 8'h01;
        directed_patterns[3]  = 8'h80;
        directed_patterns[4]  = 8'h55;
        directed_patterns[5]  = 8'hAA;
        directed_patterns[6]  = 8'h7F;
        directed_patterns[7]  = 8'hFE;
        directed_patterns[8]  = 8'h0F;
        directed_patterns[9]  = 8'hF0;
        directed_patterns[10] = 8'h33;
        directed_patterns[11] = 8'hCC;
    end

    task automatic wait_bclk_ticks(input int n);
        int j;
        begin
            for (j = 0; j < n; j = j + 1)
                @(posedge dut.bclk);
        end
    endtask

    task automatic reset_dut;
        begin
            rst_n       = 1'b0;
            data_stb    = 1'b0;
            data_bus_in = 16'h0000;
            dvl_d       = DIV_VAL;
            uart_rx     = 1'b1;

            repeat (8) @(posedge clk);
            rst_n = 1'b1;
            repeat (8) @(posedge clk);
        end
    endtask

    task automatic write_tx_byte(input byte b);
        begin
            @(negedge clk);
            data_bus_in = {8'h00, b};
            data_stb    = 1'b1;

            @(posedge clk);
            @(negedge clk);
            data_stb    = 1'b0;
        end
    endtask

    task automatic drive_rx_byte(input byte b, input int idle_before, input int idle_after);
        int k;
        begin
            uart_rx = 1'b1;
            wait_bclk_ticks(idle_before);

            uart_rx = 1'b0; // start
            wait_bclk_ticks(16);

            for (k = 0; k < 8; k = k + 1) begin
                uart_rx = b[k];
                wait_bclk_ticks(16);
            end

            uart_rx = 1'b1; // stop
            wait_bclk_ticks(16);

            uart_rx = 1'b1;
            wait_bclk_ticks(idle_after);
        end
    endtask

    task automatic check_tx_byte(input byte expected);
        byte got;
        int k;
        int timeout;
        begin
            got = 8'h00;

            timeout = 0;
            while ((uart_tx !== 1'b0) && (timeout < 20000)) begin
                @(posedge clk);
                timeout = timeout + 1;
            end

            if (timeout >= 20000) begin
                $display("TX FAIL: timeout waiting for start bit, expected=%02h time=%0t", expected, $time);
                tx_fail = tx_fail + 1;
                total_fail = total_fail + 1;
                disable check_tx_byte;
            end

            wait_bclk_ticks(24); // 1.5 bit-times

            for (k = 0; k < 8; k = k + 1) begin
                got[k] = uart_tx;
                if (k < 7)
                    wait_bclk_ticks(16);
            end

            wait_bclk_ticks(16); // stop bit center

            if (uart_tx !== 1'b1) begin
                $display("TX FAIL: bad stop bit, expected=%02h got=%02h time=%0t", expected, got, $time);
                tx_fail = tx_fail + 1;
                total_fail = total_fail + 1;
            end
            else if (got === expected) begin
                $display("TX PASS: expected=%02h got=%02h", expected, got);
                tx_pass = tx_pass + 1;
                total_pass = total_pass + 1;
            end
            else begin
                $display("TX FAIL: expected=%02h got=%02h", expected, got);
                tx_fail = tx_fail + 1;
                total_fail = total_fail + 1;
            end

            wait_bclk_ticks(16);
        end
    endtask

    task automatic check_rx_byte(input byte expected);
        byte got;
        begin
            wait_bclk_ticks(32);
            got = dut.rx_buf_q[7:0];

            if (got === expected) begin
                $display("RX PASS: expected=%02h got=%02h", expected, got);
                rx_pass = rx_pass + 1;
                total_pass = total_pass + 1;
            end
            else begin
                $display("RX FAIL: expected=%02h got=%02h time=%0t", expected, got, $time);
                rx_fail = rx_fail + 1;
                total_fail = total_fail + 1;
            end
        end
    endtask

    task automatic tx_case(input byte b, input int gap_ticks);
        begin
            write_tx_byte(b);
            check_tx_byte(b);
            wait_bclk_ticks(gap_ticks);
        end
    endtask

    task automatic rx_case(input byte b, input int idle_before, input int idle_after);
        begin
            drive_rx_byte(b, idle_before, idle_after);
            check_rx_byte(b);
        end
    endtask

    task automatic tx_burst_test(input int count, input int gap_ticks);
        int n;
        byte b;
        begin
            for (n = 0; n < count; n = n + 1) begin
                b = $urandom_range(0,255);
                tx_case(b, gap_ticks);
            end
        end
    endtask

    task automatic rx_burst_test(input int count, input int idle_before, input int idle_after);
        int n;
        byte b;
        begin
            for (n = 0; n < count; n = n + 1) begin
                b = $urandom_range(0,255);
                rx_case(b, idle_before, idle_after);
            end
        end
    endtask

    task automatic tx_directed_test;
        int n;
        begin
            $display("------------------------------------");
            $display("TX directed patterns");
            $display("------------------------------------");
            for (n = 0; n < 12; n = n + 1)
                tx_case(directed_patterns[n], 32);
        end
    endtask

    task automatic rx_directed_test;
        int n;
        begin
            $display("------------------------------------");
            $display("RX directed patterns");
            $display("------------------------------------");
            for (n = 0; n < 12; n = n + 1)
                rx_case(directed_patterns[n], 32, 32);
        end
    endtask

    task automatic tx_random_test(input int count);
        int n;
        byte b;
        begin
            $display("------------------------------------");
            $display("TX random test");
            $display("------------------------------------");
            for (n = 0; n < count; n = n + 1) begin
                b = $urandom_range(0,255);
                tx_case(b, $urandom_range(8,40));
            end
        end
    endtask

    task automatic rx_random_test(input int count);
        int n;
        byte b;
        int idle_before;
        int idle_after;
        begin
            $display("------------------------------------");
            $display("RX random test");
            $display("------------------------------------");
            for (n = 0; n < count; n = n + 1) begin
                b = $urandom_range(0,255);
                idle_before = $urandom_range(8,40);
                idle_after  = $urandom_range(8,40);
                rx_case(b, idle_before, idle_after);
            end
        end
    endtask

    task automatic tx_back_to_back_test;
        int n;
        byte b;
        begin
            $display("------------------------------------");
            $display("TX back-to-back stress");
            $display("------------------------------------");
            for (n = 0; n < 32; n = n + 1) begin
                b = $urandom_range(0,255);
                tx_case(b, 0);
            end
        end
    endtask

    task automatic rx_back_to_back_test;
        int n;
        byte b;
        begin
            $display("------------------------------------");
            $display("RX back-to-back stress");
            $display("------------------------------------");
            for (n = 0; n < 32; n = n + 1) begin
                b = $urandom_range(0,255);
                rx_case(b, 0, 0);
            end
        end
    endtask

    task automatic tx_reset_recovery_test;
        byte b;
        begin
            $display("------------------------------------");
            $display("TX reset recovery");
            $display("------------------------------------");

            b = 8'hA5;
            write_tx_byte(b);

            // let TX start, then reset in the middle
            wait_bclk_ticks(20);

            rst_n = 1'b0;
            repeat (4) @(posedge clk);
            rst_n = 1'b1;
            repeat (8) @(posedge clk);

            // after reset, line should idle high and next byte should still work
            tx_case(8'h3C, 32);
        end
    endtask

    task automatic rx_reset_recovery_test;
        begin
            $display("------------------------------------");
            $display("RX reset recovery");
            $display("------------------------------------");

            uart_rx = 1'b1;
            wait_bclk_ticks(16);

            uart_rx = 1'b0; // start half frame
            wait_bclk_ticks(16);
            uart_rx = 1'b1;
            wait_bclk_ticks(16);
            uart_rx = 1'b0;
            wait_bclk_ticks(16);

            rst_n = 1'b0;
            repeat (4) @(posedge clk);
            rst_n = 1'b1;
            repeat (8) @(posedge clk);

            rx_case(8'hC3, 32, 32);
        end
    endtask

    initial begin
        $display("====================================");
        $display("UART extended TX/RX stress test");
        $display("====================================");

        reset_dut();

        tx_directed_test();
        tx_random_test(100);
        tx_back_to_back_test();
        tx_reset_recovery_test();

        reset_dut();

        rx_directed_test();
        rx_random_test(100);
        rx_back_to_back_test();
        rx_reset_recovery_test();

        $display("====================================");
        $display("FINAL SUMMARY");
        $display("TX PASS    = %0d", tx_pass);
        $display("TX FAIL    = %0d", tx_fail);
        $display("RX PASS    = %0d", rx_pass);
        $display("RX FAIL    = %0d", rx_fail);
        $display("TOTAL PASS = %0d", total_pass);
        $display("TOTAL FAIL = %0d", total_fail);
        $display("====================================");

        if (total_fail == 0)
            $display("OVERALL RESULT: PASS");
        else
            $display("OVERALL RESULT: FAIL");

        $finish;
    end


  
`ifndef WAVE_DEPTH
  `define WAVE_DEPTH 0   // 0 = full hierarchy; or set a small int for depth
`endif
  initial begin
`ifdef FST_DUMP
    $dumpfile("sim/uart_top_tb.fst");
`else
    $dumpfile("sim/uart_top_tb.vcd");
`endif
    $dumpvars(`WAVE_DEPTH, uart_top_tb);
end

endmodule