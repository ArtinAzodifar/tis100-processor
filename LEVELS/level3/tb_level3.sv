`timescale 1ns/1ps

module tb_tis100;

    localparam int NUM_TESTS = 5;

    // آرایه‌های تست (ورودی‌ها و خروجی‌های مورد انتظار)
    int unsigned test_A_vals [0:NUM_TESTS-1] = '{50,  50,   14,  20, 37};
    int unsigned test_B_vals [0:NUM_TESTS-1] = '{ 33, 99,   94,  11,  67};
    // فرمول منطقی: P = A - B, N = B - A
    int signed   exp_P_vals  [0:NUM_TESTS-1] = '{ 17, -49,  -80, 9,  -30};
    int signed   exp_N_vals  [0:NUM_TESTS-1] = '{-17,  49,  80,  -9, 30};

    // سیگنال‌های سطح بالا
    logic clk;
    logic rst;

    // ---------- ورودی IN.A (متصل به گره N2) ----------
    logic [15:0] IN_A_data; logic IN_A_valid; logic IN_A_ready;

    // ---------- ورودی IN.B (متصل به گره N3) ----------
    logic [15:0] IN_B_data; logic IN_B_valid; logic IN_B_ready;

    // ---------- خروجی OUT.P (متصل به گره N10) ----------
    logic [15:0] OUT_P_data; logic OUT_P_valid; logic OUT_P_ready;

    // ---------- خروجی OUT.N (متصل به گره N11) ----------
    logic [15:0] OUT_N_data; logic OUT_N_valid; logic OUT_N_ready;

    // سایر پورت‌های غیرفعال (گره‌های خالی)
    logic [15:0] N1in_data, N4in_data;
    logic        N1in_valid, N4in_valid;
    logic        N1in_ready, N4in_ready;
    logic [15:0] N9out_data, N12out_data;
    logic        N9out_valid, N12out_valid;
    logic        N9out_ready, N12out_ready;

    // تعریف برنامه‌های گره‌ها
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

    // وهله‌سازی ماژول top_tis100
    top_tis100 #(
        .PROG_N1 (PROG_N1), .PROG_N2 (PROG_N2), .PROG_N3 (PROG_N3), .PROG_N4 (PROG_N4),
        .PROG_N5 (PROG_N5), .PROG_N6 (PROG_N6), .PROG_N7 (PROG_N7), .PROG_N8 (PROG_N8),
        .PROG_N9 (PROG_N9), .PROG_N10(PROG_N10), .PROG_N11(PROG_N11), .PROG_N12(PROG_N12)
    ) dut (
        .clk(clk), .rst(rst),
        .N1in_data (N1in_data), .N1in_valid (N1in_valid), .N1in_ready (N1in_ready),
        .N2in_data (IN_A_data), .N2in_valid (IN_A_valid), .N2in_ready (IN_A_ready),
        .N3in_data (IN_B_data), .N3in_valid (IN_B_valid), .N3in_ready (IN_B_ready),
        .N4in_data (N4in_data), .N4in_valid (N4in_valid), .N4in_ready (N4in_ready),
        .N9out_data (N9out_data), .N9out_valid (N9out_valid), .N9out_ready (N9out_ready),
        .N10out_data(OUT_P_data),.N10out_valid(OUT_P_valid),.N10out_ready(OUT_P_ready),
        .N11out_data(OUT_N_data),.N11out_valid(OUT_N_valid),.N11out_ready(OUT_N_ready),
        .N12out_data(N12out_data),.N12out_valid(N12out_valid),.N12out_ready(N12out_ready)
    );

    // تولید کلاک
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // تسک‌های کمکی
    task automatic wait_cycles(input int n);
        repeat (n) @(posedge clk);
    endtask

    // تسک ارسال همزمان ورودی‌های A و B
    task automatic start_inputs(input logic [15:0] a_val, input logic [15:0] b_val);
        begin
            while(!IN_A_ready || !IN_B_ready) begin
                @(posedge clk);
            end
            @(negedge clk);
            IN_A_data = a_val; IN_A_valid = 1'b1;
            IN_B_data = b_val; IN_B_valid = 1'b1;
            @(posedge clk);
            @(posedge clk);
            IN_A_valid = 1'b0;
            IN_B_valid = 1'b0;
        end
    endtask

    // متغیرهای جلوگیری از لاگ تکراری
    logic last_p_valid = 1'b0;
    logic last_n_valid = 1'b0;

    // بلوک اصلی تست
    initial begin
        // تعاریف متغیرها در ابتدای بلوک برای جلوگیری از خطای کامپایل ModelSim
        int timeout_cnt;
        logic p_checked;
        logic n_checked;
        int i;

        // مقداردهی اولیه
        rst = 1'b1;
        IN_A_valid = 1'b0; IN_B_valid = 1'b0;
        OUT_P_ready = 1'b1; OUT_N_ready = 1'b1;
        N1in_valid = 1'b0; N4in_valid = 1'b0;
        N9out_ready = 1'b1; N12out_ready = 1'b1;

        wait_cycles(10);
        rst = 1'b0;
        wait_cycles(5);

        for (i = 0; i < NUM_TESTS; i++) begin
            timeout_cnt = 0;
            p_checked = 1'b0;
            n_checked = 1'b0;

            $display("--------------------------------------------------");
            $display("Starting TEST %0d | IN_A=%0d, IN_B=%0d", i+1, test_A_vals[i], test_B_vals[i]);

            start_inputs(test_A_vals[i], test_B_vals[i]);

            while (!(p_checked && n_checked)) begin
                @(posedge clk);
                #1;
                
                timeout_cnt++;
                if (timeout_cnt > 20000) begin
                    $error("[%0t] TEST %0d TIMEOUT! P_checked=%0d, N_checked=%0d", $time, i+1, p_checked, n_checked);
                    break;
                end

                // بررسی خروجی OUT.P
                if (OUT_P_valid && OUT_P_ready && !last_p_valid) begin
                    // نکته: مقادیر P و N را به صورت signed چاپ می‌کنیم
                    if ($signed(OUT_P_data) === exp_P_vals[i]) begin
                        $display("[%0t] TEST %0d PASS (OUT.P) | A=%0d, B=%0d => P=%0d", $time, i+1, test_A_vals[i], test_B_vals[i], $signed(OUT_P_data));
                    end else begin
                        $error("[%0t] TEST %0d FAIL (OUT.P) | A=%0d, B=%0d | OUT.P=%0d | EXP.P=%0d", $time, i+1, test_A_vals[i], test_B_vals[i], $signed(OUT_P_data), exp_P_vals[i]);
                    end
                    p_checked = 1'b1;
                end
                
                // بررسی خروجی OUT.N
                if (OUT_N_valid && OUT_N_ready && !last_n_valid) begin
                    if ($signed(OUT_N_data) === exp_N_vals[i]) begin
                        $display("[%0t] TEST %0d PASS (OUT.N) | A=%0d, B=%0d => N=%0d", $time, i+1, test_A_vals[i], test_B_vals[i], $signed(OUT_N_data));
                    end else begin
                        $error("[%0t] TEST %0d FAIL (OUT.N) | A=%0d, B=%0d | OUT.N=%0d | EXP.N=%0d", $time, i+1, test_A_vals[i], test_B_vals[i], $signed(OUT_N_data), exp_N_vals[i]);
                    end
                    n_checked = 1'b1;
                end
                
                last_p_valid <= OUT_P_valid;
                last_n_valid <= OUT_N_valid;
            end
        end

        $display("--------------------------------------------------");
        $display("All tests finished.");
        $stop;
    end

endmodule