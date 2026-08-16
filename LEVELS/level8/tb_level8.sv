`timescale 1ns/1ps

module tb_top_tis100_signal_edge();

    // --------------------------------------------------------
    // Clock and Reset Signals
    // --------------------------------------------------------
    logic clk;
    logic rst;

    // --------------------------------------------------------
    // Node Interfaces
    // --------------------------------------------------------
    logic [15:0] N1in_data, N2in_data, N3in_data, N4in_data;
    logic        N1in_valid, N2in_valid, N3in_valid, N4in_valid;
    logic        N1in_ready, N2in_ready, N3in_ready, N4in_ready;

    logic [15:0] N9out_data, N10out_data, N11out_data, N12out_data;
    logic        N9out_valid, N10out_valid, N11out_valid, N12out_valid;
    logic        N9out_ready, N10out_ready, N11out_ready, N12out_ready;

    // --------------------------------------------------------
    // Parameters & Instantiation (As requested)
    // --------------------------------------------------------
    localparam string PROG_N1  = "N1_machine.txt";
    localparam string PROG_N2  = "N2_machine.txt";
    localparam string PROG_N3  = "N3_machine.txt";
    localparam string PROG_N4  = "N4_machine.txt";
    localparam string PROG_N5  = "N5_machine.txt";
    localparam string PROG_N6  = "N6_machine.txt";
    localparam string PROG_N7  = "N7_machine.txt";
    localparam string PROG_N8  = "N8_machine.txt";
    localparam string PROG_N9  = "N9_machine.txt";
    localparam string PROG_N10 = "N10_machine.txt";
    localparam string PROG_N11 = "N11_machine.txt";
    localparam string PROG_N12 = "N12_machine.txt";

    top_tis100 #(
        .PROG_N1 (PROG_N1),
        .PROG_N2 (PROG_N2),
        .PROG_N3 (PROG_N3),
        .PROG_N4 (PROG_N4),
        .PROG_N5 (PROG_N5),
        .PROG_N6 (PROG_N6),
        .PROG_N7 (PROG_N7),
        .PROG_N8 (PROG_N8),
        .PROG_N9 (PROG_N9),
        .PROG_N10(PROG_N10),
        .PROG_N11(PROG_N11),
        .PROG_N12(PROG_N12)
    ) dut (
        .clk(clk), .rst(rst),
        .N1in_data(N1in_data),   .N1in_valid(N1in_valid),   .N1in_ready(N1in_ready),
        .N2in_data(N2in_data),   .N2in_valid(N2in_valid),   .N2in_ready(N2in_ready), // IN
        .N3in_data(N3in_data),   .N3in_valid(N3in_valid),   .N3in_ready(N3in_ready),
        .N4in_data(N4in_data),   .N4in_valid(N4in_valid),   .N4in_ready(N4in_ready),
        .N9out_data(N9out_data),   .N9out_valid(N9out_valid),   .N9out_ready(N9out_ready),
        .N10out_data(N10out_data), .N10out_valid(N10out_valid), .N10out_ready(N10out_ready),
        .N11out_data(N11out_data), .N11out_valid(N11out_valid), .N11out_ready(N11out_ready), // OUT
        .N12out_data(N12out_data), .N12out_valid(N12out_valid), .N12out_ready(N12out_ready)
    );

    // --------------------------------------------------------
    // Clock Generation
    // --------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz Clock
    end

    // --------------------------------------------------------
    // Test Vectors (Extracted strictly from image_9634bb.jpg)
    // --------------------------------------------------------
    localparam NUM_CASES = 34;

    // SystemVerilog automatically handles negative literal conversion to 16-bit 2's complement
    logic [15:0] in_arr [0:NUM_CASES-1] = '{
         0,  32,  30,  27,  24,  28,  37,  33,  24,  13,  9,  13,  12, 
        14,  23,  21,  23,  19,   9,  18,   8,  -3,   6, 14,  25,  15, 
        14,   3,   2,  -1, -10,  -7,  -7, -11
    };
    
    logic [15:0] expected_out_arr [0:NUM_CASES-1] = '{
        0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1,
        0, 1, 0, 0, 0, 0, 0, 0
    };

    // --------------------------------------------------------
    // Main Test Procedure (Self-Checking)
    // --------------------------------------------------------
    integer errors = 0;

    initial begin
        // Initialize signals
        rst = 1;
        
        // Tie off unused inputs
        N1in_valid = 0; N1in_data = 0;
        N3in_valid = 0; N3in_data = 0;
        N4in_valid = 0; N4in_data = 0;
        
        // Tie off unused outputs (always ready to accept data to prevent stalls)
        N9out_ready  = 1;
        N10out_ready = 1;
        N12out_ready = 1;

        // Initialize active inputs/outputs
        N2in_valid = 0; N2in_data = 0;
        N11out_ready = 0;

        // Apply reset
        #20;
        rst = 0;
        #20;

        $display("--------------------------------------------------");
        $display("Starting SELF-CHECKING Test for SIGNAL EDGE DETECTOR");
        $display("--------------------------------------------------");

        // Run Driver and Monitor concurrently
        fork
            // Thread 1: Drive IN (N2)
            begin
                for (int i = 0; i < NUM_CASES; i++) begin
                    @(posedge clk);
                    N2in_valid = 1;
                    N2in_data  = in_arr[i];
                    // Wait for handshake
                    wait(N2in_ready == 1);
                    @(posedge clk);
                    N2in_valid = 0;
                end
            end

            // Thread 2: Monitor OUT (N11) and Check Results
            begin
                N11out_ready = 1; // Always ready to receive
                
                for (int i = 0; i < NUM_CASES; i++) begin
                    @(posedge clk);
                    wait(N11out_valid == 1); // Wait for valid data from DUT
                    
                    // We use $signed() for printing so negative numbers display correctly
                    if (N11out_data !== expected_out_arr[i]) begin
                        $error("MISMATCH! Output #%0d (For IN=%0d): Expected = %0d, Got = %0d", 
                                i+1, $signed(in_arr[i]), expected_out_arr[i], $signed(N11out_data));
                        errors++;
                    end else begin
                        $display("MATCH: Output #%0d received successfully: %0d", i+1, $signed(N11out_data));
                    end
                    @(posedge clk); // Advance clock to complete handshake
                end
                N11out_ready = 0;
            end
        join

        // --------------------------------------------------------
        // Test Result Summary
        // --------------------------------------------------------
        $display("--------------------------------------------------");
        if (errors == 0) begin
            $display("TEST PASSED! All %0d outputs matched perfectly.", NUM_CASES);
        end else begin
            $display("TEST FAILED with %0d mismatches.", errors);
        end
        $display("--------------------------------------------------");
        
        #100;
        $stop;
    end

endmodule