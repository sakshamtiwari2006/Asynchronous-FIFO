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
    output [3:0] b_wptr, b_rptr 
);

    wire [3:0] g_wptr, g_rptr, g_rptr_sync, g_wptr_sync;
   
    synchronizer s_w(
        wclk,
        wrst_n,
        g_rptr, 
        g_rptr_sync);

    write_side wr(
        wclk,
        wrst_n,
        w_en,
        g_rptr_sync,
        g_wptr,
        b_wptr,
        full
    );

    synchronizer s_r (
        rclk, 
        rrst_n, 
        g_wptr, 
        g_wptr_sync);

    read_side rd(
        rclk,
        rrst_n,
        r_en,
        g_wptr_sync,
        b_rptr,
        g_rptr,
        empty
    );

    reg [7:0] fifo_stack[0:7];

    always @(posedge wclk)
        begin
            if(w_en && !full)begin
                fifo_stack[b_wptr[2:0]] <= data_in;
            end

        end

    always @(posedge rclk)
        begin
            if(!rrst_n)
                data_out <= 0;
            else if(r_en && !empty)begin
                data_out <= fifo_stack[b_rptr[2:0]];
            end
        end

endmodule