`timescale 10ns/1ns
`include "fifo.v"

module async_fifo_tb;

    reg [7:0] data_in;

    reg wclk;
    reg wrst_n;
    reg w_en;

    reg rclk;
    reg rrst_n;
    reg r_en;

    wire [7:0] data_out;

    wire full;
    wire empty;

    wire [3:0] b_wptr;
    wire [3:0] b_rptr;


    fifo DUT(
        .data_in  (data_in),
        .wclk     (wclk),
        .wrst_n   (wrst_n),
        .w_en     (w_en),

        .r_en     (r_en),
        .rclk     (rclk),
        .rrst_n   (rrst_n),

        .data_out (data_out),
        .full     (full),
        .empty    (empty),

        .b_wptr   (b_wptr),
        .b_rptr   (b_rptr)
    );


 
    initial begin
        wclk = 0;
        forever #5 wclk = ~wclk;
    end


    initial begin
        rclk = 0;
        forever #10 rclk = ~rclk;
    end


    initial begin
        wrst_n  = 0;
        rrst_n  = 0;
        w_en    = 0;
        r_en    = 0;
        data_in = 8'h00;

        #30;

        wrst_n = 1;
        rrst_n = 1;
    end


    integer i;

    initial begin

        wait(wrst_n == 1);

        #20;


        for (i = 0; i < 16; i = i + 1) begin

            if (full) begin

                while (!empty) begin
                    @(negedge wclk);
                    w_en    = 1'b1;
                    data_in = 8'h00; 
                end

            end

            @(negedge wclk);

            case(i)
                0:  data_in = 8'hA5;
                1:  data_in = 8'hB1;
                2:  data_in = 8'h92;
                3:  data_in = 8'h48;
                4:  data_in = 8'h34;
                5:  data_in = 8'h88;
                6:  data_in = 8'h79;
                7:  data_in = 8'h10;
                8:  data_in = 8'h07;
                9:  data_in = 8'h67;
                10: data_in = 8'hAA;
                11: data_in = 8'hBB;
                12: data_in = 8'hCC;
                13: data_in = 8'hDD;
                14: data_in = 8'hEE;
                15: data_in = 8'hFF;
            endcase

            w_en = 1'b1;

            $display(
                "WRITE #%0d : DATA=%02h | FULL=%b | WPTR=%0d",
                i+1,
                data_in,
                full,
                b_wptr
            );

        end

        // Finish write burst
        @(negedge wclk);
        w_en    = 1'b0;
        data_in = 8'h00;

    end

    integer j;

    initial begin

        wait(rrst_n == 1);

        #20;

        for(j = 0; j < 16; j = j + 1) begin

            wait(empty == 0);

            @(negedge rclk);
            r_en = 1;

            @(posedge rclk);
            #1;

            $display(
                "READ  #%0d : DATA=%02h | EMPTY=%b | RPTR=%0d",
                j+1,
                data_out,
                empty,
                b_rptr
            );

            @(negedge rclk);
            r_en = 0;

        end

        r_en = 0;

        wait(empty == 1);


        #50;
        $finish;

    end

    initial begin
        #10000;
        $finish;
    end

endmodule
