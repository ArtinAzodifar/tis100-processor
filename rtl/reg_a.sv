module reg_a (
    input  logic        clk,
    input  logic        rst,
    input  logic        A_write,
    input  logic [15:0] data_in,
    output logic [15:0] data_out
);

    always_ff @(posedge clk) begin
        if (rst)
            data_out <= 16'b0;
        else if (A_write)
            data_out <= data_in;
    end

endmodule