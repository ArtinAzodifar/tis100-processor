module imem #(
    parameter string PROG_FILE = "program.txt"
) (
    input  logic [15:0] addr,
    output logic [19:0] instr
);

    logic [19:0] RAM [0:15];

    assign instr = RAM[addr[3:0]];

    initial begin
        integer i;
        for (i = 0; i < 16; i = i + 1) begin
            RAM[i] = 20'b0; 
        end
        //$readmemb(PROG_FILE, RAM);
    end
endmodule