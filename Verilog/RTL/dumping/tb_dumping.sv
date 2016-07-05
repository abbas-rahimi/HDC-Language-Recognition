// This module reads all traning files and send letters to random_index_block for dumping hypervectors values (for arbitrary N)
// These values should be hardcoded in Verilog modules of Item memory and associative memory 
module tb(); 
parameter N = 10000;
parameter PRECISION = 32;
parameter MAXLETTERS = 27;
parameter NUMLANG = 22;

parameter init_st=0, olv_st=1, rlv_st=2, clv_st=3, wlv_st=4, fin=5;

reg [4:0] state;
reg letterReady, textDone;
wire [N-1 : 0] textVector;
reg [4 : 0] inputLetter;
reg [8:0] c;

integer	i, j, unknown;
integer	fileHandle;
reg clk, rst, rst_RI;
reg [4 : 0] langVectorSel;

// Address of training files
string langFileDir = "/tools/designs/ABS_HD/HDL/preprocessed_texts/"; 
string langFileAddr;
string langLabels[NUMLANG] = {"ell", "eng", "afr", "ita", "ces", "est", "spa", "nld", "por", "lav", "lit", "ron", "pol", "fra", "bul", "deu", "dan", "fin", "hun", "swe", "slk", "slv"};


always @(posedge clk)
begin
	if (!rst) begin
		state = init_st;
	end
	else
		case (state)
			init_st:
			begin
				langVectorSel = -1;
				rst_RI = 0;
				letterReady = 0;
				textDone = 0;
				state = olv_st;
			end
		
			olv_st:
				begin
					rst_RI = 0;
					letterReady = 0;
					textDone = 0;
					langVectorSel += 1;
					unknown = 0;
					if (langVectorSel < NUMLANG) begin
						langFileAddr = {langFileDir, langLabels[langVectorSel],".txt"};
						fileHandle = $fopen(langFileAddr,"r");
						state = rlv_st;
					end
					else
						state = fin;
				end
			
			rlv_st:
				begin
					letterReady = 1;
					rst_RI = 1;
					textDone = 0;
					
					c = $fgetc(fileHandle);
					if (c == 'h1ff) begin
						$display ("end of %s is reached with UNKNOWN=%d", langFileAddr, unknown);
						$fclose(fileHandle);
						state = clv_st;
					end
					else
						if (c == 32)  //ascii code space
							inputLetter <= MAXLETTERS - 1;
						else if (c >= 97 && c <= 122) //ascii code lowercase letters
							inputLetter <= c - 97;
						else 
							unknown += 1;
				end	
			
			clv_st: 
				begin
					rst_RI = 1;
					letterReady = 0;
					textDone = 1;
					state = wlv_st;
				end
			
			wlv_st: 
				begin
					rst_RI = 1;
					letterReady = 0;
					textDone = 0;
					state = olv_st;
				end
				
			fin:
				begin
					$display ("%d language files are encoded :-)", langVectorSel);
					$finish;
				end
			
		endcase
end


random_index_block #(N, PRECISION, MAXLETTERS) RIB(
	.letterReady (letterReady),
	.inputLetter (inputLetter),
	.textDone (textDone),
	.textVector (textVector),
	.clk (clk),	
	.rst (rst_RI));


initial begin
	clk = 0;
	rst = 0; 
	rst_RI = 0;
		
	#5;
	rst = 1; 
end

always #1 clk = !clk;


endmodule

