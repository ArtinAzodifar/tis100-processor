module datapath  #(
    parameter string PROG_FILE = "program.txt"
)(
    input  logic        clk,
    input  logic        rst,

    input  logic        PCWrite,
    input  logic        IRWrite,
    input  logic        OldPCWrite,
    input  logic        A_write,
    input  logic        dataUnit_write,
    input  logic        dataUnit_sav,
    input  logic        dataUnit_swp,
    input  logic        ResultSrc,
    input  logic [1:0]  ALUSrcA,
    input  logic [1:0]  ALUSrcB,
    input  logic [2:0]  ALUControl,
    input  logic        aluout_enable,
    input  logic        readEnable,


    output logic [3:0]  opcode,
    output logic        flag,
    output logic        src_ready,
    output logic        dst_ready,
    output logic        ACC_Zero,
    output logic        ACC_Negative,

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

    logic [15:0] pc_next, pc_current, old_pc;
    logic [19:0] instr, instr_reg;
    logic [3:0]  src, dst;
    logic [15:0] imm_ext;
    
    logic [15:0] dataUnit_out, acc_out, reg_a_out;
    logic [15:0] alu_src_a_val, alu_src_b_val, alu_result, alu_out;
    logic        alu_zero;


    assign opcode = instr_reg[3:0];
    assign flag   = instr_reg[8];
    assign src    = instr_reg[12:9];
    assign dst    = instr_reg[7:4];
    
    assign imm_ext = {{5{instr_reg[19]}}, instr_reg[19:9]};


    pc pc_inst (
        .clk(clk), .rst(rst),
        .PCWrite(PCWrite), .pc_next(pc_next), .pc(pc_current)
    );

    oldPC oldPC_inst (
        .clk(clk), .rst(rst),
        .OldPCWrite(OldPCWrite), .pc_in(pc_current), .old_pc_out(old_pc)
    );

    imem #(
        .PROG_FILE(PROG_FILE)
    ) imem_inst (
        .addr(pc_current), .instr(instr)
    );

    ir ir_inst (
        .clk(clk), .rst(rst),
        .IRWrite(IRWrite), .instr_in(instr), .instr_out(instr_reg)
    );


    dataUnit dataUnit_inst (
        .clk(clk), .rst(rst),
        .src(src), .dst(dst), .flag(flag),
        .dataUnit_write(dataUnit_write), .write_data(alu_out),
        .dataUnit_sav(dataUnit_sav), .dataUnit_swp(dataUnit_swp),
        .readEnable(readEnable),
        
        .DATA_OUT(dataUnit_out), .ACC_OUT(acc_out),
        .src_ready(src_ready), .dst_ready(dst_ready),
        .ACC_Zero(ACC_Zero), .ACC_Negative(ACC_Negative),
        
        .up_data_in(up_data_in), .up_valid_in(up_valid_in), .up_ready_out(up_ready_out),
        .dn_data_in(dn_data_in), .dn_valid_in(dn_valid_in), .dn_ready_out(dn_ready_out),
        .lf_data_in(lf_data_in), .lf_valid_in(lf_valid_in), .lf_ready_out(lf_ready_out),
        .rt_data_in(rt_data_in), .rt_valid_in(rt_valid_in), .rt_ready_out(rt_ready_out),
        
        .up_data_out(up_data_out), .up_valid_out(up_valid_out), .up_ready_in(up_ready_in),
        .dn_data_out(dn_data_out), .dn_valid_out(dn_valid_out), .dn_ready_in(dn_ready_in),
        .lf_data_out(lf_data_out), .lf_valid_out(lf_valid_out), .lf_ready_in(lf_ready_in),
        .rt_data_out(rt_data_out), .rt_valid_out(rt_valid_out), .rt_ready_in(rt_ready_in)
    );

    reg_a reg_a_inst (
        .clk(clk), .rst(rst),
        .A_write(A_write), .data_in(dataUnit_out), .data_out(reg_a_out)
    );

    always_comb begin
        // ALUSrcA: 00:PC, 01:ACC, 10:OldPC, 11:0
        case (ALUSrcA)
            2'b00: alu_src_a_val = pc_current;
            2'b01: alu_src_a_val = acc_out;
            2'b10: alu_src_a_val = old_pc;
            2'b11: alu_src_a_val = 16'b0;
        endcase

        // ALUSrcB: 00:RegA, 01:ExtImm, 10:1, 11:ACC
        case (ALUSrcB)
            2'b00: alu_src_b_val = reg_a_out;
            2'b01: alu_src_b_val = imm_ext;
            2'b10: alu_src_b_val = 16'b1;
            2'b11: alu_src_b_val = acc_out;
        endcase
    end

    alu alu_inst (
        .src1(alu_src_a_val), .src2(alu_src_b_val),
        .opCode(ALUControl),
        .result(alu_result), .zero(alu_zero)
    );

    aluOut aluOut_inst (
        .clk(clk), .rst(rst), .enable(aluout_enable),
        .data_in(alu_result), .data_out(alu_out)
    );

    mux2 #(16) mux_result (
        .d0(alu_out), .d1(alu_result), .s(ResultSrc), .y(pc_next)
    );

endmodule