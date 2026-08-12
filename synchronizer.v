module synchronizer(
    input clk,
    input reset_n,
    input [3:0] d_in,
    output [3:0] d_out
);

    reg [3:0] q1,q2;

    always @(posedge clk)
    begin

        if(reset_n == 1'b0)begin
            q1 <= 4'h0;
            q2 <= 4'h0;
        end

        else begin
            q1 <= d_in;
            q2 <= q1;
        end
    end

    assign d_out = q2;

endmodule