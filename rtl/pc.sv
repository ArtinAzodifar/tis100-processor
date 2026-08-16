module pc (
    input  logic       clk,
    input  logic       rst,
    input  logic       PCWrite,
    input  logic [15:0] pc_next,
    output logic [15:0] pc
);

    always_ff @(posedge clk) begin
        if (rst)
            pc <= 0;
        else if (PCWrite) begin
            if (pc_next == 16)
                pc <= 0;
            else
                pc <= pc_next;
        end
    end

endmodule