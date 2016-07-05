// This module is in charge of perfoming the encoding of trained inputs
// After training it write two files:
// 1- letterVector.txt which contains the random hypevector values to be used in Item Memory 
// 2- langVector.txt  which contains the 21 trained hypevector to be used in associative memory
module random_index_block(
	letterReady,
	inputLetter,
	textDone,
	textVector,
	clk,
	rst
);
parameter N = 10000;
parameter PRECISION = 31;
parameter MAXLETTERS = 27;
`define DUMP 1
`define TYPICAL 1


input [4 : 0] inputLetter;
output reg [N-1 : 0] textVector;
input clk;
input rst;
input textDone;
input letterReady;

int j, seed, fileHandle, fileHandleLV, i;
reg [N-1 : 0] letterVector;
reg [N-1 : 0] letter_1;
reg [N-1 : 0] letter_2;
reg [N-1 : 0] letter_3;
reg [PRECISION-1 : 0] posCounter [N-1 : 0];
reg [31 : 0] counter;
reg [N-1 : 0] letterEncoding [MAXLETTERS-1 : 0];
reg [N-1 : 0] OneEncodedLetter;
reg [2 : 0] state;
wire [N-1 : 0] tetagramVector;

initial begin
	seed = 0;
	for (j = 0; j < MAXLETTERS; j = j + 1) begin
		for (i = 0; i < N; i = i + 1)
			OneEncodedLetter[i] = $random(seed) % 2;
		letterEncoding[j] = OneEncodedLetter;
	end
	

`ifdef TYPICAL
	fileHandleLV = $fopen("langVector.txt","w");
	fileHandle   = $fopen("letterVector.txt","w");
`endif


`ifdef DUMP
	for (j = 0; j < MAXLETTERS; j = j + 1) begin
		OneEncodedLetter = letterEncoding[j]; 
		for (i = 0; i < N; i = i + 1)
			$fwrite (fileHandle, "%d ", OneEncodedLetter[i]);
	end
				
	$fclose(fileHandle);
`endif		
end 

// Shift registers and compute tetagram
always @(posedge clk) begin
	if (!rst) begin	
		for (j = 0; j < N; j = j + 1) begin
			posCounter[j] <= 0;
		end
		letter_1 <= 0;
		letter_2 <= 0;
		letter_3 <= 0;
		state <= 0;
		counter <= 0;
		$display ("Reseting RI...");
	end
	else 
		if (letterReady) begin
			
			letter_3 <= letterVector;
				
			letter_2[N-1] <= letter_3[0]; 
			letter_2[N-2 : 0] <= letter_3[N-1 : 1];		
			
			letter_1[N-1] <= letter_2[0]; 
			letter_1[N-2 : 0] <= letter_2[N-1 : 1];
			
			if (state < 3)
				state <= state + 1;
			else begin
				counter <= counter + 1;
					
				for (j = 0; j < N; j = j + 1) 
					if (tetagramVector [j] == 1'b1)
						posCounter[j] <= posCounter[j] + 1;	
			end
		end
end

assign tetagramVector = letter_3 ^ letter_2 ^ letter_1;

// Do thresholding based on counter values
always @(posedge clk) begin
	if (!rst)
		textVector = 0;
	else
		if (textDone) begin 

`ifdef TYPICAL		
			for (j = 0; j < N; j = j + 1) begin
				if (posCounter[j] > (counter >> 1))
					textVector[j] = 1;
				else
					textVector[j] = 0;
			end
`endif		

			
`ifdef DUMP
			for (j = 0; j < N; j = j + 1) begin
				$fwrite (fileHandleLV, "%d ", textVector[j]);
			end
			$fwrite (fileHandleLV, "\n");
			$display ("Writing lang vectors...");
`endif
		end
end

always @(posedge clk) begin
	if (rst) begin
		letterVector <= letterEncoding [inputLetter];
	end
end 
endmodule