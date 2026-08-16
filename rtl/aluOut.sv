module aluOut (
    input  logic        clk,
    input  logic        rst,
    input  logic        enable,
    input  logic [15:0] data_in,
    output logic [15:0] data_out
);

    always_ff @(posedge clk) begin
        if (rst)
            data_out <= 16'b0;
        else if(enable)
            data_out <= data_in;
    end

endmodule