`timescale 1ns/1ps

module tb_tis100;

    localparam int NUM_TESTS = 5;

    logic clk;
    logic rst;

    logic [15:0] IN_A_data;
    logic        IN_A_valid;
    logic        IN_A_ready;

    logic [15:0] OUT_A_data;
    logic        OUT_A_valid;
    logic        OUT_A_ready;

    logic [15:0] N1in_data, N3in_data, N4in_data;
    logic        N1in_valid, N3in_valid, N4in_valid;
    logic        N1in_ready, N3in_ready, N4in_ready;

    logic [15:0] N9out_data, N10out_data, N12out_data;
    logic        N9out_valid, N10out_valid, N12out_valid;
    logic        N9out_ready, N10out_ready, N12out_ready;

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

    int unsigned test_vals    [0:NUM_TESTS-1] = '{66, 34, 88, 91, 53};
    int unsigned expected_vals[0:NUM_TESTS-1] = '{132, 68, 176, 182, 106};

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
        .clk(clk),
        .rst(rst),

        .N1in_data (N1in_data), .N1in_valid (N1in_valid), .N1in_ready (N1in_ready),
        .N2in_data (IN_A_data), .N2in_valid (IN_A_valid), .N2in_ready (IN_A_ready),
        .N3in_data (N3in_data), .N3in_valid (N3in_valid), .N3in_ready (N3in_ready),
        .N4in_data (N4in_data), .N4in_valid (N4in_valid), .N4in_ready (N4in_ready),

        .N9out_data (N9out_data),   .N9out_valid (N9out_valid),   .N9out_ready (N9out_ready),
        .N10out_data(N10out_data),  .N10out_valid(N10out_valid),  .N10out_ready(N10out_ready),
        .N11out_data(OUT_A_data),   .N11out_valid(OUT_A_valid),   .N11out_ready(OUT_A_ready),
        .N12out_data(N12out_data),  .N12out_valid(N12out_valid),  .N12out_ready(N12out_ready)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic wait_cycles(input int n);
        repeat (n) @(posedge clk);
    endtask

    task automatic start_input(input logic [15:0] v);
        begin
            @(negedge clk);
            IN_A_data  = v;
            IN_A_valid = 1'b1;
        end
    endtask

    task automatic wait_and_check_output(
        input int idx,
        input logic [15:0] expected
    );
        logic [15:0] got;
        begin
            while (OUT_A_valid) begin
                @(posedge clk);
                #1;
            end

            forever begin
                @(posedge clk);
                #1;
                if (OUT_A_valid && OUT_A_ready) begin
                    got = OUT_A_data;
                    if (got === expected) begin
                        $display("[%0t] TEST %0d PASS | IN=%0d | OUT=%0d | EXPECTED=%0d",
                                 $time, idx, IN_A_data, got, expected);
                    end
                    else begin
                        $error("[%0t] TEST %0d FAIL | IN=%0d | OUT=%0d | EXPECTED=%0d",
                               $time, idx, IN_A_data, got, expected);
                    end
                    break;
                end
            end

            while (OUT_A_valid) begin
                @(posedge clk);
                #1;
            end
        end
    endtask

    initial begin
        rst         = 1'b1;
        IN_A_valid  = 1'b1;   // همیشه معتبر
        IN_A_data   = test_vals[0][15:0];

        N1in_valid   = 1'b0;
        N3in_valid   = 1'b0;
        N4in_valid   = 1'b0;

        N1in_data    = 16'd0;
        N3in_data    = 16'd0;
        N4in_data    = 16'd0;

        OUT_A_ready  = 1'b1;
        N9out_ready  = 1'b1;
        N10out_ready = 1'b1;
        N12out_ready = 1'b1;

        wait_cycles(10);
        rst = 1'b0;
        wait_cycles(5);

        for (int i = 0; i < NUM_TESTS; i++) begin
            $display("--------------------------------------------------");
            $display("Starting TEST %0d | IN_A=%0d | EXPECTED=%0d",
                     i+1, test_vals[i], expected_vals[i]);

            start_input(test_vals[i][15:0]);
            wait_and_check_output(i+1, expected_vals[i][15:0]);

            wait_cycles(10);
        end

        $display("All tests finished.");
        $stop;
    end

endmodule