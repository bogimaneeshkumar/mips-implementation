/*
 *simple register which can hold data and clear
 */

module regr #(
    parameter N = 1
) (
    input wire clk,
    input wire clear,
    input wire hold,
    input wire [N-1:0] in,
    output reg [N-1:0] out
);

    always@(posedge clk) begin
        if (clear)
            out <= {N{1'b0}};
        else if (hold)
            out <= out;
        else
            out <= in;
    end

endmodule
