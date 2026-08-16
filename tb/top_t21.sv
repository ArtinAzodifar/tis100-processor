module top_t21 (
    input logic clk,
    input logic rst
);
    // سیگنال‌های واسط
    // A
    logic [15:0] A_up_data_in, A_dn_data_in, A_lf_data_in, A_rt_data_in;
    logic A_up_valid_in, A_dn_valid_in, A_lf_valid_in, A_rt_valid_in;
    logic A_up_ready_out, A_dn_ready_out, A_lf_ready_out, A_rt_ready_out;
    logic [15:0] A_up_data_out, A_dn_data_out, A_lf_data_out, A_rt_data_out;
    logic A_up_valid_out, A_dn_valid_out, A_lf_valid_out, A_rt_valid_out;
    logic A_up_ready_in, A_dn_ready_in, A_lf_ready_in, A_rt_ready_in;

    // B
    logic [15:0] B_up_data_in, B_dn_data_in, B_lf_data_in, B_rt_data_in;
    logic B_up_valid_in, B_dn_valid_in, B_lf_valid_in, B_rt_valid_in;
    logic B_up_ready_out, B_dn_ready_out, B_lf_ready_out, B_rt_ready_out;
    logic [15:0] B_up_data_out, B_dn_data_out, B_lf_data_out, B_rt_data_out;
    logic B_up_valid_out, B_dn_valid_out, B_lf_valid_out, B_rt_valid_out;
    logic B_up_ready_in, B_dn_ready_in, B_lf_ready_in, B_rt_ready_in;

    // C
    logic [15:0] C_up_data_in, C_dn_data_in, C_lf_data_in, C_rt_data_in;
    logic C_up_valid_in, C_dn_valid_in, C_lf_valid_in, C_rt_valid_in;
    logic C_up_ready_out, C_dn_ready_out, C_lf_ready_out, C_rt_ready_out;
    logic [15:0] C_up_data_out, C_dn_data_out, C_lf_data_out, C_rt_data_out;
    logic C_up_valid_out, C_dn_valid_out, C_lf_valid_out, C_rt_valid_out;
    logic C_up_ready_in, C_dn_ready_in, C_lf_ready_in, C_rt_ready_in;

    // گره‌ها (توجه: imem هر گره باید فایل مربوط به خود را بخواند)
    t21 #(.PROG_FILE("progA.txt")) A_inst (
        .clk, .rst,
        .up_data_in(A_up_data_in), .up_valid_in(A_up_valid_in), .up_ready_out(A_up_ready_out),
        .dn_data_in(A_dn_data_in), .dn_valid_in(A_dn_valid_in), .dn_ready_out(A_dn_ready_out),
        .lf_data_in(A_lf_data_in), .lf_valid_in(A_lf_valid_in), .lf_ready_out(A_lf_ready_out),
        .rt_data_in(A_rt_data_in), .rt_valid_in(A_rt_valid_in), .rt_ready_out(A_rt_ready_out),
        .up_data_out(A_up_data_out), .up_valid_out(A_up_valid_out), .up_ready_in(A_up_ready_in),
        .dn_data_out(A_dn_data_out), .dn_valid_out(A_dn_valid_out), .dn_ready_in(A_dn_ready_in),
        .lf_data_out(A_lf_data_out), .lf_valid_out(A_lf_valid_out), .lf_ready_in(A_lf_ready_in),
        .rt_data_out(A_rt_data_out), .rt_valid_out(A_rt_valid_out), .rt_ready_in(A_rt_ready_in)
    );

    t21 #(.PROG_FILE("progB.txt")) B_inst (
        .clk, .rst,
        .up_data_in(B_up_data_in), .up_valid_in(B_up_valid_in), .up_ready_out(B_up_ready_out),
        .dn_data_in(B_dn_data_in), .dn_valid_in(B_dn_valid_in), .dn_ready_out(B_dn_ready_out),
        .lf_data_in(B_lf_data_in), .lf_valid_in(B_lf_valid_in), .lf_ready_out(B_lf_ready_out),
        .rt_data_in(B_rt_data_in), .rt_valid_in(B_rt_valid_in), .rt_ready_out(B_rt_ready_out),
        .up_data_out(B_up_data_out), .up_valid_out(B_up_valid_out), .up_ready_in(B_up_ready_in),
        .dn_data_out(B_dn_data_out), .dn_valid_out(B_dn_valid_out), .dn_ready_in(B_dn_ready_in),
        .lf_data_out(B_lf_data_out), .lf_valid_out(B_lf_valid_out), .lf_ready_in(B_lf_ready_in),
        .rt_data_out(B_rt_data_out), .rt_valid_out(B_rt_valid_out), .rt_ready_in(B_rt_ready_in)
    );

    t21 #(.PROG_FILE("progC.txt")) C_inst (
        .clk, .rst,
        .up_data_in(C_up_data_in), .up_valid_in(C_up_valid_in), .up_ready_out(C_up_ready_out),
        .dn_data_in(C_dn_data_in), .dn_valid_in(C_dn_valid_in), .dn_ready_out(C_dn_ready_out),
        .lf_data_in(C_lf_data_in), .lf_valid_in(C_lf_valid_in), .lf_ready_out(C_lf_ready_out),
        .rt_data_in(C_rt_data_in), .rt_valid_in(C_rt_valid_in), .rt_ready_out(C_rt_ready_out),
        .up_data_out(C_up_data_out), .up_valid_out(C_up_valid_out), .up_ready_in(C_up_ready_in),
        .dn_data_out(C_dn_data_out), .dn_valid_out(C_dn_valid_out), .dn_ready_in(C_dn_ready_in),
        .lf_data_out(C_lf_data_out), .lf_valid_out(C_lf_valid_out), .lf_ready_in(C_lf_ready_in),
        .rt_data_out(C_rt_data_out), .rt_valid_out(C_rt_valid_out), .rt_ready_in(C_rt_ready_in)
    );

    // اتصالات
    // A.RIGHT <-> B.LEFT
    assign B_lf_data_in  = A_rt_data_out;
    assign B_lf_valid_in = A_rt_valid_out;
    assign A_rt_ready_in = B_lf_ready_out;

    assign A_rt_data_in  = B_lf_data_out;
    assign A_rt_valid_in = B_lf_valid_out;
    assign B_lf_ready_in = A_rt_ready_out;

    // A.DOWN <-> C.UP
    assign C_up_data_in  = A_dn_data_out;
    assign C_up_valid_in = A_dn_valid_out;
    assign A_dn_ready_in = C_up_ready_out;

    assign A_dn_data_in  = C_up_data_out;
    assign A_dn_valid_in = C_up_valid_out;
    assign C_up_ready_in = A_dn_ready_out;

    // پورت‌های بلااستفاده را غیرفعال کن
    assign {A_up_valid_in, A_lf_valid_in} = '0;
    assign {A_up_ready_in, A_lf_ready_in} = '1;
    assign {B_up_valid_in, B_dn_valid_in, B_rt_valid_in} = '0;
    assign {B_up_ready_in, B_dn_ready_in, B_rt_ready_in} = '1;
    assign {C_dn_valid_in, C_lf_valid_in, C_rt_valid_in} = '0;
    assign {C_dn_ready_in, C_lf_ready_in, C_rt_ready_in} = '1;
endmodule