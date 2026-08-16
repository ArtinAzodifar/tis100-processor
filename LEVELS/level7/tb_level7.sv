`timescale 1ns/1ps

module tb_tis100;

    logic clk;
    logic rst;

    logic [15:0] N1in_data;
    logic        N1in_valid;
    logic        N1in_ready;

    logic [15:0] N2in_data;
    logic        N2in_valid;
    logic        N2in_ready;

    logic [15:0] N3in_data;
    logic        N3in_valid;
    logic        N3in_ready;

    logic [15:0] N4in_data;
    logic        N4in_valid;
    logic        N4in_ready;

    logic [15:0] N9out_data;
    logic        N9out_valid;
    logic        N9out_ready;

    logic [15:0] N10out_data;
    logic        N10out_valid;
    logic        N10out_ready;

    logic [15:0] N11out_data;
    logic        N11out_valid;
    logic        N11out_ready;

    logic [15:0] N12out_data;
    logic        N12out_valid;
    logic        N12out_ready;

    localparam int INPUT_COUNT  = 39;
    localparam int OUTPUT_COUNT = 11;
    localparam int TIMEOUT      = 20000;

    logic [15:0] input_values [0:INPUT_COUNT-1];
    logic [15:0] expected_sum [0:OUTPUT_COUNT-1];
    logic [15:0] expected_len [0:OUTPUT_COUNT-1];

    integer sum_index;
    integer len_index;
    integer errors;
    integer cycles;
    integer i;

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
        .clk(clk),
        .rst(rst),

        .N1in_data(N1in_data),
        .N1in_valid(N1in_valid),
        .N1in_ready(N1in_ready),

        .N2in_data(N2in_data),
        .N2in_valid(N2in_valid),
        .N2in_ready(N2in_ready),

        .N3in_data(N3in_data),
        .N3in_valid(N3in_valid),
        .N3in_ready(N3in_ready),

        .N4in_data(N4in_data),
        .N4in_valid(N4in_valid),
        .N4in_ready(N4in_ready),

        .N9out_data(N9out_data),
        .N9out_valid(N9out_valid),
        .N9out_ready(N9out_ready),

        .N10out_data(N10out_data),
        .N10out_valid(N10out_valid),
        .N10out_ready(N10out_ready),

        .N11out_data(N11out_data),
        .N11out_valid(N11out_valid),
        .N11out_ready(N11out_ready),

        .N12out_data(N12out_data),
        .N12out_valid(N12out_valid),
        .N12out_ready(N12out_ready)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        input_values[0]  = 16'd35;
        input_values[1]  = 16'd0;
        input_values[2]  = 16'd62;
        input_values[3]  = 16'd51;
        input_values[4]  = 16'd81;
        input_values[5]  = 16'd54;
        input_values[6]  = 16'd12;
        input_values[7]  = 16'd0;
        input_values[8]  = 16'd51;
        input_values[9]  = 16'd63;
        input_values[10] = 16'd50;
        input_values[11] = 16'd67;
        input_values[12] = 16'd48;
        input_values[13] = 16'd0;
        input_values[14] = 16'd49;
        input_values[15] = 16'd23;
        input_values[16] = 16'd26;
        input_values[17] = 16'd0;
        input_values[18] = 16'd33;
        input_values[19] = 16'd79;
        input_values[20] = 16'd70;
        input_values[21] = 16'd0;
        input_values[22] = 16'd0;
        input_values[23] = 16'd94;
        input_values[24] = 16'd0;
        input_values[25] = 16'd79;
        input_values[26] = 16'd0;
        input_values[27] = 16'd98;
        input_values[28] = 16'd15;
        input_values[29] = 16'd0;
        input_values[30] = 16'd53;
        input_values[31] = 16'd35;
        input_values[32] = 16'd45;
        input_values[33] = 16'd12;
        input_values[34] = 16'd79;
        input_values[35] = 16'd0;
        input_values[36] = 16'd19;
        input_values[37] = 16'd71;
        input_values[38] = 16'd0;

        expected_sum[0]  = 16'd35;
        expected_sum[1]  = 16'd260;
        expected_sum[2]  = 16'd279;
        expected_sum[3]  = 16'd98;
        expected_sum[4]  = 16'd182;
        expected_sum[5]  = 16'd0;
        expected_sum[6]  = 16'd94;
        expected_sum[7]  = 16'd79;
        expected_sum[8]  = 16'd113;
        expected_sum[9]  = 16'd224;
        expected_sum[10] = 16'd90;

        expected_len[0]  = 16'd1;
        expected_len[1]  = 16'd5;
        expected_len[2]  = 16'd5;
        expected_len[3]  = 16'd3;
        expected_len[4]  = 16'd3;
        expected_len[5]  = 16'd0;
        expected_len[6]  = 16'd1;
        expected_len[7]  = 16'd1;
        expected_len[8]  = 16'd2;
        expected_len[9]  = 16'd5;
        expected_len[10] = 16'd2;
    end

    initial begin
        rst = 1'b1;

        N1in_data  = 16'd0;
        N1in_valid = 1'b0;
        N2in_data  = 16'd0;
        N2in_valid = 1'b0;
        N3in_data  = 16'd0;
        N3in_valid = 1'b0;
        N4in_data  = 16'd0;
        N4in_valid = 1'b0;

        N9out_ready  = 1'b1;
        N10out_ready = 1'b1;
        N11out_ready = 1'b1;
        N12out_ready = 1'b1;

        sum_index = 0;
        len_index = 0;
        errors    = 0;
        cycles    = 0;

        repeat (5) @(posedge clk);
        rst = 1'b0;
    end

    // The image's IN stream enters the top of N2, not N1.
    initial begin
        wait (rst == 1'b0);

        for (i = 0; i < INPUT_COUNT; i = i + 1) begin
            @(negedge clk);
            N2in_data  = input_values[i];
            N2in_valid = 1'b1;

            do @(posedge clk);
            while (!N2in_ready);

            @(negedge clk);
            N2in_valid = 1'b0;
        end
    end

    // OUT.S is below N10.
    always @(posedge clk) begin
        if (!rst && N10out_valid && N10out_ready) begin
            if (sum_index >= OUTPUT_COUNT)
                errors = errors + 1;
            else if (N10out_data !== expected_sum[sum_index])
                errors = errors + 1;

            sum_index = sum_index + 1;
        end
    end

    // OUT.L is below N11.
    always @(posedge clk) begin
        if (!rst && N11out_valid && N11out_ready) begin
            if (len_index >= OUTPUT_COUNT)
                errors = errors + 1;
            else if (N11out_data !== expected_len[len_index])
                errors = errors + 1;

            len_index = len_index + 1;
        end
    end

    // No output is expected below N9 or N12.
    always @(posedge clk) begin
        if (!rst) begin
            if (N9out_valid  && N9out_ready)  errors = errors + 1;
            if (N12out_valid && N12out_ready) errors = errors + 1;
        end
    end

    initial begin
        wait (rst == 1'b0);

        while ((sum_index < OUTPUT_COUNT || len_index < OUTPUT_COUNT) &&
               cycles < TIMEOUT) begin
            @(posedge clk);
            cycles = cycles + 1;
        end

        // Keep checking briefly for unexpected extra outputs.
        repeat (20) @(posedge clk);

        if (sum_index != OUTPUT_COUNT)
            errors = errors + 1;

        if (len_index != OUTPUT_COUNT)
            errors = errors + 1;

        if (errors == 0)
            $display("PASS");
        else
            $display("FAIL");

        $stop;
    end

endmodule
