module alu (
    input logic [15:0] src1, src2,
    input logic [2:0] opCode,
    output logic [15:0] result,
    output logic zero
);

    assign zero = (result == 0);
    always_comb
        case (opCode)
            3'b000: result = src1 + src2;
            3'b001: result = src1 - src2;
            3'b101: result = (src1 < src2)?1:0;
            3'b011: result = src1 | src2;
            3'b010: result = src1 & src2;
            default: result = 16'bx;
        endcase
    
endmodule