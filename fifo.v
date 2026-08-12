`include "write_side.v"
`include "read_side.v"
`include "synchronizer.v"

module fifo(
    input [7:0] data_in,
    input wclk,
    input wrst_n,
    input w_en,

    input r_en,
    input rrst_n,
    input rclk,

    output reg [7:0] data_out,
    output full,
    output empty,

    output [3:0] b_wptr,
    output [3:0] b_rptr
);

    wire [3:0] g_wptr;
    wire [3:0] g_rptr;

    wire [3:0] g_rptr_sync;
    wire [3:0] g_wptr_sync;

    synchronizer s_w(
        .clk     (wclk),
        .reset_n (wrst_n),
        .d_in    (g_rptr),
        .d_out   (g_rptr_sync)
    );

    write_side wr(
        .wclk        (wclk),
        .wrst_n      (wrst_n),
        .w_en        (w_en),
        .data_in     (data_in),
        .g_rptr_sync (g_rptr_sync),

        .g_wptr      (g_wptr),
        .b_wptr      (b_wptr),
        .full        (full)
    );

    reg [7:0] fifo_stack [0:7];

    always @(posedge wclk) begin
        if (w_en && (data_in != 8'h00) && !full) begin
            fifo_stack[b_wptr[2:0]] <= data_in;
        end
    end

    synchronizer s_r(
        .clk     (rclk),
        .reset_n (rrst_n),
        .d_in    (g_wptr),
        .d_out   (g_wptr_sync)
    );

    read_side rd(
        .rclk        (rclk),
        .rrst_n      (rrst_n),
        .r_en        (r_en),
        .g_wptr_sync (g_wptr_sync),

        .b_rptr      (b_rptr),
        .g_rptr      (g_rptr),
        .empty       (empty)
    );

    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n)
            data_out <= 8'h00;
        else if (r_en && !empty)
            data_out <= fifo_stack[b_rptr[2:0]];
    end

endmodule
