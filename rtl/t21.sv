module t21 #(
    parameter string PROG_FILE = "program.txt"
)(
    input  logic        clk,
    input  logic        rst,

    // ports
    input  logic [15:0] up_data_in,   input logic up_valid_in,   output logic up_ready_out,
    input  logic [15:0] dn_data_in,   input logic dn_valid_in,   output logic dn_ready_out,
    input  logic [15:0] lf_data_in,   input logic lf_valid_in,   output logic lf_ready_out,
    input  logic [15:0] rt_data_in,   input logic rt_valid_in,   output logic rt_ready_out,

    output logic [15:0] up_data_out,  output logic up_valid_out, input logic up_ready_in,
    output logic [15:0] dn_data_out,  output logic dn_valid_out, input logic dn_ready_in,
    output logic [15:0] lf_data_out,  output logic lf_valid_out, input logic lf_ready_in,
    output logic [15:0] rt_data_out,  output logic rt_valid_out, input logic rt_ready_in
);

    
    logic        PCWrite, IRWrite, OldPCWrite, A_write;
    logic        dataUnit_write, dataUnit_sav, dataUnit_swp;
    logic        ResultSrc;
    logic [1:0]  ALUSrcA, ALUSrcB;
    logic [2:0]  ALUControl;
    logic        aluout_enable;
    logic        readEnable;
    
    logic [3:0]  opcode;
    logic        flag, src_ready, dst_ready, ACC_Zero, ACC_Negative;


    controlUnit cu (
        .clk(clk),
        .rst(rst),
        
        .opcode(opcode),
        .flag(flag),
        .src_ready(src_ready),
        .dst_ready(dst_ready),
        .ACC_Zero(ACC_Zero),
        .ACC_Negative(ACC_Negative),
        
        .PCWrite(PCWrite),
        .IRWrite(IRWrite),
        .OldPCWrite(OldPCWrite),
        .A_write(A_write),
        .dataUnit_write(dataUnit_write),
        .dataUnit_sav(dataUnit_sav),
        .dataUnit_swp(dataUnit_swp),
        .ResultSrc(ResultSrc),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .ALUControl(ALUControl),
        .ALUOutEnable(aluout_enable),
        .readEnable(readEnable)
    );

    datapath #(
        .PROG_FILE(PROG_FILE)
        ) dp (
        .clk(clk),
        .rst(rst),
        
        .PCWrite(PCWrite),
        .IRWrite(IRWrite),
        .OldPCWrite(OldPCWrite),
        .A_write(A_write),
        .dataUnit_write(dataUnit_write),
        .dataUnit_sav(dataUnit_sav),
        .dataUnit_swp(dataUnit_swp),
        .ResultSrc(ResultSrc),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .ALUControl(ALUControl),
        .aluout_enable(aluout_enable),
        .readEnable(readEnable),
        
        .opcode(opcode),
        .flag(flag),
        .src_ready(src_ready),
        .dst_ready(dst_ready),
        .ACC_Zero(ACC_Zero),
        .ACC_Negative(ACC_Negative),
        
        .up_data_in(up_data_in), .up_valid_in(up_valid_in), .up_ready_out(up_ready_out),
        .dn_data_in(dn_data_in), .dn_valid_in(dn_valid_in), .dn_ready_out(dn_ready_out),
        .lf_data_in(lf_data_in), .lf_valid_in(lf_valid_in), .lf_ready_out(lf_ready_out),
        .rt_data_in(rt_data_in), .rt_valid_in(rt_valid_in), .rt_ready_out(rt_ready_out),
        
        .up_data_out(up_data_out), .up_valid_out(up_valid_out), .up_ready_in(up_ready_in),
        .dn_data_out(dn_data_out), .dn_valid_out(dn_valid_out), .dn_ready_in(dn_ready_in),
        .lf_data_out(lf_data_out), .lf_valid_out(lf_valid_out), .lf_ready_in(lf_ready_in),
        .rt_data_out(rt_data_out), .rt_valid_out(rt_valid_out), .rt_ready_in(rt_ready_in)
    );

endmodule