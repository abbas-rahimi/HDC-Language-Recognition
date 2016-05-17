`timescale  1ns / 10ps
module tb(); 
parameter N = 10000;
parameter PRECISION = $clog2 (N);
parameter PRECISION_RI = 10;
parameter MAXLETTERS = 27;
parameter NUMLANG = 22;
parameter LOG_NUMLANG = $clog2 (NUMLANG);
parameter init_mem_st=0, otv_st=1, rtv_st=2, wait_st=3, wtv_st=4, ctv_st=5, counting=6, readDistance =7, dummy=8, dummy2=9, fin=10;

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


integer	i, j, k, unknown, correct, numTests, waitingCycles;
integer	fileHandle, fileListHandle, fileHandleRI;

string langFileAddr;
string langLabels[NUMLANG] = {"ell", "eng", "afr", "ita", "ces", "est", "spa", "nld", "por", "lav", "lit", "ron", "pol", "fra", "bul", "deu", "dan", "fin", "hun", "swe", "slk", "slv"};

string textFileDir = "../../testing_texts/";
string textFileAddr;
string textFileName;
string actualLang;

reg [PRECISION-1 : 0] randomVal [N-1 : 0];

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
	//list_full.lst  
	fileListHandle = $fopen("../../testing_texts/list_ultra_tiny.lst","r");	

	$display ("Sims started");
	#10;
	rst = 1; 
	
end

always #2.3 clk = !clk;

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

