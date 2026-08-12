module read_side(
    input rclk,
    input rrst_n,
    input r_en,
    input [3:0] g_wptr_sync,

    output reg [3:0] b_rptr,
    output reg [3:0] g_rptr,
    output empty
);

    reg [3:0] b_rptr_next;
    reg [3:0] g_rptr_next;

    always @(*) begin
        b_rptr_next = b_rptr;

        if (r_en && !empty)
            b_rptr_next = b_rptr + 1'b1;

        g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next;
    end

    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            b_rptr <= 4'h0;
            g_rptr <= 4'h0;
        end else begin
            b_rptr <= b_rptr_next;
            g_rptr <= g_rptr_next;
        end
    end

    assign empty = (g_rptr == g_wptr_sync);

endmodule
