module ir (
    input  logic        clk,
    input  logic        rst,
    input  logic        IRWrite,
    input  logic [19:0] instr_in,
    output logic [19:0] instr_out
);

    always_ff @(posedge clk) begin
        if (rst)
            instr_out <= 20'b0;
        else if (IRWrite)
            instr_out <= instr_in;
    end

endmodule