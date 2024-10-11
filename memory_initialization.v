module memory_initialization;
integer i;

// Instruction Memory Initialization
	INSTR_MEM[0] = 32'h00500413;
	INSTR_MEM[1] = 32'hffd00493;
	INSTR_MEM[2] = 32'h02940933;
	INSTR_MEM[3] = 32'h80000437;
	INSTR_MEM[4] = 32'h00040413;
	INSTR_MEM[5] = 32'h00200493;
	INSTR_MEM[6] = 32'h029439b3;
	INSTR_MEM[7] = 32'h01400413;
	INSTR_MEM[8] = 32'h00300493;
	INSTR_MEM[9] = 32'h02945a33;
	INSTR_MEM[10] = 32'h000000ef;
	for (i = 11; i < 128; i = i + 1) begin
		INSTR_MEM[i] = 32'h0;
	end

// Data Constant Memory Initialization
	DATA_CONST_MEM[0] = 32'h00000004;
	DATA_CONST_MEM[1] = 32'h65570a0d;
	DATA_CONST_MEM[2] = 32'h6d6f636c;
	DATA_CONST_MEM[3] = 32'h6f742065;
	DATA_CONST_MEM[4] = 32'h33474320;
	DATA_CONST_MEM[5] = 32'h2e373032;
	DATA_CONST_MEM[6] = 32'h000a0d2e;
	DATA_CONST_MEM[7] = 32'h00000005;
	for (i = 8; i < 128; i = i + 1) begin
		DATA_CONST_MEM[i] = 32'h0;
	end
endmodule