`timescale  1ns / 10ps
module faulty_HD_tb(); 
parameter N = 10000;
parameter PRECISION = $clog2 (N);
parameter PRECISION_RI = 10;
parameter MAXLETTERS = 27;
parameter NUMLANG = 22;
parameter LOG_NUMLANG = $clog2 (NUMLANG);
parameter init_mem_st=0, otv_st=1, rtv_st=2, wait_st=3, wtv_st=4, ctv_st=5, counting=6, readDistance =7, dummy=8, dummy2=9, fin=10;
parameter TOT_NUM_CELLS = 680365;

reg [4:0] state;
reg letterReady, textDone;
reg [4 : 0] inputLetter;
reg [8:0] c;
reg clk, rst, computeAngle, rst_RI;
wire [PRECISION-1 : 0] distance;
wire [LOG_NUMLANG-1 : 0] bestMatchID;
reg [PRECISION-1 : 0] index;
reg [PRECISION-1 : 0] samplingThreshold;
reg letterEncoding [N-1 : 0][MAXLETTERS-1 : 0];
reg langVector [N-1 : 0][NUMLANG-1 : 0];
reg argmax;
wire done;
integer	i, j, k, unknown, correct, numTests, waitingCycles, filerp, cellFaultRate;
integer	fileHandle, fileListHandle, fileHandleRI;
string langFileAddr;
string langLabels[NUMLANG] = {"ell", "eng", "afr", "ita", "ces", "est", "spa", "nld", "por", "lav", "lit", "ron", "pol", "fra", "bul", "deu", "dan", "fin", "hun", "swe", "slk", "slv"};
string textFileDir = "../testSentences/";
string textFileAddr;
string textFileName;
string actualLang;
reg [PRECISION-1 : 0] randomVal [N-1 : 0];

`include "../src/inject_fault_into_cell.v"

always @(posedge clk) begin	
	if (rst) begin
		for (i = 1; i <= TOT_NUM_CELLS; i = i + 1) 
			if (({$random} % cellFaultRate) == 1)
				inject_fault_into_cell (i);
	end
end


always @(posedge clk)
begin
	if (!rst) begin
		state <= init_mem_st; //olv_st;
	end
	else
		case (state)
			init_mem_st:
				begin
					rst_RI <= 0;
					letterReady <= 0;
					textDone <= 0;
					computeAngle <= 0;
					argmax <= 0;
					state <= otv_st;
					$display("Memory loading is done!");
				end
				
			otv_st:
				begin
					rst_RI <= 0;
					//if there is still a test file to read
					if ($fscanf(fileListHandle, "%s\n", textFileName) == 1) begin
						textFileAddr = {textFileDir, textFileName};
						fileHandle = $fopen(textFileAddr, "r");
						state <= rtv_st;
					end
					else
						state <= fin;
				end
			
			rtv_st:
				begin
					letterReady <= 1;
					rst_RI <= 1;
					textDone <= 0;
					c = $fgetc(fileHandle);
					if (c == 'h1ff) begin
						$display ("end of test file %s is reached", textFileAddr);
						$fclose(fileHandle);
						state <= ctv_st;
						numTests += 1;
					end
					else begin
						if (c == 32)  //ascii code space
							inputLetter <= MAXLETTERS - 1;
						else if (c >= 97 && c <= 122) //ascii code lowercase letters
							inputLetter <= c - 97;
						else 
							unknown += 1;
						state <= rtv_st;
					end
				end
			
			ctv_st: 
				begin
					rst_RI <= 1;
					letterReady <= 0;
					textDone <= 1;
					state <= wtv_st;
				end
				
			wtv_st:
				begin
					rst_RI <= 1;
					letterReady <= 0;
					textDone <= 0;
					computeAngle <= 1;
					index <= 0;
					argmax <= 0;
					state <= counting;
				end
			
			counting:
				begin
					rst_RI <= 1;
					letterReady <= 0;
					textDone <= 0;
					computeAngle <= 0;
					
					if (index < N - 1) begin
						index <= index + 1;
						state <= counting;
						argmax <= 0;
					end
					else begin
						argmax <= 1;
						state <= dummy;
						waitingCycles <= 0;
					end
				end
				
			dummy:
				state <= dummy2;
			
			dummy2:
				state <= wait_st;
				
			wait_st:
				begin
					if (done) begin
						if (langLabels[bestMatchID] == actualLang)
							correct += 1;
						else
							$display ("%s went to %s !! \n", actualLang, langLabels[bestMatchID]); 
		
						state <= otv_st;
						argmax <= 0;
						//$display ("index=%d  waitingCycles=%d", index, waitingCycles);
					end					
				end
			
			fin:
				begin
					filerp = $fopen("result.rep", "a+");	
					$fwrite (filerp, "\n Tests=%d correct=%d cellErrorRate=%d for ", numTests, correct, cellFaultRate, $time);
					$fclose (filerp);
	
					$display ("numTests=%d correct=%d for ", numTests, correct, $time);
					$finish;
				end
			
		endcase
end

hyperdimensional_module #(N, PRECISION_RI, MAXLETTERS, NUMLANG) HD(
//hyperdimensional_module HD(
	.letterReady (letterReady), 
	.inputLetter (inputLetter), 
	.textDone (textDone),
	
	.clk (clk), .rst (rst), .computeAngle (computeAngle), .rst_RI(rst_RI),
	.distance (distance), 
	.bestMatchID (bestMatchID), 
	.done (done),
	.index (index),
	.argmax (argmax)); 
 
initial begin
	clk = 0;
	rst = 0; 
	rst_RI = 0;
	unknown = 0;
	correct = 0;
	numTests = 0;
	argmax = 0;
	
	fileListHandle = $fopen ("cellFaultRate.txt", "r");
	$fscanf (fileListHandle, "%d", cellFaultRate);
	$fclose (fileListHandle);
	
	fileListHandle = $fopen ("cellFaultRate.txt", "w");
	$fwrite (fileListHandle, "%d", cellFaultRate - 100000);
	$fclose (fileListHandle);
	
	//list_full.bk  full short tiny  list_ultra_tiny
	fileListHandle = $fopen("../testSentences/list_ultra_tiny.bk","r");	

	$display ("Sims started with cell fault rate: %d", cellFaultRate);
	#10;
	rst = 1; 
	
end

always #1 clk = !clk;

always @(*) begin
	case ({textFileName[0], textFileName[1]})
		"af" : actualLang = "afr";
		"bg" : actualLang = "bul";
		"cs" : actualLang = "ces";
		"da" : actualLang = "dan";
		"nl" : actualLang = "nld";
		"de" : actualLang = "deu";
		"en" : actualLang = "eng";
		"et" : actualLang = "est";
		"fi" : actualLang = "fin";
		"fr" : actualLang = "fra";
		"el" : actualLang = "ell";
		"hu" : actualLang = "hun";
		"it" : actualLang = "ita"; 
		"lv" : actualLang = "lav";
		"lt" : actualLang = "lit";
		"pl" : actualLang = "pol";
		"pt" : actualLang = "por";
		"ro" : actualLang = "ron";
		"sk" : actualLang = "slk";
		"sl" : actualLang = "slv";
		"es" : actualLang = "spa";
		"sv" : actualLang = "swe";
	endcase
end

endmodule

/*
task inject_fault_into_cell;
input integer target;
integer id, y, z;
begin
	id = 0;
	//HDB: ------------------------------------------------------------------------------------
	//HDB:
	//output reg [PRECISION-1 : 0] distance;
	//output reg [LOG_NUMLANG-1 : 0] bestMatchID;
	//reg [LOG_NUMLANG-1 : 0] j;
	//reg [N-1 : 0] langVectorsMem [NUMLANG-1 : 0];
	//reg [1 : 0] state;
	//output reg done;
	//HDB: hamming_distance_element:
	//reg [PRECISION-1 : 0] distance;
	for (z = 0; z < PRECISION; z = z + 1) begin
		id += 1;
		if (id == target) HD.HDB.distance[z] = ~HD.HDB.distance[z];
	end
	
	for (z = 0; z < LOG_NUMLANG-1; z = z + 1) begin
		id += 1;
		if (id == target) HD.HDB.bestMatchID[z] = ~HD.HDB.bestMatchID[z];
		id += 1;
		if (id == target) HD.HDB.j[z] = ~HD.HDB.j[z];
	end	
	
	for (y = 0; y < N; y = y + 1) 
		for (z = 0; z < NUMLANG; z = z + 1) begin
			id += 1;
			if (id == target) HD.HDB.langVectorsMem[y][z] = ~HD.HDB.langVectorsMem[y][z];
		end
	
	for (z = 0; z < 1; z = z + 1) begin
		id += 1;
		if (id == target) HD.HDB.state[z] = ~HD.HDB.state[z];
	end
	
	id += 1;
	if (id == target) HD.HDB.done = ~HD.HDB.done;
	
	for (y = 0; y < PRECISION; y = y + 1) begin
		id += 1;
		if (id == target) HD.HDB.GEN[0].HD_element_i.distance[y] = ~HD.HDB.GEN[0].HD_element_i.distance[y];
		id += 1;
		if (id == target) HD.HDB.GEN[1].HD_element_i.distance[y] = ~HD.HDB.GEN[1].HD_element_i.distance[y];
		id += 1;
		if (id == target) HD.HDB.GEN[2].HD_element_i.distance[y] = ~HD.HDB.GEN[2].HD_element_i.distance[y];
		id += 1;
		if (id == target) HD.HDB.GEN[3].HD_element_i.distance[y] = ~HD.HDB.GEN[3].HD_element_i.distance[y];
		id += 1;
		if (id == target) HD.HDB.GEN[4].HD_element_i.distance[y] = ~HD.HDB.GEN[4].HD_element_i.distance[y];
		id += 1;
		if (id == target) HD.HDB.GEN[5].HD_element_i.distance[y] = ~HD.HDB.GEN[5].HD_element_i.distance[y];
		id += 1;
		if (id == target) HD.HDB.GEN[6].HD_element_i.distance[y] = ~HD.HDB.GEN[6].HD_element_i.distance[y];
		id += 1;
		if (id == target) HD.HDB.GEN[7].HD_element_i.distance[y] = ~HD.HDB.GEN[7].HD_element_i.distance[y];
		id += 1;
		if (id == target) HD.HDB.GEN[8].HD_element_i.distance[y] = ~HD.HDB.GEN[8].HD_element_i.distance[y];
		id += 1;
		if (id == target) HD.HDB.GEN[9].HD_element_i.distance[y] = ~HD.HDB.GEN[9].HD_element_i.distance[y];
		id += 1;
		if (id == target) HD.HDB.GEN[10].HD_element_i.distance[y] = ~HD.HDB.GEN[10].HD_element_i.distance[y];
		id += 1;
		if (id == target) HD.HDB.GEN[11].HD_element_i.distance[y] = ~HD.HDB.GEN[11].HD_element_i.distance[y];
		id += 1;
		if (id == target) HD.HDB.GEN[12].HD_element_i.distance[y] = ~HD.HDB.GEN[12].HD_element_i.distance[y];	
		id += 1;
		if (id == target) HD.HDB.GEN[13].HD_element_i.distance[y] = ~HD.HDB.GEN[13].HD_element_i.distance[y];	
		id += 1;
		if (id == target) HD.HDB.GEN[14].HD_element_i.distance[y] = ~HD.HDB.GEN[14].HD_element_i.distance[y];	
		id += 1;
		if (id == target) HD.HDB.GEN[15].HD_element_i.distance[y] = ~HD.HDB.GEN[15].HD_element_i.distance[y];	
		id += 1;
		if (id == target) HD.HDB.GEN[16].HD_element_i.distance[y] = ~HD.HDB.GEN[16].HD_element_i.distance[y];	
		id += 1;
		if (id == target) HD.HDB.GEN[17].HD_element_i.distance[y] = ~HD.HDB.GEN[17].HD_element_i.distance[y];	
		id += 1;
		if (id == target) HD.HDB.GEN[18].HD_element_i.distance[y] = ~HD.HDB.GEN[18].HD_element_i.distance[y];	
		id += 1;
		if (id == target) HD.HDB.GEN[19].HD_element_i.distance[y] = ~HD.HDB.GEN[19].HD_element_i.distance[y];	
		id += 1;
		if (id == target) HD.HDB.GEN[20].HD_element_i.distance[y] = ~HD.HDB.GEN[20].HD_element_i.distance[y];	
		id += 1;
		if (id == target) HD.HDB.GEN[21].HD_element_i.distance[y] = ~HD.HDB.GEN[21].HD_element_i.distance[y];		
	end

	//RIB: --------------------------------------------------------------------------------------------
	//reg [N-1 : 0] letterVector;
	//reg [N-1 : 0] letter_1;
	//reg [N-1 : 0] letter_2;
	//reg [N-1 : 0] letter_3;
	//output reg [N-1 : 0] textVector;
	//reg [PRECISION-1 : 0] posCounter [N-1 : 0];
	//reg [N-1 : 0] letterEncoding [MAXLETTERS-1 : 0];
	//reg [31 : 0] counter;
	//reg [2 : 0] state;
	
	for (z = 0; z < N; z = z + 1) begin
		id += 1;
		if (id == target) HD.RIB.letterVector[z] = ~HD.RIB.letterVector[z];
		id += 1;
		if (id == target) HD.RIB.letter_1[z] = ~HD.RIB.letter_1[z];
		id += 1;
		if (id == target) HD.RIB.letter_2[z] = ~HD.RIB.letter_2[z];
		id += 1;
		if (id == target) HD.RIB.letter_3[z] = ~HD.RIB.letter_3[z];
		id += 1;
		if (id == target) HD.RIB.textVector[z] = ~HD.RIB.textVector[z];
	end
	
	for (y = 0; y < PRECISION; y = y + 1) 
		for (z = 0; z < N; z = z + 1) begin
			id += 1;
			if (id == target) HD.RIB.posCounter[y][z] = ~HD.RIB.posCounter[y][z];
		end
	
	for (y = 0; y < N; y = y + 1) 
		for (z = 0; z < MAXLETTERS; z = z + 1) begin
			id += 1;
			if (id == target) HD.RIB.letterEncoding[y][z] = ~HD.RIB.letterEncoding[y][z];
		end
	
	for (z = 0; z < 31; z = z + 1) begin
		id += 1;
		if (id == target) HD.RIB.counter[z] = ~HD.RIB.counter[z];
	end
	
	for (z = 0; z < 2; z = z + 1) begin
		id += 1;
		if (id == target) HD.RIB.state[z] = ~HD.RIB.state[z];
	end

	//$display ("# of memory cells covered for fault injection=%d", id);
end
endtask
*/
