module hyperdimensional_module(
	letterReady, inputLetter, textDone,
	clk, rst, computeAngle, rst_RI,
	distance, bestMatchID, index, argmax, done); 
parameter N = 10000;
parameter PRECISION_RI = 10;
parameter MAXLETTERS = 27;
parameter NUMLANG = 22;
parameter LOG_NUMLANG = $clog2 (NUMLANG);
parameter PRECISION = $clog2 (N); //14; // Log (N)

input letterReady;
input argmax;
input [4 : 0] inputLetter;
input textDone;
input clk, rst, computeAngle, rst_RI;

output [PRECISION-1 : 0] distance;
output [LOG_NUMLANG-1 : 0] bestMatchID;
output done;
input [PRECISION-1 : 0] index;

wire [N-1 : 0] textVector;

random_index_block #(N, PRECISION_RI, MAXLETTERS) RIB(
	.letterReady (letterReady),
	.inputLetter (inputLetter),
	.textDone (textDone),
	.textVector (textVector),
	.clk (clk),	.rst (rst_RI));

hamming_distance_block #(N, PRECISION, NUMLANG, LOG_NUMLANG) HDB(
    .textVector (textVector), 
	.computeAngle (computeAngle),
    .distance (distance),
	.bestMatchID (bestMatchID),
	.index (index),
	.argmax (argmax),
	.done (done),
	.clk (clk),	.rst (rst));
endmodule

