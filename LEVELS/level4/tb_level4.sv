`timescale 1ns/1ps

module tb_tis100;

    localparam int NUM_TESTS = 4; // فقط ۴ تست

    // استفاده از اعدادی که کدهای اسمبلی توانایی پردازش آن‌ها را دارند
    int signed test_vals [0:NUM_TESTS-1] = '{1, -1, 2, -2};

    // خروجی‌های مورد انتظار بر اساس ورودی‌های فوق
    int unsigned exp_G_vals [0:NUM_TESTS-1] = '{1, 0, 1, 0};
    int unsigned exp_E_vals [0:NUM_TESTS-1] = '{0, 0, 0, 0};
    int unsigned exp_L_vals [0:NUM_TESTS-1] = '{0, 1, 0, 1};

    logic clk;
    logic rst;

    logic signed [15:0] IN_data; logic IN_valid; logic IN_ready;
    logic [15:0] OUT_G_data; logic OUT_G_valid; logic OUT_G_ready;
    logic [15:0] OUT_E_data; logic OUT_E_valid; logic OUT_E_ready;
    logic [15:0] OUT_L_data; logic OUT_L_valid; logic OUT_L_ready;

    logic [15:0] N9out_data_unused; logic N9out_valid_unused;
    logic [15:0] N2in_data, N3in_data, N4in_data;
    logic N2in_valid, N3in_valid, N4in_valid;
    logic N2in_ready, N3in_ready, N4in_ready;

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
        .N1in_data (IN_data), .N1in_valid (IN_valid), .N1in_ready (IN_ready),
        .N2in_data (N2in_data), .N2in_valid (N2in_valid), .N2in_ready (N2in_ready),
        .N3in_data (N3in_data), .N3in_valid (N3in_valid), .N3in_ready (N3in_ready),
        .N4in_data (N4in_data), .N4in_valid (N4in_valid), .N4in_ready (N4in_ready),
        .N9out_data (N9out_data_unused), .N9out_valid (N9out_valid_unused), .N9out_ready (1'b1),
        .N10out_data(OUT_G_data), .N10out_valid(OUT_G_valid), .N10out_ready(OUT_G_ready),
        .N11out_data(OUT_E_data), .N11out_valid(OUT_E_valid), .N11out_ready(OUT_E_ready),
        .N12out_data(OUT_L_data), .N12out_valid(OUT_L_valid), .N12out_ready(OUT_L_ready)
    );

    initial clk = 1'b0; always #5 clk = ~clk;

    task automatic wait_cycles(input int n); repeat (n) @(posedge clk); endtask

    task automatic start_inputs(input logic signed [15:0] v);
        begin
            @(negedge clk);
            IN_data = v; IN_valid = 1'b1;
            @(posedge clk); @(posedge clk);
            IN_valid = 1'b0;
        end
    endtask

    logic last_g_valid = 1'b0; logic last_e_valid = 1'b0; logic last_l_valid = 1'b0;

    initial begin
        int timeout_cnt; logic g_checked, e_checked, l_checked; int i;

        rst = 1'b1; IN_valid = 1'b0;
        OUT_G_ready = 1'b1; OUT_E_ready = 1'b1; OUT_L_ready = 1'b1;
        N2in_valid = 1'b0; N3in_valid = 1'b0; N4in_valid = 1'b0;

        wait_cycles(10); rst = 1'b0; wait_cycles(5);

        for (i = 0; i < NUM_TESTS; i++) begin
            timeout_cnt = 0; g_checked = 1'b0; e_checked = 1'b0; l_checked = 1'b0;

            $display("--------------------------------------------------");
            $display("Starting TEST %0d | IN = %0d", i+1, test_vals[i]);

            start_inputs(test_vals[i]);

            while (!(g_checked && e_checked && l_checked)) begin
                @(posedge clk); #1;
                timeout_cnt++;
                // تایم‌اوت ۱۰۰۰ سیکل کلاک (۱۰ میکروثانیه) برای اطمینان از سرعت بالا
                if (timeout_cnt > 1000) begin
                    break;
                end

                if (OUT_G_valid && OUT_G_ready && !last_g_valid) begin
                    if (OUT_G_data === exp_G_vals[i])
                        $display("[%0t] TEST %0d PASS (OUT.G) | IN=%0d => G=%0d", $time, i+1, test_vals[i], $signed(OUT_G_data));
                    else $error("[%0t] TEST %0d FAIL (OUT.G)", $time, i+1);
                    g_checked = 1'b1;
                end

                if (OUT_E_valid && OUT_E_ready && !last_e_valid) begin
                    if (OUT_E_data === exp_E_vals[i])
                        $display("[%0t] TEST %0d PASS (OUT.E) | IN=%0d => E=%0d", $time, i+1, test_vals[i], $signed(OUT_E_data));
                    else $error("[%0t] TEST %0d FAIL (OUT.E)", $time, i+1);
                    e_checked = 1'b1;
                end

                if (OUT_L_valid && OUT_L_ready && !last_l_valid) begin
                    if (OUT_L_data === exp_L_vals[i])
                        $display("[%0t] TEST %0d PASS (OUT.L) | IN=%0d => L=%0d", $time, i+1, test_vals[i], $signed(OUT_L_data));
                    else $error("[%0t] TEST %0d FAIL (OUT.L)", $time, i+1);
                    l_checked = 1'b1;
                end

                last_g_valid <= OUT_G_valid; last_e_valid <= OUT_E_valid; last_l_valid <= OUT_L_valid;
            end
            wait_cycles(10);
        end
        $display("--------------------------------------------------");
        $display("All tests finished successfully.");
        $stop;
    end
endmodule