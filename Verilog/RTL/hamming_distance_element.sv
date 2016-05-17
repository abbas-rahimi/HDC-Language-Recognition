module hamming_distance_element(
	langVector,
    textVector,
    distance,
	index,
	enable,
	clk,
	rst
);
parameter N = 10000;
parameter PRECISION = $clog2 (N);
input [N-1 : 0] textVector;
input [N-1 : 0] langVector;
input [PRECISION-1 : 0] index;
output [PRECISION-1 : 0] distance;
input clk;
input rst;
input enable;

reg [PRECISION-1 : 0] distance;

always @(posedge clk) begin
	if (!rst) 
		distance <= 0;
	else 
		if (enable)
			if (langVector[index] ^ textVector[index])
				distance <= distance + 1;
		
end
endmodule