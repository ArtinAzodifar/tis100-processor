module dataUnit (
    input  logic        clk,
    input  logic        rst,

    input  logic [3:0]  src,
    input  logic [3:0]  dst,
    input logic         flag,
    input  logic        dataUnit_write,
    input  logic [15:0] write_data,
    input  logic        dataUnit_sav,
    input  logic        dataUnit_swp,
    input  logic        readEnable,

    // data and status outputs
    output logic [15:0] DATA_OUT,
    output logic [15:0] ACC_OUT,
    output logic        src_ready,    // Blocking
    output logic        dst_ready,    // Blocking
    output logic        ACC_Zero,
    output logic        ACC_Negative,

    // inputs
    input  logic [15:0] up_data_in,   input logic up_valid_in,   output logic up_ready_out,
    input  logic [15:0] dn_data_in,   input logic dn_valid_in,   output logic dn_ready_out,
    input  logic [15:0] lf_data_in,   input logic lf_valid_in,   output logic lf_ready_out,
    input  logic [15:0] rt_data_in,   input logic rt_valid_in,   output logic rt_ready_out,

    // outputs
    output logic [15:0] up_data_out,  output logic up_valid_out, input logic up_ready_in,
    output logic [15:0] dn_data_out,  output logic dn_valid_out, input logic dn_ready_in,
    output logic [15:0] lf_data_out,  output logic lf_valid_out, input logic lf_ready_in,
    output logic [15:0] rt_data_out,  output logic rt_valid_out, input logic rt_ready_in
);

    // operand binary codes
    localparam logic [3:0]
        PORT_NIL   = 4'b0000,
        PORT_ACC   = 4'b0001,
        PORT_BAK   = 4'b0010,
        PORT_UP    = 4'b0011,
        PORT_DOWN  = 4'b0100,
        PORT_LEFT  = 4'b0101,
        PORT_RIGHT = 4'b0110,
        PORT_ANY   = 4'b0111,
        PORT_LAST  = 4'b1000;

    // registers
    logic [15:0] ACC;
    logic [15:0] BAK;
    logic [3:0]  LAST_port;
    logic src_fire;
    logic dst_fire;


    assign ACC_OUT      = ACC;
    assign ACC_Zero     = (ACC == 16'b0);
    assign ACC_Negative = ACC[15];

    assign {up_data_out, dn_data_out, lf_data_out, rt_data_out} = {4{write_data}};

    assign src_fire = readEnable && src_ready;
    assign dst_fire = dataUnit_write && dst_ready;

    logic [3:0] final_src;
    logic [3:0] final_dst;

    // find source and dst real place
    always_comb begin
        // Source
        if      (src == PORT_LAST) final_src = LAST_port;
        else if (src == PORT_ANY) begin
            if      (up_valid_in)  final_src = PORT_UP;
            else if (lf_valid_in)  final_src = PORT_LEFT;
            else if (rt_valid_in)  final_src = PORT_RIGHT;
            else if (dn_valid_in)  final_src = PORT_DOWN;
            else                   final_src = PORT_UP;
        end else                   final_src = src;

        // Destination
        if      (dst == PORT_LAST) final_dst = LAST_port;
        else if (dst == PORT_ANY) begin
            if      (up_ready_in)  final_dst = PORT_UP;
            else if (lf_ready_in)  final_dst = PORT_LEFT;
            else if (rt_ready_in)  final_dst = PORT_RIGHT;
            else if (dn_ready_in)  final_dst = PORT_DOWN;
            else                   final_dst = PORT_UP;
        end else                   final_dst = dst;
    end

    // reading + ready, Blocking
    always_comb begin
        src_ready = 1'b1; 
        DATA_OUT  = 16'b0;
        {up_ready_out, dn_ready_out, lf_ready_out, rt_ready_out} = 4'b0000;

        if(readEnable) begin
            case (final_src)
                PORT_ACC:   DATA_OUT = ACC;
                PORT_UP:    if (!flag) begin
                                DATA_OUT = up_data_in;
                                src_ready = up_valid_in;
                                up_ready_out = 1'b1;
                            end
                PORT_DOWN:  if (!flag) begin
                                DATA_OUT = dn_data_in;
                                src_ready = dn_valid_in;
                                dn_ready_out = 1'b1;
                            end
                PORT_LEFT:  if (!flag) begin
                                DATA_OUT = lf_data_in;
                                src_ready = lf_valid_in;
                                lf_ready_out = 1'b1;
                            end
                PORT_RIGHT: if (!flag) begin
                                DATA_OUT = rt_data_in;
                                src_ready = rt_valid_in;
                                rt_ready_out = 1'b1;
                            end
                default:    DATA_OUT = 16'b0;
            endcase
        end
    end

    // writing + valid, Blocking
    always_comb begin
        dst_ready = 1'b1;
        {up_valid_out, dn_valid_out, lf_valid_out, rt_valid_out} = 4'b0000;

        case (final_dst)
            PORT_UP:    begin 
                            dst_ready = up_ready_in;
                            up_valid_out = dataUnit_write;
                        end
            PORT_DOWN:  begin
                            dst_ready = dn_ready_in;
                            dn_valid_out = dataUnit_write;
                        end
            PORT_LEFT:  begin
                            dst_ready = lf_ready_in;
                            lf_valid_out = dataUnit_write;
                        end
            PORT_RIGHT: begin 
                            dst_ready = rt_ready_in;
                            rt_valid_out = dataUnit_write;
                        end
            default:    dst_ready = 1'b1;
        endcase
    end

    // update registers
    always_ff @(posedge clk) begin
        if (rst) begin
            ACC       <= 16'b0;
            BAK       <= 16'b0;
            LAST_port <= PORT_UP; // default last port (for init)
        end
        else begin

            // SAV and SWP
            if (dataUnit_sav) begin
                BAK <= ACC;
            end else if (dataUnit_swp) begin
                ACC <= BAK;
                BAK <= ACC;
            end 

            // write on ACC
            else if (dataUnit_write && dst_ready && final_dst == PORT_ACC) begin
                ACC <= write_data;
            end
            
            // update LAST
            if (dst_fire && dst == PORT_ANY)
                LAST_port <= final_dst;
            else if (src_fire && src == PORT_ANY)
                LAST_port <= final_src;
        end
    end

endmodule