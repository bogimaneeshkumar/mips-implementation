/*
 *simple register which can hold data and clear
 */

module regr #(
    parameter N = 1
) (
    input clk,
    input clear,
    input hold,
    input wire [N-1:0] in,
    output reg [N-1:0] out
);

    always_ff @(posedge clk) begin
        if (clear)
            out <= {N{1'b0}};
        else if (hold)
            out <= out;
        else
            out <= in;
    end

endmodule
