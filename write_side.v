module write_side(
    input wclk,
    input wrst_n,
    input w_en,
    input [3:0] g_rptr_sync,

    output reg [3:0] g_wptr,
    output reg [3:0] b_wptr,
    output full
);

    reg [3:0] b_wptr_next;
    reg [3:0] g_wptr_next;

    

    always @(w_en) 
        begin
            b_wptr_next = b_wptr;

            if (w_en && !full) begin
                b_wptr_next = b_wptr + 1;
            end

            g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next;
        end

    always @(posedge wclk)
        begin
            if(!wrst_n) begin
                b_wptr <= 0;
                g_wptr <= 0;
            end

            else if(!full) begin
                b_wptr <= b_wptr_next;
                g_wptr <= g_wptr_next;
            end
        end

    assign full =(g_wptr_next =={~g_rptr_sync[3],g_rptr_sync[2:0]});

endmodule