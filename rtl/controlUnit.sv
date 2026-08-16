module controlUnit (
    input  logic        clk,
    input  logic        rst,

    input  logic [3:0]  opcode,
    input  logic        flag,         // 1: Immediate, 0: Reg/Port
    input  logic        src_ready,
    input  logic        dst_ready,
    input  logic        ACC_Zero,
    input  logic        ACC_Negative,

    output logic        PCWrite,
    output logic        IRWrite,
    output logic        OldPCWrite,
    output logic        A_write,
    output logic        dataUnit_write,
    output logic        dataUnit_sav,
    output logic        dataUnit_swp,
    output logic        ResultSrc,      // 0: ALUOut, 1: ALUResult
    output logic [1:0]  ALUSrcA,        // 00:PC, 01:ACC, 10:OldPC, 11:0
    output logic [1:0]  ALUSrcB,        // 00:RegA, 01:ExtImm, 10:1, 11:ACC
    output logic [2:0]  ALUControl,
    output logic ALUOutEnable,
    output logic readEnable
);

    localparam [3:0] OP_MOV = 4'b0001,
                     OP_ADD = 4'b0010,
                     OP_SUB = 4'b0011,
                     OP_NEG = 4'b0100,
                     OP_SAV = 4'b0101,
                     OP_SWP = 4'b0110,
                     OP_JMP = 4'b0111,
                     OP_JEZ = 4'b1000,
                     OP_JNZ = 4'b1001,
                     OP_JGZ = 4'b1010,
                     OP_JLZ = 4'b1011,
                     OP_JRO = 4'b1100;

    typedef enum logic [2:0] {
        FETCH      = 3'b000,
        DECODE     = 3'b001,
        READ_WAIT  = 3'b010,
        EXECUTE    = 3'b011,
        WRITE_WAIT = 3'b100,
        JMP_WB     = 3'b101,
        BRANCH_WB  = 3'b110,
        INTERNAL   = 3'b111
    } states;

    states current_state, next_state;


    // branch taken condition based on opcode
    logic branch_cond;
    always_comb begin
        case (opcode)
            OP_JEZ:  branch_cond =  ACC_Zero;
            OP_JNZ:  branch_cond = !ACC_Zero;
            OP_JLZ:  branch_cond =  ACC_Negative;
            OP_JGZ:  branch_cond = (!ACC_Negative && !ACC_Zero);
            default: branch_cond = 1'b0;
        endcase
    end


    always_ff @(posedge clk) begin
        if (rst)
            current_state <= FETCH;
        else
            current_state <= next_state;
    end

    // next_state logic
    always_comb begin
        next_state = FETCH;

        case (current_state)
            FETCH: begin
                next_state = DECODE;
            end

            DECODE: begin
                case (opcode)
                    OP_SAV, OP_SWP: next_state = INTERNAL;
                    OP_JMP:         next_state = JMP_WB;
                    OP_JEZ, OP_JNZ, 
                    OP_JLZ, OP_JGZ: next_state = BRANCH_WB;
                    OP_NEG:         next_state = EXECUTE;
                    default: begin // MOV, ADD, SUB, JRO
                        if (flag)   next_state = EXECUTE;
                        else        next_state = READ_WAIT;
                    end
                endcase
            end

            READ_WAIT: begin
                if (!src_ready) next_state = READ_WAIT; // Blocking Stall
                else            next_state = EXECUTE;
            end

            EXECUTE: begin
                if (opcode == OP_JRO) next_state = JMP_WB;
                else                  next_state = WRITE_WAIT;
            end

            WRITE_WAIT: begin
                if (!dst_ready) next_state = WRITE_WAIT; // Blocking Stall
                else            next_state = FETCH;
            end

            JMP_WB, BRANCH_WB, INTERNAL: begin
                next_state = FETCH;
            end

            default: next_state = FETCH;
        endcase
    end

    // output logic
    always_comb begin
        PCWrite        = 1'b0;
        IRWrite        = 1'b0;
        OldPCWrite     = 1'b0;
        A_write        = 1'b0;
        dataUnit_write = 1'b0;
        dataUnit_sav   = 1'b0;
        dataUnit_swp   = 1'b0;
        ResultSrc      = 1'b0; // 0: ALUOut
        ALUSrcA        = 2'b00;
        ALUSrcB        = 2'b00;
        ALUControl     = 3'b000; // 000: ADD, 001: SUB
        ALUOutEnable   = 1'b0;
        readEnable     = 1'b0;

        case (current_state)
            
            FETCH: begin
                IRWrite    = 1'b1;
                OldPCWrite = 1'b1;
                PCWrite    = 1'b1;
                ResultSrc  = 1'b1; // PC+1
                ALUSrcA    = 2'b00; // PC
                ALUSrcB    = 2'b10; // 1
                ALUControl = 3'b000; // ADD
                ALUOutEnable   = 1'b1;
            end


            DECODE: begin
                if (opcode == OP_JMP || opcode == OP_JEZ || 
                    opcode == OP_JNZ || opcode == OP_JLZ || opcode == OP_JGZ) begin
                    // ALUOut = OldPC + ImmExt
                    ALUSrcA    = 2'b10; // OldPC
                    ALUSrcB    = 2'b01; // ExtImm
                    ALUControl = 3'b000; // ADD
                    ALUOutEnable   = 1'b1;
                end
            end

            READ_WAIT: begin
                readEnable = 1'b1;
                if (src_ready) begin
                    A_write = 1'b1;
                end
            end

            EXECUTE: begin
                case (opcode)
                    OP_MOV: begin
                        ALUSrcA    = 2'b11; // 0
                        ALUSrcB    = flag ? 2'b01 : 2'b00; // ExtImm or RegA
                        ALUControl = 3'b000; // ADD (0 + src)
                        ALUOutEnable   = 1'b1;
                    end
                    OP_ADD: begin
                        ALUSrcA    = 2'b01; // ACC
                        ALUSrcB    = flag ? 2'b01 : 2'b00; // ExtImm or RegA
                        ALUControl = 3'b000; // ADD
                        ALUOutEnable   = 1'b1;
                    end
                    OP_SUB: begin
                        ALUSrcA    = 2'b01; // ACC
                        ALUSrcB    = flag ? 2'b01 : 2'b00; // ExtImm or RegA
                        ALUControl = 3'b001; // SUB
                        ALUOutEnable   = 1'b1;
                    end
                    OP_NEG: begin
                        ALUSrcA    = 2'b11; // 0
                        ALUSrcB    = 2'b11; // ACC
                        ALUControl = 3'b001; // SUB (0 - ACC = -ACC)
                        ALUOutEnable   = 1'b1;
                    end
                    OP_JRO: begin
                        ALUSrcA    = 2'b10; // OldPC
                        ALUSrcB    = flag ? 2'b01 : 2'b00;
                        ALUControl = 3'b000; // ADD (OldPC + RegA)
                        ALUOutEnable   = 1'b1;
                    end
                    default: ;
                endcase
            end

            WRITE_WAIT: begin
                ResultSrc = 1'b0; // ALUOut
                dataUnit_write = 1'b1;
            end

            JMP_WB: begin
                ResultSrc = 1'b0; // ALUOut = OldPC + ImmExt
                PCWrite   = 1'b1;
            end


            BRANCH_WB: begin
                ResultSrc = 1'b0; // ALUOut OldPC + ImmExt
                PCWrite   = branch_cond;
            end

            // Internal for SWP , SAV
            INTERNAL: begin
                if (opcode == OP_SAV)      dataUnit_sav = 1'b1;
                else if (opcode == OP_SWP) dataUnit_swp = 1'b1;
            end

            default: ;
        endcase
    end

endmodule