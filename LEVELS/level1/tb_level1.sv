`timescale 1ns/1ps

module tb_tis100;

    localparam int NUM_TESTS = 5;

    // پارامترهای ورودی و خروجی تست‌ها
    int unsigned test_X_vals [0:NUM_TESTS-1] = '{30, 85, 90, 64, 18};
    int unsigned test_A_vals [0:NUM_TESTS-1] = '{13, 56, 23, 62, 32};
    int unsigned exp_X_vals  [0:NUM_TESTS-1] = '{30, 85, 90, 64, 18};
    int unsigned exp_A_vals  [0:NUM_TESTS-1] = '{13, 56, 23, 62, 32};

    // سیگنال‌های سطح بالا (نام‌گذاری دقیق)
    logic clk;
    logic rst;

    logic [15:0] IN_X_data; logic IN_X_valid; logic IN_X_ready;
    logic [15:0] IN_A_data; logic IN_A_valid; logic IN_A_ready;

    logic [15:0] OUT_X_data; logic OUT_X_valid; logic OUT_X_ready;
    logic [15:0] OUT_A_data; logic OUT_A_valid; logic OUT_A_ready;

    // سیگنال‌های غیرفعال گره‌های دیگر
    logic [15:0] N2in_data, N3in_data;
    logic        N2in_valid, N3in_valid;
    logic        N2in_ready, N3in_ready;
    logic [15:0] N10out_data, N11out_data;
    logic        N10out_valid, N11out_valid;
    logic        N10out_ready, N11out_ready;

    // برنامه‌های گره‌ها
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

    // وهله‌سازی (Instantiation)
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
        .N1in_data (IN_X_data), .N1in_valid (IN_X_valid), .N1in_ready (IN_X_ready),
        .N2in_data (N2in_data), .N2in_valid (N2in_valid), .N2in_ready (N2in_ready),
        .N3in_data (N3in_data), .N3in_valid (N3in_valid), .N3in_ready (N3in_ready),
        .N4in_data (IN_A_data), .N4in_valid (IN_A_valid), .N4in_ready (IN_A_ready),
        .N9out_data (OUT_X_data),  .N9out_valid (OUT_X_valid),  .N9out_ready (OUT_X_ready),
        .N10out_data(N10out_data), .N10out_valid(N10out_valid), .N10out_ready(N10out_ready),
        .N11out_data(N11out_data), .N11out_valid(N11out_valid), .N11out_ready(N11out_ready),
        .N12out_data(OUT_A_data),  .N12out_valid(OUT_A_valid),  .N12out_ready(OUT_A_ready)
    );

    // تولید کلاک
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // تسک‌های کمکی
    task automatic wait_cycles(input int n);
        repeat (n) @(posedge clk);
    endtask

    task automatic start_inputs(input logic [15:0] x_val, input logic [15:0] a_val);
        begin
            while(!IN_X_ready || !IN_A_ready) begin
                @(posedge clk);
            end
            @(negedge clk);
            IN_X_data = x_val; IN_X_valid = 1'b1;
            IN_A_data = a_val; IN_A_valid = 1'b1;
            @(posedge clk);
            @(posedge clk);
            IN_X_valid = 1'b0;
            IN_A_valid = 1'b0;
        end
    endtask

    // متغیرهای سطح ماژول برای جلوگیری از لاگ تکراری
    logic last_x_valid = 1'b0;
    logic last_a_valid = 1'b0;

    // =================================================================
    // بلوک اصلی تست‌ها (اصلاح شده برای رفع خطاهای ModelSim)
    // =================================================================
    initial begin
        // 1. اعلان تمام متغیرهای محلی در بالاترین سطح (قبل از هر دستوری!)
        int timeout_cnt;
        logic x_checked;
        logic a_checked;
        int i;

        // 2. شروع دستورات اجرایی
        rst = 1'b1;
        IN_X_valid = 1'b0; IN_A_valid = 1'b0;
        OUT_X_ready = 1'b1; OUT_A_ready = 1'b1;
        N2in_valid = 1'b0; N3in_valid = 1'b0;
        N10out_ready = 1'b1; N11out_ready = 1'b1;

        wait_cycles(10);
        rst = 1'b0;
        wait_cycles(5);

        // استفاده از i که در بالا تعریف شد
        for (i = 0; i < NUM_TESTS; i++) begin
            timeout_cnt = 0;
            x_checked = 1'b0;
            a_checked = 1'b0;

            $display("--------------------------------------------------");
            $display("Starting TEST %0d | IN_X=%0d, IN_A=%0d", i+1, test_X_vals[i], test_A_vals[i]);

            start_inputs(test_X_vals[i], test_A_vals[i]);

            while (!(x_checked && a_checked)) begin
                @(posedge clk);
                #1;
                
                timeout_cnt++;
                if (timeout_cnt > 20000) begin
                    $error("[%0t] TEST %0d TIMEOUT! X_checked=%0d, A_checked=%0d", $time, i+1, x_checked, a_checked);
                    break;
                end

                // بررسی خروجی OUT.X
                if (OUT_X_valid && OUT_X_ready && !last_x_valid) begin
                    if (OUT_X_data === exp_X_vals[i]) begin
                        $display("[%0t] TEST %0d PASS (OUT.X) | IN_X=%0d | OUT_X=%0d", $time, i+1, IN_X_data, OUT_X_data);
                    end else begin
                        $error("[%0t] TEST %0d FAIL (OUT.X) | IN_X=%0d | OUT_X=%0d | EXP=%0d", $time, i+1, IN_X_data, OUT_X_data, exp_X_vals[i]);
                    end
                    x_checked = 1'b1;
                end
                
                // بررسی خروجی OUT.A
                if (OUT_A_valid && OUT_A_ready && !last_a_valid) begin
                    if (OUT_A_data === exp_A_vals[i]) begin
                        $display("[%0t] TEST %0d PASS (OUT.A) | IN_A=%0d | OUT_A=%0d", $time, i+1, IN_A_data, OUT_A_data);
                    end else begin
                        $error("[%0t] TEST %0d FAIL (OUT.A) | IN_A=%0d | OUT_A=%0d | EXP=%0d", $time, i+1, IN_A_data, OUT_A_data, exp_A_vals[i]);
                    end
                    a_checked = 1'b1;
                end
                
                last_x_valid <= OUT_X_valid;
                last_a_valid <= OUT_A_valid;
            end
        end

        $display("--------------------------------------------------");
        $display("All tests finished.");
        $stop;
    end

endmodule