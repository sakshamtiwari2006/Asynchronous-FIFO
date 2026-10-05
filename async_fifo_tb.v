`timescale 1ns/1ps

`include "fifo.v"

module async_fifo_tb;

    // SIGNAL DECLARATIONS

    reg [7:0] data_in;
    reg       wclk;
    reg       wrst_n;
    reg       w_en;

    reg       rclk;
    reg       rrst_n;
    reg       r_en;

    wire [7:0] data_out;
    wire       full;
    wire       empty;

    wire [3:0] b_wptr;
    wire [3:0] b_rptr;


    // DUT INSTANTIATION

    fifo DUT (
        .data_in  (data_in),
        .wclk     (wclk),
        .wrst_n   (wrst_n),
        .w_en     (w_en),
        .r_en     (r_en),
        .rrst_n   (rrst_n),
        .rclk     (rclk),
        .data_out (data_out),
        .full     (full),
        .empty    (empty),
        .b_wptr   (b_wptr),
        .b_rptr   (b_rptr)
    );


    
    // WRITE CLOCK

    initial begin
        wclk = 1'b0;

        forever
            #5 wclk = ~wclk;
    end


    // READ CLOCK

    initial begin
        rclk = 1'b0;

        forever
            #10 rclk = ~rclk;
    end


    // RESET

    initial begin
        wrst_n  = 1'b0;
        rrst_n  = 1'b0;

        w_en    = 1'b0;
        r_en    = 1'b0;

        data_in = 8'h00;

        #40;

        wrst_n = 1'b1;
        rrst_n = 1'b1;
    end


    // TEST DATA

    reg [7:0] test_data [0:15];

    integer wi;
    integer ri;

    integer write_count;
    integer read_count;

    initial begin
        test_data[0]  = 8'hA5;
        test_data[1]  = 8'hB1;
        test_data[2]  = 8'h92;
        test_data[3]  = 8'h48;

        test_data[4]  = 8'h34;
        test_data[5]  = 8'h88;
        test_data[6]  = 8'h79;
        test_data[7]  = 8'h10;

        test_data[8]  = 8'h07;
        test_data[9]  = 8'h67;
        test_data[10] = 8'hAA;
        test_data[11] = 8'hBB;

        test_data[12] = 8'hCC;
        test_data[13] = 8'hDD;
        test_data[14] = 8'hEE;
        test_data[15] = 8'hFF;

        write_count = 0;
        read_count  = 0;
    end


    // WRITE PROCESS

    initial begin
        wait(wrst_n == 1'b1);

        @(negedge wclk);

        for (wi = 0; wi < 16; wi = wi + 1) begin

            while (full)
                @(negedge wclk);

            data_in = test_data[wi];

            w_en = 1'b1;

            @(posedge wclk);

            #1;

            $display("Writing data: %02h", data_in);

            write_count = write_count + 1;

            @(negedge wclk);

            w_en = 1'b0;

            data_in = 8'h00;
        end

        $display("");
        $display("All data written successfully.");
        $display("");
    end


    // READ PROCESS

    initial begin
        wait(rrst_n == 1'b1);

        @(negedge rclk);

        for (ri = 0; ri < 16; ri = ri + 1) begin

            while (empty)
                @(negedge rclk);

            r_en = 1'b1;

            @(posedge rclk);

            #1;

            if (data_out !== test_data[ri]) begin

                $display(
                    "Read data: %02h - ERROR (Expected %02h)",
                    data_out,
                    test_data[ri]
                );

            end

            else begin

                $display(
                    "Read data: %02h - PASS",
                    data_out
                );

            end

            read_count = read_count + 1;

            @(negedge rclk);

            r_en = 1'b0;
        end

        $display("");
        $display("All data read successfully.");
        $display("");

        wait(empty == 1'b1);

        #30;

        if ((write_count == 16) &&
            (read_count  == 16)) begin

            $display("       FIFO TEST PASSED");

        end

        else begin

            $display("       FIFO TEST FAILED");

        end

        $finish;
    end




    initial begin

        $monitor(
            "Time=%0t | Write=%b Read=%b | Data In=%02h | Data Out=%02h | Full=%b Empty=%b",
            $time,
            w_en,
            r_en,
            data_in,
            data_out,
            full,
            empty
        );

    end


    initial begin

        #5000;

        $display("");
        $display("FIFO test stopped: simulation timeout.");
        $display("");

        $finish;

    end

endmodule
