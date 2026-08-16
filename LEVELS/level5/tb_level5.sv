`timescale 1ns/1ps

module tb_tis100;

    localparam int NUM_TESTS = 5;

    // آرایه‌های تست (بر اساس ستون‌های موجود در تصویر شما)
    int signed test_A_vals [0:NUM_TESTS-1] = '{ -13,  -27,  -29, -17, -19};
    int signed test_S_vals [0:NUM_TESTS-1] = '{ -1,   1,    1,   -1,   0};
    int signed test_B_vals [0:NUM_TESTS-1] = '{  7,   7,    6,   29,  29};

    // پارامترهای مورد انتظار خروجی (بر اساس منطق گره N7)
    // S=-1 => A, S=1 => B, S=0 => A+B
    int signed exp_vals    [0:NUM_TESTS-1] = '{ -13,  7,  6, -17,  10}; 

    // سیگنال‌های سطح بالا
    logic clk;
    logic rst;

    // ورودی‌های سطح بالا (متصل به N2, N3, N4)
    logic signed [15:0] IN_A_data; logic IN_A_valid; logic IN_A_ready;
    logic signed [15:0] IN_S_data; logic IN_S_valid; logic IN_S_ready;
    logic signed [15:0] IN_B_data; logic IN_B_valid; logic IN_B_ready;

    // خروجی سطح بالا (متصل به N11)
    logic signed [15:0] OUT_data; logic OUT_valid; logic OUT_ready;

    // پورت‌های غیرفعال و مسیرهای میان‌بر
    logic [15:0] N1in_data, N4in_data;
    logic        N1in_valid, N4in_valid;
    logic        N1in_ready, N4in_ready;
    logic [15:0] N9out_data, N12out_data;
    logic        N9out_valid, N12out_valid;
    logic        N9out_ready, N12out_ready;
    logic [15:0] N10out_data_unused;
    logic        N10out_valid_unused;

    // پارامترهای فایل‌های کد
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
        .PROG_N1 (PROG_N1), .PROG_N2 (PROG_N2), .PROG_N3 (PROG_N3), .PROG_N4 (PROG_N4),
        .PROG_N5 (PROG_N5), .PROG_N6 (PROG_N6), .PROG_N7 (PROG_N7), .PROG_N8 (PROG_N8),
        .PROG_N9 (PROG_N9), .PROG_N10(PROG_N10), .PROG_N11(PROG_N11), .PROG_N12(PROG_N12)
    ) dut (
        .clk(clk), .rst(rst),
        .N1in_data (N1in_data), .N1in_valid (N1in_valid), .N1in_ready (N1in_ready),
        .N2in_data (IN_A_data), .N2in_valid (IN_A_valid), .N2in_ready (IN_A_ready), // IN.A
        .N3in_data (IN_S_data), .N3in_valid (IN_S_valid), .N3in_ready (IN_S_ready), // IN.S
        .N4in_data (IN_B_data), .N4in_valid (IN_B_valid), .N4in_ready (IN_B_ready), // IN.B
        .N9out_data (N9out_data), .N9out_valid (N9out_valid), .N9out_ready (N9out_ready),
        .N10out_data(N10out_data_unused), .N10out_valid(N10out_valid_unused), .N10out_ready(1'b1),
        .N11out_data(OUT_data),  .N11out_valid(OUT_valid),  .N11out_ready(OUT_ready), // OUT
        .N12out_data(N12out_data),.N12out_valid(N12out_valid),.N12out_ready(N12out_ready)
    );

    // تولید کلاک
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // تسک‌های کمکی
    task automatic wait_cycles(input int n);
        repeat (n) @(posedge clk);
    endtask

    task automatic start_inputs(input int a, input int s, input int b);
        begin
            while (!(IN_A_ready && IN_S_ready && IN_B_ready)) begin
                @(posedge clk);
            end
            @(negedge clk);
            IN_A_data = a; IN_A_valid = 1'b1;
            IN_S_data = s; IN_S_valid = 1'b1;
            IN_B_data = b; IN_B_valid = 1'b1;
            @(posedge clk);
            @(posedge clk);
            IN_A_valid = 1'b0; IN_S_valid = 1'b0; IN_B_valid = 1'b0;
        end
    endtask

    // بلوک اصلی تست
    initial begin
        // تعاریف متغیرهای محلی در بالاترین سطح بلوک (برای جلوگیری از خطای ModelSim)
        int i;
        int out_val;

        rst = 1'b1; IN_A_valid = 1'b0; IN_S_valid = 1'b0; IN_B_valid = 1'b0;
        OUT_ready = 1'b1; N1in_valid = 1'b0; N4in_valid = 1'b0;
        N9out_ready = 1'b1; N12out_ready = 1'b1;

        wait_cycles(10); rst = 1'b0; wait_cycles(5);

        for (i = 0; i < NUM_TESTS; i++) begin
            $display("--------------------------------------------------");
            $display("Starting TEST %0d | A=%0d, S=%0d, B=%0d", i+1, test_A_vals[i], test_S_vals[i], test_B_vals[i]);

            start_inputs(test_A_vals[i], test_S_vals[i], test_B_vals[i]);

            // منتظر خروجی گره N11 می‌شویم
            wait (OUT_valid && OUT_ready);
            out_val = OUT_data;

            if (out_val == exp_vals[i]) begin
                $display("[%0t] TEST %0d PASS (OUT) | S=%0d => OUT=%0d", $time, i+1, test_S_vals[i], out_val);
            end else begin
                $error("[%0t] TEST %0d FAIL (OUT) | Expected=%0d, Got=%0d", $time, i+1, exp_vals[i], out_val);
            end
            
            wait_cycles(10);
        end

        $display("--------------------------------------------------");
        $display("All tests finished.");
        $stop;
    end

endmodule