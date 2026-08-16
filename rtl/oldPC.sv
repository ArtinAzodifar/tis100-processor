module oldPC (
    input  logic       clk,
    input  logic       rst,
    input  logic       OldPCWrite,
    input  logic [15:0] pc_in,
    output logic [15:0] old_pc_out
);

    always_ff @(posedge clk) begin
        if (rst)
            old_pc_out <= 16'b0;
        else if (OldPCWrite)
            old_pc_out <= pc_in;
    end

endmodule