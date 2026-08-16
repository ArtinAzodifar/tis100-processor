`timescale 1ns/1ps
module tb_top_t21;
    logic clk = 0, rst = 1;
    top_t21 top (.*);

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top_t21);
        #20 rst = 0;
        #20000;
        // A
        if (top.A_inst.dp.dataUnit_inst.ACC !== 16'h0099) $error("A ACC wrong: %h", top.A_inst.dp.dataUnit_inst.ACC);
        if (top.A_inst.dp.dataUnit_inst.BAK !== 16'h000A) $error("A BAK wrong: %h", top.A_inst.dp.dataUnit_inst.BAK);
        // B
        if (top.B_inst.dp.dataUnit_inst.ACC !== 16'h0005) $error("B ACC wrong: %h", top.B_inst.dp.dataUnit_inst.ACC);
        if (top.B_inst.dp.dataUnit_inst.BAK !== 16'h0005) $error("B BAK wrong: %h", top.B_inst.dp.dataUnit_inst.BAK);
        // C
        if (top.C_inst.dp.dataUnit_inst.ACC !== 16'h0003) $error("C ACC wrong: %h", top.C_inst.dp.dataUnit_inst.ACC);
        if (top.C_inst.dp.dataUnit_inst.BAK !== 16'h0003) $error("C BAK wrong: %h", top.C_inst.dp.dataUnit_inst.BAK);

        $display("All checks passed!");
        $stop;
    end
endmodule