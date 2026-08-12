`timescale 10ns/1ns
`include "fifo.v"

module async_fifo_tb;

    reg  [7:0] data_in;
    reg        wclk;
    reg        wrst_n;
    reg        w_en;

    reg        r_en;
    reg        rclk;
    reg        rrst_n;

    wire [7:0] data_out;
    wire full, empty;

    wire [3:0] b_wptr, b_rptr;

    fifo DUT (
        .data_in (data_in),
        .wclk    (wclk),
        .wrst_n  (wrst_n),
        .w_en    (w_en),
        .r_en    (r_en),
        .rclk    (rclk),
        .rrst_n  (rrst_n),

        .data_out(data_out),
        .full(full),
        .empty(empty),
        .b_wptr(b_wptr),
        .b_rptr(b_rptr)
    );

    // write clock
    initial begin
        wclk = 0;
        forever #5 wclk = ~wclk;
    end

    // read clock
    initial begin
        rclk = 0;
        forever #10 rclk = ~rclk;
    end

    // stimulus
    initial begin
        data_in = 8'h00;
        w_en    = 1'b0;
        r_en    = 1'b0;
        wrst_n  = 1'b0;
        rrst_n  = 1'b0;

        #12 wrst_n = 1'b1; data_in = 8'ha5;

        #10  w_en = 1'b1; 
        #5  rrst_n = 1'b1; r_en = 1'b1; w_en = 1'b0;
        #5  w_en = 1'b1; data_in = 8'hb1;
        #5  r_en = 1'b0; w_en = 1'b0;
        #5  w_en = 1'b1; data_in = 8'h92;

        #5  r_en = 1'b1; w_en = 1'b0;
        #5  w_en = 1'b1; data_in = 8'h48;
        #5  r_en = 1'b0; w_en = 1'b0;
        #5  w_en = 1'b1; data_in = 8'h34;

        #5  r_en = 1'b1; w_en = 1'b0;
        #5  w_en = 1'b1; data_in = 8'h88;
        #5  r_en = 1'b0; w_en = 1'b0;
        #5  w_en = 1'b1; data_in = 8'h79;

        #5  r_en = 1'b1; w_en = 1'b0;
        #5  w_en = 1'b1; data_in = 8'h10;
        #5  r_en = 1'b0; w_en = 1'b0;
        #5  w_en = 1'b1; data_in = 8'h07;

        #5  r_en = 1'b1; w_en = 1'b0;
        #5  w_en = 1'b1; data_in = 8'h67;
        #5 r_en = 1'b0; w_en = 1'b0;
        #10 r_en = 1'b1;
        #10 r_en = 1'b0;
        #10 r_en = 1'b1;
        #10 r_en = 1'b0;
        #10 r_en = 1'b1;
        #10 r_en = 1'b0;

        #20000;
        $finish;
    end

endmodule