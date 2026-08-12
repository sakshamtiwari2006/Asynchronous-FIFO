module write_side(
    input        wclk,
    input        wrst_n,
    input        w_en,
    input [7:0]  data_in,
    input [3:0]  g_rptr_sync,

    output reg [3:0] g_wptr,
    output reg [3:0] b_wptr,
    output reg       full
);

    reg [3:0] b_wptr_next;
    reg [3:0] g_wptr_next;
    wire full_val;

    always @(*) begin
        b_wptr_next = b_wptr;

        if (w_en && (data_in != 8'h00) && !full)
            b_wptr_next = b_wptr + 1'b1;

        g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next;
    end

    assign full_val = (g_wptr_next == {~g_rptr_sync[3:2], g_rptr_sync[1:0]});

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            b_wptr <= 4'h0;
            g_wptr <= 4'h0;
            full   <= 1'b0;
        end
        else begin
            b_wptr <= b_wptr_next;
            g_wptr <= g_wptr_next;
            full   <= full_val;
        end
    end

endmodule
