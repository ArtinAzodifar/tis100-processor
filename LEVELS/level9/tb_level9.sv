`timescale 1ns/1ps

module tb_tis100;

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

    localparam int INPUT_COUNT = 5;
    localparam int TIMEOUT = 30000;

    logic clk;
    logic rst;

    logic [15:0] N1in_data;
    logic N1in_valid;
    logic N1in_ready;
    logic [15:0] N2in_data;
    logic N2in_valid;
    logic N2in_ready;
    logic [15:0] N3in_data;
    logic N3in_valid;
    logic N3in_ready;
    logic [15:0] N4in_data;
    logic N4in_valid;
    logic N4in_ready;

    logic [15:0] N9out_data;
    logic N9out_valid;
    logic N9out_ready;
    logic [15:0] N10out_data;
    logic N10out_valid;
    logic N10out_ready;
    logic [15:0] N11out_data;
    logic N11out_valid;
    logic N11out_ready;
    logic [15:0] N12out_data;
    logic N12out_valid;
    logic N12out_ready;

    logic [15:0] input1 [0:INPUT_COUNT-1];
    logic [15:0] input2 [0:INPUT_COUNT-1];
    logic [15:0] input3 [0:INPUT_COUNT-1];
    logic [15:0] input4 [0:INPUT_COUNT-1];
    logic [15:0] expected [0:INPUT_COUNT-1];

    integer output_index;
    integer errors;
    integer cycles;
    integer i;

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
        input1[0] = 16'd0;
        input1[1] = 16'd0;
        input1[2] = 16'd0;
        input1[3] = 16'd0;
        input1[4] = 16'd0;
        input2[0] = 16'd0;
        input2[1] = 16'd0;
        input2[2] = 16'd0;
        input2[3] = 16'd0;
        input2[4] = 16'd0;
        input3[0] = 16'd0;
        input3[1] = 16'd0;
        input3[2] = 16'd0;
        input3[3] = 16'd1;
        input3[4] = 16'd1;
        input4[0] = 16'd0;
        input4[1] = 16'd0;
        input4[2] = 16'd1;
        input4[3] = 16'd1;
        input4[4] = 16'd1;
        expected[0] = 16'd0;
        expected[1] = 16'd0;
        expected[2] = 16'd4;
        expected[3] = 16'd3;
        expected[4] = 16'd0;
    end

    initial begin
        rst = 1'b1;
        N1in_data = 16'd0;
        N2in_data = 16'd0;
        N3in_data = 16'd0;
        N4in_data = 16'd0;
        N1in_valid = 1'b0;
        N2in_valid = 1'b0;
        N3in_valid = 1'b0;
        N4in_valid = 1'b0;
        N9out_ready = 1'b1;
        N10out_ready = 1'b1;
        N11out_ready = 1'b1;
        N12out_ready = 1'b1;
        output_index = 0;
        errors = 0;
        cycles = 0;
        repeat (5) @(posedge clk);
        rst = 1'b0;
    end

    initial begin
        wait (!rst);
        for (i = 0; i < INPUT_COUNT; i = i + 1) begin
            @(negedge clk);
            N1in_data = input1[i];
            N2in_data = input2[i];
            N3in_data = input3[i];
            N4in_data = input4[i];
            N1in_valid = 1'b1;
            N2in_valid = 1'b1;
            N3in_valid = 1'b1;
            N4in_valid = 1'b1;

            while (N1in_valid || N2in_valid || N3in_valid || N4in_valid) begin
                @(posedge clk);

                if (N1in_valid && N1in_ready)
                    N1in_valid <= 1'b0;

                if (N2in_valid && N2in_ready)
                    N2in_valid <= 1'b0;

                if (N3in_valid && N3in_ready)
                    N3in_valid <= 1'b0;

                if (N4in_valid && N4in_ready)
                    N4in_valid <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if (!rst && N11out_valid && N11out_ready) begin
            $display("%0d : %0d", output_index, N11out_data);
            if (output_index >= INPUT_COUNT)
                errors = errors + 1;
            else if (N11out_data !== expected[output_index])
                errors = errors + 1;
            output_index = output_index + 1;
        end

        if (!rst && N9out_valid && N9out_ready)
            errors = errors + 1;

        if (!rst && N10out_valid && N10out_ready)
            errors = errors + 1;

        if (!rst && N12out_valid && N12out_ready)
            errors = errors + 1;
    end

    initial begin
        wait (!rst);
        while (output_index < INPUT_COUNT && cycles < TIMEOUT) begin
            @(posedge clk);
            cycles = cycles + 1;
        end

        repeat (20) @(posedge clk);

        if (output_index != INPUT_COUNT)
            errors = errors + 1;

        if (N1in_valid && N1in_ready)
        $display("N1 accepted %0d", N1in_data);

        if (N2in_valid && N2in_ready)
            $display("N2 accepted %0d", N2in_data);

        if (N3in_valid && N3in_ready)
            $display("N3 accepted %0d", N3in_data);

        if (N4in_valid && N4in_ready)
            $display("N4 accepted %0d", N4in_data);

        if (errors == 0)
            $display("PASS");
        else
            $display("FAIL");

        $stop;
    end

endmodule
