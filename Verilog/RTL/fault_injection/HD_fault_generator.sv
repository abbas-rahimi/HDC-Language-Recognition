`timescale  1ns / 10ps
module HD_fault_generator(); 
parameter N = 10000;
parameter PRECISION = $clog2 (N);
parameter PRECISION_RI = 10;
parameter MAXLETTERS = 27;
parameter NUMLANG = 22;
parameter LOG_NUMLANG = $clog2 (NUMLANG);

integer filep;

task inject_fault_into_cell;
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

	$fwrite (filep, "task inject_fault_into_cell;\n");
	$fwrite (filep, "input integer target;\n");
	$fwrite (filep, "begin\n");
	$fwrite (filep, "case (target)\n");
	
	for (z = 0; z < PRECISION; z = z + 1) begin
		id += 1;
		//if (id == target) HD.HDB.distance[z] = ~HD.HDB.distance[z];
		$fwrite (filep, "%d: HD.HDB.distance[%2d] = ~HD.HDB.distance[%2d];\n", id, z, z);
	end
	
	for (z = 0; z < LOG_NUMLANG-1; z = z + 1) begin
		id += 1;
		//if (id == target) HD.HDB.bestMatchID[z] = ~HD.HDB.bestMatchID[z];
		$fwrite (filep, "%d: HD.HDB.bestMatchID[%2d] = ~HD.HDB.bestMatchID[%2d];\n", id, z, z);
		
		id += 1;
		//if (id == target) HD.HDB.j[z] = ~HD.HDB.j[z];
		$fwrite (filep, "%d: HD.HDB.j[%2d] = ~HD.HDB.j[%2d];\n", id, z, z);
	end
	
	for (y = 0; y < N; y = y + 1) 
		for (z = 0; z < NUMLANG; z = z + 1) begin
			id += 1;
			//if (id == target) HD.HDB.langVectorsMem[y][z] = ~HD.HDB.langVectorsMem[y][z];
			$fwrite (filep, "%d: HD.HDB.langVectorsMem[%2d][%2d] = ~HD.HDB.langVectorsMem[%2d][%2d];\n", id, y, z, y, z);
		end
	
	for (z = 0; z < 1; z = z + 1) begin
		id += 1;
		//if (id == target) HD.HDB.state[z] = ~HD.HDB.state[z];
		$fwrite (filep, "%d: HD.HDB.state[%2d] = ~HD.HDB.state[%2d];\n", id, z, z);
	end
	
	id += 1;
	//if (id == target) HD.HDB.done = ~HD.HDB.done;
	$fwrite (filep, "%d: HD.HDB.done = ~HD.HDB.done;\n", id);

	for (y = 0; y < PRECISION; y = y + 1) 
		for (z = 0; z < NUMLANG; z = z + 1) begin
			id += 1;
			//if (id == target) HD.HDB.GEN[z].HD_element_i.distance[y] = ~HD.HDB.GEN[z].HD_element_i.distance[y];
			$fwrite (filep, "%d: HD.HDB.GEN[%2d].HD_element_i.distance[%2d] = ~HD.HDB.GEN[%2d].HD_element_i.distance[%2d];\n", id, z, y, z, y);
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
		//if (id == target) HD.RIB.letterVector[z] = ~HD.RIB.letterVector[z];
		$fwrite (filep, "%d: HD.RIB.letterVector[%2d] = ~HD.RIB.letterVector[%2d];\n", id, z, z);
		
		id += 1;
		//if (id == target) HD.RIB.letter_1[z] = ~HD.RIB.letter_1[z];
		$fwrite (filep, "%d: HD.RIB.letter_1[%2d] = ~HD.RIB.letter_1[%2d];\n", id, z, z);
		
		id += 1;
		//if (id == target) HD.RIB.letter_2[z] = ~HD.RIB.letter_2[z];
		$fwrite (filep, "%d: HD.RIB.letter_2[%2d] = ~HD.RIB.letter_2[%2d];\n", id, z, z);
		
		id += 1;
		//if (id == target) HD.RIB.letter_3[z] = ~HD.RIB.letter_3[z];
		$fwrite (filep, "%d: HD.RIB.letter_3[%2d] = ~HD.RIB.letter_3[%2d];\n", id, z, z);
		
		id += 1;
		//if (id == target) HD.RIB.textVector[z] = ~HD.RIB.textVector[z];
		$fwrite (filep, "%d: HD.RIB.textVector[%2d] = ~HD.RIB.textVector[%2d];\n", id, z, z);
	end
	
	for (y = 0; y < PRECISION_RI; y = y + 1) 
		for (z = 0; z < N; z = z + 1) begin
			id += 1;
			//if (id == target) HD.RIB.posCounter[y][z] = ~HD.RIB.posCounter[y][z];
			//$fwrite (filep, "%d: HD.RIB.posCounter[%2d][%2d] = ~HD.RIB.posCounter[%2d][%2d];\n", id, y, z, y, z);
			$fwrite (filep, "%d: HD.RIB.posCounter[%2d][%2d] = ~HD.RIB.posCounter[%2d][%2d];\n", id, z, y, z, y);
		end
	
	for (y = 0; y < N; y = y + 1) 
		for (z = 0; z < MAXLETTERS; z = z + 1) begin
			id += 1;
			//if (id == target) HD.RIB.letterEncoding[y][z] = ~HD.RIB.letterEncoding[y][z];
			$fwrite (filep, "%d: HD.RIB.letterEncoding[%2d][%2d] = ~HD.RIB.letterEncoding[%2d][%2d];\n", id, y, z, y, z);
		end
	
	for (z = 0; z < 31; z = z + 1) begin
		id += 1;
		//if (id == target) HD.RIB.counter[z] = ~HD.RIB.counter[z];
		$fwrite (filep, "%d: HD.RIB.counter[%2d] = ~HD.RIB.counter[%2d];\n", id, z, z);
	end
	
	for (z = 0; z < 2; z = z + 1) begin
		id += 1;
		//if (id == target) HD.RIB.state[z] = ~HD.RIB.state[z];
		$fwrite (filep, "%d: HD.RIB.state[%2d] = ~HD.RIB.state[%2d];\n", id, z, z);
	end
	$fwrite (filep, "endcase\n");
	$fwrite (filep, "end\n");
	$fwrite (filep, "endtask\n");
	//$fwrite (filep, "%d: ;\n", id, z, z);
	//$display ("# of memory cells covered for fault injection=%d", id);
	
end
endtask
 
initial begin
	filep = $fopen("../src/inject_fault_into_cell.v", "w");
	inject_fault_into_cell;
	$display ("inject_fault_into_cell.v dummped");
	$finish;
end
endmodule

