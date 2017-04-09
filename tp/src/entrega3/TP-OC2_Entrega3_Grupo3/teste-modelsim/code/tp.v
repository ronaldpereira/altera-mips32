module tp(
input CLOCK_50, // FPGA Clock 50 MHz
//input [3:0] KEY, // FPGA KEY input (for FPGA testing)
output [8:0] LEDG, // Green led (Clock [25] counter)
output [6:0] HEX0, // First seven segments display
output [6:0] HEX1 // Second seven segments display
);

reg [3:0] KEY = 3'b000; // ModelSim Simulation on Key[0] of FPGA input

reg [31:0] clk = 32'd0; // Clock

reg [2:0] FSM_1; // Finite State Machine -> tells which stage the processor is (IF, ID, EX, MEMl, WB)
reg [2:0] FSM_2;
reg [2:0] FSM_3;
reg [2:0] FSM_4;
reg [2:0] FSM_5;

reg [15:0] FSM2_1; // Finite State Machine (auxiliar) -> tells which OpCode
reg [15:0] FSM2_2;
reg [15:0] FSM2_3;
reg [15:0] FSM2_4;
reg [15:0] FSM2_5;

integer i; // Auxiliar to the for loop

reg [9:0] pc; // Program Counter (goes 1 to 1)
reg [31:0] registers [31:0]; // Register bank

reg [31:0] instruction;
reg [31:0] instruction_1; // Instruction inputs
reg [31:0] instruction_2;
reg [31:0] instruction_3;
reg [31:0] instruction_4;
reg [31:0] instruction_5;

reg [31:0] aluOutput;
reg [31:0] aluOutput_1; // Outputs of the ALU
reg [31:0] aluOutput_2;
reg [31:0] aluOutput_3;
reg [31:0] aluOutput_4;
reg [31:0] aluOutput_5;

reg [31:0] auxMem_1; // Memory stage auxiliars
reg [31:0] auxMem_2;
reg [31:0] auxMem_3;
reg [31:0] auxMem_4;
reg [31:0] auxMem_5;

reg writeEnable;
reg writeEnable_1; // Write Enable bit
reg writeEnable_2;
reg writeEnable_3;
reg writeEnable_4;
reg writeEnable_5;

reg Zero;
reg Zero_1; // Branch auxiliars
reg Zero_2;
reg Zero_3;
reg Zero_4;
reg Zero_5;

reg [31:0] A_1; // First operands
reg [31:0] A_2;
reg [31:0] A_3;
reg [31:0] A_4;
reg [31:0] A_5;

reg [31:0] B_1; // Second operands
reg [31:0] B_2;
reg [31:0] B_3;
reg [31:0] B_4;
reg [31:0] B_5;

reg [31:0] imm_1; // Immediate operands
reg [31:0] imm_2;
reg [31:0] imm_3;
reg [31:0] imm_4;
reg [31:0] imm_5;

reg [25:0] jmem_1; // Jump memory address
reg [25:0] jmem_2;
reg [25:0] jmem_3;
reg [25:0] jmem_4;
reg [25:0] jmem_5;

wire [31:0] out_mem_inst; // Instruction Memory output
wire [31:0] out_mem_data; // Data Memory output

mem_inst mem_i(.address(pc), .clock(clk[0]), .q(out_mem_inst));

mem_data mem_d(.address(aluOutput[9:0]), .clock(clk[0]), .data(registers[instruction[20:16]]), .wren(writeEnable), .q(out_mem_data));

	assign LEDG[0] = clk[1];

	always@(posedge CLOCK_50)
	begin
		clk = clk + 1;
	end

	always@(posedge clk[1])
	begin
		if(KEY[0] == 0)
		begin
			FSM_1 = 3'b001; // 1
			FSM2_1 = 16'h0000;
			FSM_2 = 3'b000; // 0
			FSM2_2 = 16'h0000;
			FSM_3 = 3'b111; // -1
			FSM2_3 = 16'h0000;
			FSM_4 = 3'b110; // -2
			FSM2_4 = 16'h0000;
			FSM_5 = 3'b101; // -3
			FSM2_5 = 16'h0000;

			aluOutput = 32'd0;
			aluOutput_1 = 32'd0;
			aluOutput_2 = 32'd0;
			aluOutput_3 = 32'd0;
			aluOutput_4 = 32'd0;
			aluOutput_5 = 32'd0;

			Zero = 1'b0;
			Zero_1 = 1'b0;
			Zero_2 = 1'b0;
			Zero_3 = 1'b0;
			Zero_4 = 1'b0;
			Zero_5 = 1'b0;

			pc = 10'd0;

			instruction = 32'd0;
			instruction_1 = 32'd0;
			instruction_2 = 32'd0;
			instruction_3 = 32'd0;
			instruction_4 = 32'd0;
			instruction_5 = 32'd0;

			for(i = 0; i < 32; i = i + 1)
			begin
				registers[i] = i;
			end

			KEY[0] = 1;
		end

		else
		begin
			if(FSM_1 == 3'b001) // Instruction fetch
			begin
				pc = pc + 1;
				instruction_1 = out_mem_inst;
			end

			if(FSM_2 == 3'b001) // Instruction fetch
			begin
				pc = pc + 1;
				instruction_2 = out_mem_inst;
			end

			if(FSM_3 == 3'b001) // Instruction fetch
			begin
				pc = pc + 1;
				instruction_3 = out_mem_inst;
			end

			if(FSM_4 == 3'b001) // Instruction fetch
			begin
				pc = pc + 1;
				instruction_4 = out_mem_inst;
			end

			if(FSM_5 == 3'b001) // Instruction fetch
			begin
				pc = pc + 1;
				instruction_5 = out_mem_inst;
			end

			if(FSM_1 == 3'b010) // Instruction decode
			begin
				// R-Type Instructions
				if(instruction_1[31:26] == 6'b000000 && instruction_1[5:0] == 6'b100000) // add instruction
				begin
					FSM2_1 = 16'h0001; // add
					A_1 = registers[instruction_1[25:21]];
					B_1 = registers[instruction_1[20:16]];
				end

				else if(instruction_1[31:26] == 6'b000000 && instruction_1[5:0] == 6'b100010) // sub instruction
				begin
					FSM2_1 = 16'h0002; // sub
					A_1 = registers[instruction_1[25:21]];
					B_1 = registers[instruction_1[20:16]];
				end

				else if(instruction_1[31:26] == 6'b000000 && instruction_1[5:0] == 6'b100100) // and instruction
				begin
					FSM2_1 = 16'h0003; // and
					A_1 = registers[instruction_1[25:21]];
					B_1 = registers[instruction_1[20:16]];

				end

				else if(instruction_1[31:26] == 6'b000000 && instruction_1[5:0] == 6'b100111) // nor instruction
				begin
					FSM2_1 = 16'h0004; // nor
					A_1 = registers[instruction_1[25:21]];
					B_1 = registers[instruction_1[20:16]];
				end

				else if(instruction_1[31:26] == 6'b000000 && instruction_1[5:0] == 6'b100110) // xor instruction
				begin
					FSM2_1 = 16'h0005; // xor
					A_1 = registers[instruction_1[25:21]];
					B_1 = registers[instruction_1[20:16]];
				end

				else if(instruction_1[31:26] == 6'b000000 && instruction_1[5:0] == 6'b101010) // slt instruction
				begin
					FSM2_1 = 16'h0006; // slt
					A_1 = registers[instruction_1[25:21]];
					B_1 = registers[instruction_1[20:16]];
				end

				else if(instruction_1[31:26] == 6'b000000 && instruction_1[5:0] == 6'b000000) // sll instruction
				begin
					FSM2_1 = 16'h0007; // sll
					A_1 = registers[instruction_1[25:21]];
					B_1 = registers[instruction_1[10:6]];
				end

				else if(instruction_1[31:26] == 6'b000000 && instruction_1[5:0] == 6'b000010) // srl instruction
				begin
					FSM2_1 = 16'h0008; // srl
					A_1 = registers[instruction_1[25:21]];
					B_1 = registers[instruction_1[10:6]];
				end

				else if(instruction_1[31:26] == 6'b000000 && instruction_1[5:0] == 6'b100101) // or instruction
				begin
					FSM2_1 = 16'h0009; // or
					A_1 = registers[instruction_1[25:21]];
					B_1 = registers[instruction_1[20:16]];

				end
				// End R-Type Instructions

				// I-Type Instructions
				else if(instruction_1[31:26] == 6'b001000) // addi instruction
				begin
					FSM2_1 = 16'h000A_1; // addi
					A_1 = registers[instruction_1[25:21]];
					imm_1[15:0] = instruction_1[15:0];
					imm_1[31:16] = instruction_1[15]; // Immediate signal extension
				end

				else if(instruction_1[31:26] == 6'b100011) // lw instruction
				begin
					FSM2_1 = 16'h000B_1; // lw
					A_1 = registers[instruction_1[25:21]];
					imm_1[15:0] = instruction_1[15:0];
					imm_1[31:16] = instruction_1[15]; // Immediate signal extension
				end

				else if(instruction_1[31:26] == 6'b101011) // sw instruction
				begin
					FSM2_1 = 16'h000C; // sw
					A_1 = registers[instruction_1[25:21]];
					imm_1[15:0] = instruction_1[15:0];
					imm_1[31:16] = instruction_1[15]; // Immediate signal extension
				end

				else if(instruction_1[31:26] == 6'b001100) // andi instruction
				begin
					FSM2_1 = 16'h000D; // andi
					A_1 = registers[instruction_1[25:21]];
					imm_1[15:0] = instruction_1[15:0];
					imm_1[31:16] = instruction_1[15]; // Immediate signal extension
				end

				else if(instruction_1[31:26] == 6'b001101) // ori instruction
				begin
					FSM2_1 = 16'h000E; // ori
					A_1 = registers[instruction_1[25:21]];
					imm_1[15:0] = instruction_1[15:0];
					imm_1[31:16] = instruction_1[15]; // Immediate signal extension
				end

				else if(instruction_1[31:26] == 6'b001010) // slti instruction
				begin
					FSM2_1 = 16'h000F; // slti
					A_1 = registers[instruction_1[25:21]];
					imm_1[15:0] = instruction_1[15:0];
					imm_1[31:16] = instruction_1[15]; // Immediate signal extension
				end

				else if(instruction_1[31:26] == 6'b000100) // beq instruction
				begin
					FSM2_1 = 16'h0010; // beq
					A_1 = registers[instruction_1[25:21]];
					B_1 = registers[instruction_1[20:16]];
					imm_1[15:0] = instruction_1[15:0];
					imm_1[31:16] = instruction_1[15]; // Immediate signal extension
				end

				else if(instruction_1[31:26] == 6'b000101) // bne instruction
				begin
					FSM2_1 = 16'h0011; // bne
					A_1 = registers[instruction_1[25:21]];
					B_1 = registers[instruction_1[20:16]];
					imm_1[15:0] = instruction_1[15:0];
					imm_1[31:16] = instruction_1[15]; // Immediate signal extension
				end
				// End I-Type Instructions

				// J-Type Instructions
				else if(instruction_1[31:26] == 6'b000010) // j
				begin
					FSM2_1 = 16'h0012; // j
					imm_1[25:0] = instruction_1[25:0];
				end
				// End J-Type Instructions
			end

			if(FSM_2 == 3'b010) // Instruction decode
			begin
				// R-Type Instructions
				if(instruction_2[31:26] == 6'b000000 && instruction_2[5:0] == 6'b100000) // add instruction
				begin
					FSM2_2 = 16'h0001; // add
					A_2 = registers[instruction_2[25:21]];
					B_2 = registers[instruction_2[20:16]];
				end

				else if(instruction_2[31:26] == 6'b000000 && instruction_2[5:0] == 6'b100010) // sub instruction
				begin
					FSM2_2 = 16'h0002; // sub
					A_2 = registers[instruction_2[25:21]];
					B_2 = registers[instruction_2[20:16]];
				end

				else if(instruction_2[31:26] == 6'b000000 && instruction_2[5:0] == 6'b100100) // and instruction
				begin
					FSM2_2 = 16'h0003; // and
					A_2 = registers[instruction_2[25:21]];
					B_2 = registers[instruction_2[20:16]];

				end

				else if(instruction_2[31:26] == 6'b000000 && instruction_2[5:0] == 6'b100111) // nor instruction
				begin
					FSM2_2 = 16'h0004; // nor
					A_2 = registers[instruction_2[25:21]];
					B_2 = registers[instruction_2[20:16]];
				end

				else if(instruction_2[31:26] == 6'b000000 && instruction_2[5:0] == 6'b100110) // xor instruction
				begin
					FSM2_2 = 16'h0005; // xor
					A_2 = registers[instruction_2[25:21]];
					B_2 = registers[instruction_2[20:16]];
				end

				else if(instruction_2[31:26] == 6'b000000 && instruction_2[5:0] == 6'b101010) // slt instruction
				begin
					FSM2_2 = 16'h0006; // slt
					A_2 = registers[instruction_2[25:21]];
					B_2 = registers[instruction_2[20:16]];
				end

				else if(instruction_2[31:26] == 6'b000000 && instruction_2[5:0] == 6'b000000) // sll instruction
				begin
					FSM2_2 = 16'h0007; // sll
					A_2 = registers[instruction_2[25:21]];
					B_2 = registers[instruction_2[10:6]];
				end

				else if(instruction_2[31:26] == 6'b000000 && instruction_2[5:0] == 6'b000010) // srl instruction
				begin
					FSM2_2 = 16'h0008; // srl
					A_2 = registers[instruction_2[25:21]];
					B_2 = registers[instruction_2[10:6]];
				end

				else if(instruction_2[31:26] == 6'b000000 && instruction_2[5:0] == 6'b100101) // or instruction
				begin
					FSM2_2 = 16'h0009; // or
					A_2 = registers[instruction_2[25:21]];
					B_2 = registers[instruction_2[20:16]];

				end
				// End R-Type Instructions

				// I-Type Instructions
				else if(instruction_2[31:26] == 6'b001000) // addi instruction
				begin
					FSM2_2 = 16'h000A_2; // addi
					A_2 = registers[instruction_2[25:21]];
					imm_2[15:0] = instruction_2[15:0];
					imm_2[31:16] = instruction_2[15]; // Immediate signal extension
				end

				else if(instruction_2[31:26] == 6'b100011) // lw instruction
				begin
					FSM2_2 = 16'h000B_2; // lw
					A_2 = registers[instruction_2[25:21]];
					imm_2[15:0] = instruction_2[15:0];
					imm_2[31:16] = instruction_2[15]; // Immediate signal extension
				end

				else if(instruction_2[31:26] == 6'b101011) // sw instruction
				begin
					FSM2_2 = 16'h000C; // sw
					A_2 = registers[instruction_2[25:21]];
					imm_2[15:0] = instruction_2[15:0];
					imm_2[31:16] = instruction_2[15]; // Immediate signal extension
				end

				else if(instruction_2[31:26] == 6'b001100) // andi instruction
				begin
					FSM2_2 = 16'h000D; // andi
					A_2 = registers[instruction_2[25:21]];
					imm_2[15:0] = instruction_2[15:0];
					imm_2[31:16] = instruction_2[15]; // Immediate signal extension
				end

				else if(instruction_2[31:26] == 6'b001101) // ori instruction
				begin
					FSM2_2 = 16'h000E; // ori
					A_2 = registers[instruction_2[25:21]];
					imm_2[15:0] = instruction_2[15:0];
					imm_2[31:16] = instruction_2[15]; // Immediate signal extension
				end

				else if(instruction_2[31:26] == 6'b001010) // slti instruction
				begin
					FSM2_2 = 16'h000F; // slti
					A_2 = registers[instruction_2[25:21]];
					imm_2[15:0] = instruction_2[15:0];
					imm_2[31:16] = instruction_2[15]; // Immediate signal extension
				end

				else if(instruction_2[31:26] == 6'b000100) // beq instruction
				begin
					FSM2_2 = 16'h0010; // beq
					A_2 = registers[instruction_2[25:21]];
					B_2 = registers[instruction_2[20:16]];
					imm_2[15:0] = instruction_2[15:0];
					imm_2[31:16] = instruction_2[15]; // Immediate signal extension
				end

				else if(instruction_2[31:26] == 6'b000101) // bne instruction
				begin
					FSM2_2 = 16'h0011; // bne
					A_2 = registers[instruction_2[25:21]];
					B_2 = registers[instruction_2[20:16]];
					imm_2[15:0] = instruction_2[15:0];
					imm_2[31:16] = instruction_2[15]; // Immediate signal extension
				end
				// End I-Type Instructions

				// J-Type Instructions
				else if(instruction_2[31:26] == 6'b000010) // j
				begin
					FSM2_2 = 16'h0012; // j
					imm_2[25:0] = instruction_2[25:0];
				end
				// End J-Type Instructions
			end

			if(FSM_3 == 3'b010) // Instruction decode
			begin
				// R-Type Instructions
				if(instruction_3[31:26] == 6'b000000 && instruction_3[5:0] == 6'b100000) // add instruction
				begin
					FSM2_3 = 16'h0001; // add
					A_3 = registers[instruction_3[25:21]];
					B_3 = registers[instruction_3[20:16]];
				end

				else if(instruction_3[31:26] == 6'b000000 && instruction_3[5:0] == 6'b100010) // sub instruction
				begin
					FSM2_3 = 16'h0002; // sub
					A_3 = registers[instruction_3[25:21]];
					B_3 = registers[instruction_3[20:16]];
				end

				else if(instruction_3[31:26] == 6'b000000 && instruction_3[5:0] == 6'b100100) // and instruction
				begin
					FSM2_3 = 16'h0003; // and
					A_3 = registers[instruction_3[25:21]];
					B_3 = registers[instruction_3[20:16]];

				end

				else if(instruction_3[31:26] == 6'b000000 && instruction_3[5:0] == 6'b100111) // nor instruction
				begin
					FSM2_3 = 16'h0004; // nor
					A_3 = registers[instruction_3[25:21]];
					B_3 = registers[instruction_3[20:16]];
				end

				else if(instruction_3[31:26] == 6'b000000 && instruction_3[5:0] == 6'b100110) // xor instruction
				begin
					FSM2_3 = 16'h0005; // xor
					A_3 = registers[instruction_3[25:21]];
					B_3 = registers[instruction_3[20:16]];
				end

				else if(instruction_3[31:26] == 6'b000000 && instruction_3[5:0] == 6'b101010) // slt instruction
				begin
					FSM2_3 = 16'h0006; // slt
					A_3 = registers[instruction_3[25:21]];
					B_3 = registers[instruction_3[20:16]];
				end

				else if(instruction_3[31:26] == 6'b000000 && instruction_3[5:0] == 6'b000000) // sll instruction
				begin
					FSM2_3 = 16'h0007; // sll
					A_3 = registers[instruction_3[25:21]];
					B_3 = registers[instruction_3[10:6]];
				end

				else if(instruction_3[31:26] == 6'b000000 && instruction_3[5:0] == 6'b000010) // srl instruction
				begin
					FSM2_3 = 16'h0008; // srl
					A_3 = registers[instruction_3[25:21]];
					B_3 = registers[instruction_3[10:6]];
				end

				else if(instruction_3[31:26] == 6'b000000 && instruction_3[5:0] == 6'b100101) // or instruction
				begin
					FSM2_3 = 16'h0009; // or
					A_3 = registers[instruction_3[25:21]];
					B_3 = registers[instruction_3[20:16]];

				end
				// End R-Type Instructions

				// I-Type Instructions
				else if(instruction_3[31:26] == 6'b001000) // addi instruction
				begin
					FSM2_3 = 16'h000A_3; // addi
					A_3 = registers[instruction_3[25:21]];
					imm_3[15:0] = instruction_3[15:0];
					imm_3[31:16] = instruction_3[15]; // Immediate signal extension
				end

				else if(instruction_3[31:26] == 6'b100011) // lw instruction
				begin
					FSM2_3 = 16'h000B_3; // lw
					A_3 = registers[instruction_3[25:21]];
					imm_3[15:0] = instruction_3[15:0];
					imm_3[31:16] = instruction_3[15]; // Immediate signal extension
				end

				else if(instruction_3[31:26] == 6'b101011) // sw instruction
				begin
					FSM2_3 = 16'h000C; // sw
					A_3 = registers[instruction_3[25:21]];
					imm_3[15:0] = instruction_3[15:0];
					imm_3[31:16] = instruction_3[15]; // Immediate signal extension
				end

				else if(instruction_3[31:26] == 6'b001100) // andi instruction
				begin
					FSM2_3 = 16'h000D; // andi
					A_3 = registers[instruction_3[25:21]];
					imm_3[15:0] = instruction_3[15:0];
					imm_3[31:16] = instruction_3[15]; // Immediate signal extension
				end

				else if(instruction_3[31:26] == 6'b001101) // ori instruction
				begin
					FSM2_3 = 16'h000E; // ori
					A_3 = registers[instruction_3[25:21]];
					imm_3[15:0] = instruction_3[15:0];
					imm_3[31:16] = instruction_3[15]; // Immediate signal extension
				end

				else if(instruction_3[31:26] == 6'b001010) // slti instruction
				begin
					FSM2_3 = 16'h000F; // slti
					A_3 = registers[instruction_3[25:21]];
					imm_3[15:0] = instruction_3[15:0];
					imm_3[31:16] = instruction_3[15]; // Immediate signal extension
				end

				else if(instruction_3[31:26] == 6'b000100) // beq instruction
				begin
					FSM2_3 = 16'h0010; // beq
					A_3 = registers[instruction_3[25:21]];
					B_3 = registers[instruction_3[20:16]];
					imm_3[15:0] = instruction_3[15:0];
					imm_3[31:16] = instruction_3[15]; // Immediate signal extension
				end

				else if(instruction_3[31:26] == 6'b000101) // bne instruction
				begin
					FSM2_3 = 16'h0011; // bne
					A_3 = registers[instruction_3[25:21]];
					B_3 = registers[instruction_3[20:16]];
					imm_3[15:0] = instruction_3[15:0];
					imm_3[31:16] = instruction_3[15]; // Immediate signal extension
				end
				// End I-Type Instructions

				// J-Type Instructions
				else if(instruction_3[31:26] == 6'b000010) // j
				begin
					FSM2_3 = 16'h0012; // j
					imm_3[25:0] = instruction_3[25:0];
				end
				// End J-Type Instructions
			end

			if(FSM_4 == 3'b010) // Instruction decode
			begin
				// R-Type Instructions
				if(instruction_4[31:26] == 6'b000000 && instruction_4[5:0] == 6'b100000) // add instruction
				begin
					FSM2_4 = 16'h0001; // add
					A_4 = registers[instruction_4[25:21]];
					B_4 = registers[instruction_4[20:16]];
				end

				else if(instruction_4[31:26] == 6'b000000 && instruction_4[5:0] == 6'b100010) // sub instruction
				begin
					FSM2_4 = 16'h0002; // sub
					A_4 = registers[instruction_4[25:21]];
					B_4 = registers[instruction_4[20:16]];
				end

				else if(instruction_4[31:26] == 6'b000000 && instruction_4[5:0] == 6'b100100) // and instruction
				begin
					FSM2_4 = 16'h0003; // and
					A_4 = registers[instruction_4[25:21]];
					B_4 = registers[instruction_4[20:16]];

				end

				else if(instruction_4[31:26] == 6'b000000 && instruction_4[5:0] == 6'b100111) // nor instruction
				begin
					FSM2_4 = 16'h0004; // nor
					A_4 = registers[instruction_4[25:21]];
					B_4 = registers[instruction_4[20:16]];
				end

				else if(instruction_4[31:26] == 6'b000000 && instruction_4[5:0] == 6'b100110) // xor instruction
				begin
					FSM2_4 = 16'h0005; // xor
					A_4 = registers[instruction_4[25:21]];
					B_4 = registers[instruction_4[20:16]];
				end

				else if(instruction_4[31:26] == 6'b000000 && instruction_4[5:0] == 6'b101010) // slt instruction
				begin
					FSM2_4 = 16'h0006; // slt
					A_4 = registers[instruction_4[25:21]];
					B_4 = registers[instruction_4[20:16]];
				end

				else if(instruction_4[31:26] == 6'b000000 && instruction_4[5:0] == 6'b000000) // sll instruction
				begin
					FSM2_4 = 16'h0007; // sll
					A_4 = registers[instruction_4[25:21]];
					B_4 = registers[instruction_4[10:6]];
				end

				else if(instruction_4[31:26] == 6'b000000 && instruction_4[5:0] == 6'b000010) // srl instruction
				begin
					FSM2_4 = 16'h0008; // srl
					A_4 = registers[instruction_4[25:21]];
					B_4 = registers[instruction_4[10:6]];
				end

				else if(instruction_4[31:26] == 6'b000000 && instruction_4[5:0] == 6'b100101) // or instruction
				begin
					FSM2_4 = 16'h0009; // or
					A_4 = registers[instruction_4[25:21]];
					B_4 = registers[instruction_4[20:16]];

				end
				// End R-Type Instructions

				// I-Type Instructions
				else if(instruction_4[31:26] == 6'b001000) // addi instruction
				begin
					FSM2_4 = 16'h000A_4; // addi
					A_4 = registers[instruction_4[25:21]];
					imm_4[15:0] = instruction_4[15:0];
					imm_4[31:16] = instruction_4[15]; // Immediate signal extension
				end

				else if(instruction_4[31:26] == 6'b100011) // lw instruction
				begin
					FSM2_4 = 16'h000B_4; // lw
					A_4 = registers[instruction_4[25:21]];
					imm_4[15:0] = instruction_4[15:0];
					imm_4[31:16] = instruction_4[15]; // Immediate signal extension
				end

				else if(instruction_4[31:26] == 6'b101011) // sw instruction
				begin
					FSM2_4 = 16'h000C; // sw
					A_4 = registers[instruction_4[25:21]];
					imm_4[15:0] = instruction_4[15:0];
					imm_4[31:16] = instruction_4[15]; // Immediate signal extension
				end

				else if(instruction_4[31:26] == 6'b001100) // andi instruction
				begin
					FSM2_4 = 16'h000D; // andi
					A_4 = registers[instruction_4[25:21]];
					imm_4[15:0] = instruction_4[15:0];
					imm_4[31:16] = instruction_4[15]; // Immediate signal extension
				end

				else if(instruction_4[31:26] == 6'b001101) // ori instruction
				begin
					FSM2_4 = 16'h000E; // ori
					A_4 = registers[instruction_4[25:21]];
					imm_4[15:0] = instruction_4[15:0];
					imm_4[31:16] = instruction_4[15]; // Immediate signal extension
				end

				else if(instruction_4[31:26] == 6'b001010) // slti instruction
				begin
					FSM2_4 = 16'h000F; // slti
					A_4 = registers[instruction_4[25:21]];
					imm_4[15:0] = instruction_4[15:0];
					imm_4[31:16] = instruction_4[15]; // Immediate signal extension
				end

				else if(instruction_4[31:26] == 6'b000100) // beq instruction
				begin
					FSM2_4 = 16'h0010; // beq
					A_4 = registers[instruction_4[25:21]];
					B_4 = registers[instruction_4[20:16]];
					imm_4[15:0] = instruction_4[15:0];
					imm_4[31:16] = instruction_4[15]; // Immediate signal extension
				end

				else if(instruction_4[31:26] == 6'b000101) // bne instruction
				begin
					FSM2_4 = 16'h0011; // bne
					A_4 = registers[instruction_4[25:21]];
					B_4 = registers[instruction_4[20:16]];
					imm_4[15:0] = instruction_4[15:0];
					imm_4[31:16] = instruction_4[15]; // Immediate signal extension
				end
				// End I-Type Instructions

				// J-Type Instructions
				else if(instruction_4[31:26] == 6'b000010) // j
				begin
					FSM2_4 = 16'h0012; // j
					imm_4[25:0] = instruction_4[25:0];
				end
				// End J-Type Instructions
			end

			if(FSM_5 == 3'b010) // Instruction decode
			begin
				// R-Type Instructions
				if(instruction_5[31:26] == 6'b000000 && instruction_5[5:0] == 6'b100000) // add instruction
				begin
					FSM2_5 = 16'h0001; // add
					A_5 = registers[instruction_5[25:21]];
					B_5 = registers[instruction_5[20:16]];
				end

				else if(instruction_5[31:26] == 6'b000000 && instruction_5[5:0] == 6'b100010) // sub instruction
				begin
					FSM2_5 = 16'h0002; // sub
					A_5 = registers[instruction_5[25:21]];
					B_5 = registers[instruction_5[20:16]];
				end

				else if(instruction_5[31:26] == 6'b000000 && instruction_5[5:0] == 6'b100100) // and instruction
				begin
					FSM2_5 = 16'h0003; // and
					A_5 = registers[instruction_5[25:21]];
					B_5 = registers[instruction_5[20:16]];

				end

				else if(instruction_5[31:26] == 6'b000000 && instruction_5[5:0] == 6'b100111) // nor instruction
				begin
					FSM2_5 = 16'h0004; // nor
					A_5 = registers[instruction_5[25:21]];
					B_5 = registers[instruction_5[20:16]];
				end

				else if(instruction_5[31:26] == 6'b000000 && instruction_5[5:0] == 6'b100110) // xor instruction
				begin
					FSM2_5 = 16'h0005; // xor
					A_5 = registers[instruction_5[25:21]];
					B_5 = registers[instruction_5[20:16]];
				end

				else if(instruction_5[31:26] == 6'b000000 && instruction_5[5:0] == 6'b101010) // slt instruction
				begin
					FSM2_5 = 16'h0006; // slt
					A_5 = registers[instruction_5[25:21]];
					B_5 = registers[instruction_5[20:16]];
				end

				else if(instruction_5[31:26] == 6'b000000 && instruction_5[5:0] == 6'b000000) // sll instruction
				begin
					FSM2_5 = 16'h0007; // sll
					A_5 = registers[instruction_5[25:21]];
					B_5 = registers[instruction_5[10:6]];
				end

				else if(instruction_5[31:26] == 6'b000000 && instruction_5[5:0] == 6'b000010) // srl instruction
				begin
					FSM2_5 = 16'h0008; // srl
					A_5 = registers[instruction_5[25:21]];
					B_5 = registers[instruction_5[10:6]];
				end

				else if(instruction_5[31:26] == 6'b000000 && instruction_5[5:0] == 6'b100101) // or instruction
				begin
					FSM2_5 = 16'h0009; // or
					A_5 = registers[instruction_5[25:21]];
					B_5 = registers[instruction_5[20:16]];

				end
				// End R-Type Instructions

				// I-Type Instructions
				else if(instruction_5[31:26] == 6'b001000) // addi instruction
				begin
					FSM2_5 = 16'h000A_5; // addi
					A_5 = registers[instruction_5[25:21]];
					imm_5[15:0] = instruction_5[15:0];
					imm_5[31:16] = instruction_5[15]; // Immediate signal extension
				end

				else if(instruction_5[31:26] == 6'b100011) // lw instruction
				begin
					FSM2_5 = 16'h000B_5; // lw
					A_5 = registers[instruction_5[25:21]];
					imm_5[15:0] = instruction_5[15:0];
					imm_5[31:16] = instruction_5[15]; // Immediate signal extension
				end

				else if(instruction_5[31:26] == 6'b101011) // sw instruction
				begin
					FSM2_5 = 16'h000C; // sw
					A_5 = registers[instruction_5[25:21]];
					imm_5[15:0] = instruction_5[15:0];
					imm_5[31:16] = instruction_5[15]; // Immediate signal extension
				end

				else if(instruction_5[31:26] == 6'b001100) // andi instruction
				begin
					FSM2_5 = 16'h000D; // andi
					A_5 = registers[instruction_5[25:21]];
					imm_5[15:0] = instruction_5[15:0];
					imm_5[31:16] = instruction_5[15]; // Immediate signal extension
				end

				else if(instruction_5[31:26] == 6'b001101) // ori instruction
				begin
					FSM2_5 = 16'h000E; // ori
					A_5 = registers[instruction_5[25:21]];
					imm_5[15:0] = instruction_5[15:0];
					imm_5[31:16] = instruction_5[15]; // Immediate signal extension
				end

				else if(instruction_5[31:26] == 6'b001010) // slti instruction
				begin
					FSM2_5 = 16'h000F; // slti
					A_5 = registers[instruction_5[25:21]];
					imm_5[15:0] = instruction_5[15:0];
					imm_5[31:16] = instruction_5[15]; // Immediate signal extension
				end

				else if(instruction_5[31:26] == 6'b000100) // beq instruction
				begin
					FSM2_5 = 16'h0010; // beq
					A_5 = registers[instruction_5[25:21]];
					B_5 = registers[instruction_5[20:16]];
					imm_5[15:0] = instruction_5[15:0];
					imm_5[31:16] = instruction_5[15]; // Immediate signal extension
				end

				else if(instruction_5[31:26] == 6'b000101) // bne instruction
				begin
					FSM2_5 = 16'h0011; // bne
					A_5 = registers[instruction_5[25:21]];
					B_5 = registers[instruction_5[20:16]];
					imm_5[15:0] = instruction_5[15:0];
					imm_5[31:16] = instruction_5[15]; // Immediate signal extension
				end
				// End I-Type Instructions

				// J-Type Instructions
				else if(instruction_5[31:26] == 6'b000010) // j
				begin
					FSM2_5 = 16'h0012; // j
					imm_5[25:0] = instruction_5[25:0];
				end
				// End J-Type Instructions
			end

			else if(FSM_1 == 3'b011) // Execute
			begin
				if(FSM2_1 == 16'h0001)// execute add
				begin
					aluOutput_1 = A_1 + B_1;
				end

				else if(FSM2_1 == 16'h0002)// execute sub
				begin
					aluOutput_1 = A_1 - B_1;
				end

				else if(FSM2_1 == 16'h0003)// execute and
				begin
					aluOutput_1 = A_1 & B_1;
				end

				else if(FSM2_1 == 16'h0004)// execute nor
				begin
					aluOutput_1 = ~(A_1 | B_1);
				end

				else if(FSM2_1 == 16'h0005)// execute xor
				begin
					aluOutput_1 = A_1 ^ B_1;
				end

				else if(FSM2_1 == 16'h0006)// execute slt
				begin
					if(A_1 < B_1)
					begin
						aluOutput_1 = 32'd1;
					end

					else
					begin
						aluOutput_1 = 32'd0;
					end
				end

				else if(FSM2_1 == 16'h0007)// execute sll
				begin
					aluOutput_1 = A_1 << B_1;
				end

				else if(FSM2_1 == 16'h0008)// execute srl
				begin
					aluOutput_1 = A_1 >> B_1;
				end

				else if(FSM2_1 == 16'h0009)// execute or
				begin
					aluOutput_1 = A_1 | B_1;
				end

				else if(FSM2_1 == 16'h000A_1)// execute addi
				begin
					aluOutput_1 = A_1 + imm_1;
				end

				else if(FSM2_1 == 16'h000B_1)// execute lw
				begin
					aluOutput_1 = A_1 + imm_1;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_1[i] = aluOutput_1[15];
					end
				end

				else if(FSM2_1 == 16'h000C)// execute sw
				begin
					aluOutput_1 = A_1 + imm_1;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_1[i] = aluOutput_1[15];
					end
				end

				else if(FSM2_1 == 16'h000D)// execute andi
				begin
					aluOutput_1 = A_1 & imm_1;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_1[i] = aluOutput_1[15];
					end
				end

				else if(FSM2_1 == 16'h000E)// execute ori
				begin
					aluOutput_1 = A_1 | imm_1;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_1[i] = aluOutput_1[15];
					end
				end

				else if(FSM2_1 == 16'h000F)// execute slti
				begin
					if(A_1 < imm_1)
					begin
						aluOutput_1 = 32'd1;
					end

					else
					begin
						aluOutput_1 = 32'd0;
					end
				end

				else if(FSM2_1 == 16'h0010)// execute beq
				begin
					if(A_1 >= B_1)
					begin
						aluOutput_1 = A_1 - B_1;
					end

					else
					begin
						aluOutput_1 = B_1 - A_1;
					end

					if(aluOutput_1 == 32'd0)
					begin
						Zero_1 = 1'b1;
						aluOutput_1[31:10] = 22'd0;
						aluOutput_1[9:0] = pc + imm_1;
					end

					else
					begin
						Zero_1 = 1'b0;
					end

					Zero = Zero_1;
				end

				else if(FSM2_1 == 16'h0011)// execute bne
				begin
					if(A_1 >= B_1)
					begin
						aluOutput_1 = A_1 - B_1;
					end

					else
					begin
						aluOutput_1 = B_1 - A_1;
					end

					if(aluOutput_1 != 32'd0)
					begin
						Zero_1 = 1'b0;
						aluOutput_1[31:10] = 22'd0;
						aluOutput_1[9:0] = pc + imm_1;
					end

					else
					begin
						Zero_1 = 1'b1;
					end

					Zero = Zero_1;
				end

				else if(FSM2_1 == 16'h0012)// execute j
				begin
					aluOutput_1[25:0] = imm_1[25:0];
					aluOutput_1[31:26] = pc[9:4];
				end
				
				aluOutput = aluOutput_1;
				instruction = instruction_1;
			end

			else if(FSM_2 == 3'b011) // Execute
			begin
				if(FSM2_2 == 16'h0001)// execute add
				begin
					aluOutput_2 = A_2 + B_2;
				end

				else if(FSM2_2 == 16'h0002)// execute sub
				begin
					aluOutput_2 = A_2 - B_2;
				end

				else if(FSM2_2 == 16'h0003)// execute and
				begin
					aluOutput_2 = A_2 & B_2;
				end

				else if(FSM2_2 == 16'h0004)// execute nor
				begin
					aluOutput_2 = ~(A_2 | B_2);
				end

				else if(FSM2_2 == 16'h0005)// execute xor
				begin
					aluOutput_2 = A_2 ^ B_2;
				end

				else if(FSM2_2 == 16'h0006)// execute slt
				begin
					if(A_2 < B_2)
					begin
						aluOutput_2 = 32'd1;
					end

					else
					begin
						aluOutput_2 = 32'd0;
					end
				end

				else if(FSM2_2 == 16'h0007)// execute sll
				begin
					aluOutput_2 = A_2 << B_2;
				end

				else if(FSM2_2 == 16'h0008)// execute srl
				begin
					aluOutput_2 = A_2 >> B_2;
				end

				else if(FSM2_2 == 16'h0009)// execute or
				begin
					aluOutput_2 = A_2 | B_2;
				end

				else if(FSM2_2 == 16'h000A_2)// execute addi
				begin
					aluOutput_2 = A_2 + imm_2;
				end

				else if(FSM2_2 == 16'h000B_2)// execute lw
				begin
					aluOutput_2 = A_2 + imm_2;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_2[i] = aluOutput_2[15];
					end
				end

				else if(FSM2_2 == 16'h000C)// execute sw
				begin
					aluOutput_2 = A_2 + imm_2;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_2[i] = aluOutput_2[15];
					end
				end

				else if(FSM2_2 == 16'h000D)// execute andi
				begin
					aluOutput_2 = A_2 & imm_2;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_2[i] = aluOutput_2[15];
					end
				end

				else if(FSM2_2 == 16'h000E)// execute ori
				begin
					aluOutput_2 = A_2 | imm_2;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_2[i] = aluOutput_2[15];
					end
				end

				else if(FSM2_2 == 16'h000F)// execute slti
				begin
					if(A_2 < imm_2)
					begin
						aluOutput_2 = 32'd1;
					end

					else
					begin
						aluOutput_2 = 32'd0;
					end
				end

				else if(FSM2_2 == 16'h0010)// execute beq
				begin
					if(A_2 >= B_2)
					begin
						aluOutput_2 = A_2 - B_2;
					end

					else
					begin
						aluOutput_2 = B_2 - A_2;
					end

					if(aluOutput_2 == 32'd0)
					begin
						Zero_2 = 1'b1;
						aluOutput_2[31:10] = 22'd0;
						aluOutput_2[9:0] = pc + imm_2;
					end

					else
					begin
						Zero_2 = 1'b0;
					end

					Zero = Zero_2;
				end

				else if(FSM2_2 == 16'h0011)// execute bne
				begin
					if(A_2 >= B_2)
					begin
						aluOutput_2 = A_2 - B_2;
					end

					else
					begin
						aluOutput_2 = B_2 - A_2;
					end

					if(aluOutput_2 != 32'd0)
					begin
						Zero_2 = 1'b0;
						aluOutput_2[31:10] = 22'd0;
						aluOutput_2[9:0] = pc + imm_2;
					end

					else
					begin
						Zero_2 = 1'b1;
					end

					Zero = Zero_2;
				end

				else if(FSM2_2 == 16'h0012)// execute j
				begin
						aluOutput_2[25:0] = imm_2[25:0];
						aluOutput_2[31:26] = pc[9:4];
				end
				
				aluOutput = aluOutput_2;
				instruction = instruction_2;
			end

			else if(FSM_3 == 3'b011) // Execute
			begin
				if(FSM2_3 == 16'h0001)// execute add
				begin
					aluOutput_3 = A_3 + B_3;
				end

				else if(FSM2_3 == 16'h0002)// execute sub
				begin
					aluOutput_3 = A_3 - B_3;
				end

				else if(FSM2_3 == 16'h0003)// execute and
				begin
					aluOutput_3 = A_3 & B_3;
				end

				else if(FSM2_3 == 16'h0004)// execute nor
				begin
					aluOutput_3 = ~(A_3 | B_3);
				end

				else if(FSM2_3 == 16'h0005)// execute xor
				begin
					aluOutput_3 = A_3 ^ B_3;
				end

				else if(FSM2_3 == 16'h0006)// execute slt
				begin
					if(A_3 < B_3)
					begin
						aluOutput_3 = 32'd1;
					end

					else
					begin
						aluOutput_3 = 32'd0;
					end
				end

				else if(FSM2_3 == 16'h0007)// execute sll
				begin
					aluOutput_3 = A_3 << B_3;
				end

				else if(FSM2_3 == 16'h0008)// execute srl
				begin
					aluOutput_3 = A_3 >> B_3;
				end

				else if(FSM2_3 == 16'h0009)// execute or
				begin
					aluOutput_3 = A_3 | B_3;
				end

				else if(FSM2_3 == 16'h000A_3)// execute addi
				begin
					aluOutput_3 = A_3 + imm_3;
				end

				else if(FSM2_3 == 16'h000B_3)// execute lw
				begin
					aluOutput_3 = A_3 + imm_3;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_3[i] = aluOutput_3[15];
					end
				end

				else if(FSM2_3 == 16'h000C)// execute sw
				begin
					aluOutput_3 = A_3 + imm_3;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_3[i] = aluOutput_3[15];
					end
				end

				else if(FSM2_3 == 16'h000D)// execute andi
				begin
					aluOutput_3 = A_3 & imm_3;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_3[i] = aluOutput_3[15];
					end
				end

				else if(FSM2_3 == 16'h000E)// execute ori
				begin
					aluOutput_3 = A_3 | imm_3;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_3[i] = aluOutput_3[15];
					end
				end

				else if(FSM2_3 == 16'h000F)// execute slti
				begin
					if(A_3 < imm_3)
					begin
						aluOutput_3 = 32'd1;
					end

					else
					begin
						aluOutput_3 = 32'd0;
					end
				end

				else if(FSM2_3 == 16'h0010)// execute beq
				begin
					if(A_3 >= B_3)
					begin
						aluOutput_3 = A_3 - B_3;
					end

					else
					begin
						aluOutput_3 = B_3 - A_3;
					end

					if(aluOutput_3 == 32'd0)
					begin
						Zero_3 = 1'b1;
						aluOutput_3[31:10] = 22'd0;
						aluOutput_3[9:0] = pc + imm_3;
					end

					else
					begin
						Zero_3 = 1'b0;
					end

					Zero = Zero_3;
				end

				else if(FSM2_3 == 16'h0011)// execute bne
				begin
					if(A_3 >= B_3)
					begin
						aluOutput_3 = A_3 - B_3;
					end

					else
					begin
						aluOutput_3 = B_3 - A_3;
					end

					if(aluOutput_3 != 32'd0)
					begin
						Zero_3 = 1'b0;
						aluOutput_3[31:10] = 22'd0;
						aluOutput_3[9:0] = pc + imm_3;
					end

					else
					begin
						Zero_3 = 1'b1;
					end

					Zero = Zero_3;
				end

				else if(FSM2_3 == 16'h0012)// execute j
				begin
					aluOutput_3[25:0] = imm_3[25:0];
					aluOutput_3[31:26] = pc[9:4];
				end
				
				aluOutput = aluOutput_3;
				instruction = instruction_3;
			end

			else if(FSM_4 == 3'b011) // Execute
			begin
				if(FSM2_4 == 16'h0001)// execute add
				begin
					aluOutput_4 = A_4 + B_4;
				end

				else if(FSM2_4 == 16'h0002)// execute sub
				begin
					aluOutput_4 = A_4 - B_4;
				end

				else if(FSM2_4 == 16'h0003)// execute and
				begin
					aluOutput_4 = A_4 & B_4;
				end

				else if(FSM2_4 == 16'h0004)// execute nor
				begin
					aluOutput_4 = ~(A_4 | B_4);
				end

				else if(FSM2_4 == 16'h0005)// execute xor
				begin
					aluOutput_4 = A_4 ^ B_4;
				end

				else if(FSM2_4 == 16'h0006)// execute slt
				begin
					if(A_4 < B_4)
					begin
						aluOutput_4 = 32'd1;
					end

					else
					begin
						aluOutput_4 = 32'd0;
					end
				end

				else if(FSM2_4 == 16'h0007)// execute sll
				begin
					aluOutput_4 = A_4 << B_4;
				end

				else if(FSM2_4 == 16'h0008)// execute srl
				begin
					aluOutput_4 = A_4 >> B_4;
				end

				else if(FSM2_4 == 16'h0009)// execute or
				begin
					aluOutput_4 = A_4 | B_4;
				end

				else if(FSM2_4 == 16'h000A_4)// execute addi
				begin
					aluOutput_4 = A_4 + imm_4;
				end

				else if(FSM2_4 == 16'h000B_4)// execute lw
				begin
					aluOutput_4 = A_4 + imm_4;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_4[i] = aluOutput_4[15];
					end
				end

				else if(FSM2_4 == 16'h000C)// execute sw
				begin
					aluOutput_4 = A_4 + imm_4;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_4[i] = aluOutput_4[15];
					end
				end

				else if(FSM2_4 == 16'h000D)// execute andi
				begin
					aluOutput_4 = A_4 & imm_4;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_4[i] = aluOutput_4[15];
					end
				end

				else if(FSM2_4 == 16'h000E)// execute ori
				begin
					aluOutput_4 = A_4 | imm_4;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_4[i] = aluOutput_4[15];
					end
				end

				else if(FSM2_4 == 16'h000F)// execute slti
				begin
					if(A_4 < imm_4)
					begin
						aluOutput_4 = 32'd1;
					end

					else
					begin
						aluOutput_4 = 32'd0;
					end
				end

				else if(FSM2_4 == 16'h0010)// execute beq
				begin
					if(A_4 >= B_4)
					begin
						aluOutput_4 = A_4 - B_4;
					end

					else
					begin
						aluOutput_4 = B_4 - A_4;
					end

					if(aluOutput_4 == 32'd0)
					begin
						Zero_4 = 1'b1;
						aluOutput_4[31:10] = 22'd0;
						aluOutput_4[9:0] = pc + imm_4;
					end

					else
					begin
						Zero_4 = 1'b0;
					end

					Zero = Zero_4;
				end

				else if(FSM2_4 == 16'h0011)// execute bne
				begin
					if(A_4 >= B_4)
					begin
						aluOutput_4 = A_4 - B_4;
					end

					else
					begin
						aluOutput_4 = B_4 - A_4;
					end

					if(aluOutput_4 != 32'd0)
					begin
						Zero_4 = 1'b0;
						aluOutput_4[31:10] = 22'd0;
						aluOutput_4[9:0] = pc + imm_4;
					end

					else
					begin
						Zero_4 = 1'b1;
					end

					Zero = Zero_4;
				end

				else if(FSM2_4 == 16'h0012)// execute j
				begin
					aluOutput_4[25:0] = imm_4[25:0];
					aluOutput_4[31:26] = pc[9:4];
				end
				
				aluOutput = aluOutput_4;
				instruction = instruction_4;
			end

			else if(FSM_5 == 3'b011) // Execute
			begin
				if(FSM2_5 == 16'h0001)// execute add
				begin
					aluOutput_5 = A_5 + B_5;
				end

				else if(FSM2_5 == 16'h0002)// execute sub
				begin
					aluOutput_5 = A_5 - B_5;
				end

				else if(FSM2_5 == 16'h0003)// execute and
				begin
					aluOutput_5 = A_5 & B_5;
				end

				else if(FSM2_5 == 16'h0004)// execute nor
				begin
					aluOutput_5 = ~(A_5 | B_5);
				end

				else if(FSM2_5 == 16'h0005)// execute xor
				begin
					aluOutput_5 = A_5 ^ B_5;
				end

				else if(FSM2_5 == 16'h0006)// execute slt
				begin
					if(A_5 < B_5)
					begin
						aluOutput_5 = 32'd1;
					end

					else
					begin
						aluOutput_5 = 32'd0;
					end
				end

				else if(FSM2_5 == 16'h0007)// execute sll
				begin
					aluOutput_5 = A_5 << B_5;
				end

				else if(FSM2_5 == 16'h0008)// execute srl
				begin
					aluOutput_5 = A_5 >> B_5;
				end

				else if(FSM2_5 == 16'h0009)// execute or
				begin
					aluOutput_5 = A_5 | B_5;
				end

				else if(FSM2_5 == 16'h000A_5)// execute addi
				begin
					aluOutput_5 = A_5 + imm_5;
				end

				else if(FSM2_5 == 16'h000B_5)// execute lw
				begin
					aluOutput_5 = A_5 + imm_5;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_5[i] = aluOutput_5[15];
					end
				end

				else if(FSM2_5 == 16'h000C)// execute sw
				begin
					aluOutput_5 = A_5 + imm_5;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_5[i] = aluOutput_5[15];
					end
				end

				else if(FSM2_5 == 16'h000D)// execute andi
				begin
					aluOutput_5 = A_5 & imm_5;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_5[i] = aluOutput_5[15];
					end
				end

				else if(FSM2_5 == 16'h000E)// execute ori
				begin
					aluOutput_5 = A_5 | imm_5;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput_5[i] = aluOutput_5[15];
					end
				end

				else if(FSM2_5 == 16'h000F)// execute slti
				begin
					if(A_5 < imm_5)
					begin
						aluOutput_5 = 32'd1;
					end

					else
					begin
						aluOutput_5 = 32'd0;
					end
				end

				else if(FSM2_5 == 16'h0010)// execute beq
				begin
					if(A_5 >= B_5)
					begin
						aluOutput_5 = A_5 - B_5;
					end

					else
					begin
						aluOutput_5 = B_5 - A_5;
					end

					if(aluOutput_5 == 32'd0)
					begin
						Zero_5 = 1'b1;
						aluOutput_5[31:10] = 22'd0;
						aluOutput_5[9:0] = pc + imm_5;
					end

					else
					begin
						Zero_5 = 1'b0;
					end

					Zero = Zero_5;
				end

				else if(FSM2_5 == 16'h0011)// execute bne
				begin
					if(A_5 >= B_5)
					begin
						aluOutput_5 = A_5 - B_5;
					end

					else
					begin
						aluOutput_5 = B_5 - A_5;
					end

					if(aluOutput_5 != 32'd0)
					begin
						Zero_5 = 1'b0;
						aluOutput_5[31:10] = 22'd0;
						aluOutput_5[9:0] = pc + imm_5;
					end

					else
					begin
						Zero_5 = 1'b1;
					end

					Zero = Zero_5;
				end

				else if(FSM2_5 == 16'h0012)// execute j
				begin
					aluOutput_5[25:0] = imm_5[25:0];
					aluOutput_5[31:26] = pc[9:4];
				end
				
				aluOutput = aluOutput_5;
				instruction = instruction_5;
			end

			if(FSM_1 == 3'b100) // Memory stage
			begin
				if(FSM2_1 == 16'h000B) // lw
				begin
					writeEnable = writeEnable_1;
					auxMem_1 = out_mem_data;
				end

				else if(FSM2_1 == 16'h000C) // sw
				begin
					writeEnable_1 = 1'b1; // Enable the write on data memory
					writeEnable = writeEnable_1;
				end
			end

			if(FSM_2 == 3'b100) // Memory stage
			begin
				if(FSM2_2 == 16'h000B) // lw
				begin
					writeEnable = writeEnable_2;
					auxMem_2 = out_mem_data;
				end

				else if(FSM2_2 == 16'h000C) // sw
				begin
					writeEnable_2 = 1'b1; // Enable the write on data memory
					writeEnable = writeEnable_2;
				end
			end

			if(FSM_3 == 3'b100) // Memory stage
			begin
				if(FSM2_3 == 16'h000B) // lw
				begin
					writeEnable = writeEnable_3;
					auxMem_3 = out_mem_data;
				end

				else if(FSM2_3 == 16'h000C) // sw
				begin
					writeEnable_3 = 1'b1; // Enable the write on data memory
					writeEnable = writeEnable_3;
				end
			end

			if(FSM_4 == 3'b100) // Memory stage
			begin
				if(FSM2_4 == 16'h000B) // lw
				begin
					writeEnable = writeEnable_4;
					auxMem_4 = out_mem_data;
				end

				else if(FSM2_4 == 16'h000C) // sw
				begin
					writeEnable_4 = 1'b1; // Enable the write on data memory
					writeEnable = writeEnable_4;
				end
			end

			if(FSM_5 == 3'b100) // Memory stage
			begin
				if(FSM2_5 == 16'h000B) // lw
				begin
					writeEnable = writeEnable_5;
					auxMem_5 = out_mem_data;
				end

				else if(FSM2_5 == 16'h000C) // sw
				begin
					writeEnable_5 = 1'b1; // Enable the write on data memory
					writeEnable = writeEnable_5;
				end
			end

			if(FSM_1 == 3'b101) // Writeback stage
			begin
				//R-Type Instructions
				if(instruction_1[31:26] == 6'b000000)
				begin
					registers[instruction_1[15:11]] = aluOutput_1;
				end

				//I-Type Instructions
				else if(instruction_1[31:26] == 6'b001000) // addi instruction
				begin
					registers[instruction_1[20:16]] = aluOutput_1;
				end

				else if(instruction_1[31:26] == 6'b100011) // lw instruction
				begin
					registers[instruction_1[20:16]] = auxMem_1;
				end

				else if(instruction_1[31:26] == 6'b101011) // sw instruction
				begin
					writeEnable_1 = 1'b0;
					writeEnable = writeEnable_1;
				end

				else if(instruction_1[31:26] == 6'b001100) // andi instruction
				begin
					registers[instruction_1[20:16]] = aluOutput_1;
				end

				else if(instruction_1[31:26] == 6'b001101) // ori instruction
				begin
					registers[instruction_1[20:16]] = aluOutput_1;
				end

				else if(instruction_1[31:26] == 6'b001010) // slti instruction
				begin
					registers[instruction_1[20:16]] = aluOutput_1;
				end

				else if(instruction_1[31:26] == 6'b000100) // beq instruction
				begin
					if(Zero_1 == 1'b1)
					begin
						pc[9:0] = aluOutput_1[9:0];
					end
				end

				else if(instruction_1[31:26] == 6'b000101) // bne instruction
				begin
					if(Zero_1 == 1'b0)
					begin
						pc[9:0] = aluOutput_1[9:0];
					end
				end
				// End I-Type Instructions

				// J-Type Instructions
				else if(instruction_1[31:26] == 6'b000010) // j instruction
				begin
					pc[9:0] = aluOutput_1[9:0];
				end
				// End J-Type Instructions
			end

			if(FSM_2 == 3'b101) // Writeback stage
			begin
				//R-Type Instructions
				if(instruction_2[31:26] == 6'b000000)
				begin
					registers[instruction_2[15:11]] = aluOutput_2;
				end

				//I-Type Instructions
				else if(instruction_2[31:26] == 6'b001000) // addi instruction
				begin
					registers[instruction_2[20:16]] = aluOutput_2;
				end

				else if(instruction_2[31:26] == 6'b100011) // lw instruction
				begin
					registers[instruction_2[20:16]] = auxMem_1;
				end

				else if(instruction_2[31:26] == 6'b101011) // sw instruction
				begin
					writeEnable_2 = 1'b0;
					writeEnable = writeEnable_2;
				end

				else if(instruction_2[31:26] == 6'b001100) // andi instruction
				begin
					registers[instruction_2[20:16]] = aluOutput_2;
				end

				else if(instruction_2[31:26] == 6'b001101) // ori instruction
				begin
					registers[instruction_2[20:16]] = aluOutput_2;
				end

				else if(instruction_2[31:26] == 6'b001010) // slti instruction
				begin
					registers[instruction_2[20:16]] = aluOutput_2;
				end

				else if(instruction_2[31:26] == 6'b000100) // beq instruction
				begin
					if(Zero_2 == 1'b1)
					begin
						pc[9:0] = aluOutput_2[9:0];
					end
				end

				else if(instruction_2[31:26] == 6'b000101) // bne instruction
				begin
					if(Zero_2 == 1'b0)
					begin
						pc[9:0] = aluOutput_2[9:0];
					end
				end
				// End I-Type Instructions

				// J-Type Instructions
				else if(instruction_2[31:26] == 6'b000010) // j instruction
				begin
					pc[9:0] = aluOutput_2[9:0];
				end
				// End J-Type Instructions
			end

			if(FSM_3 == 3'b101) // Writeback stage
			begin
				//R-Type Instructions
				if(instruction_3[31:26] == 6'b000000)
				begin
					registers[instruction_3[15:11]] = aluOutput_3;
				end

				//I-Type Instructions
				else if(instruction_3[31:26] == 6'b001000) // addi instruction
				begin
					registers[instruction_3[20:16]] = aluOutput_3;
				end

				else if(instruction_3[31:26] == 6'b100011) // lw instruction
				begin
					registers[instruction_3[20:16]] = auxMem_1;
				end

				else if(instruction_3[31:26] == 6'b101011) // sw instruction
				begin
					writeEnable_3 = 1'b0;
					writeEnable = writeEnable_3;
				end

				else if(instruction_3[31:26] == 6'b001100) // andi instruction
				begin
					registers[instruction_3[20:16]] = aluOutput_3;
				end

				else if(instruction_3[31:26] == 6'b001101) // ori instruction
				begin
					registers[instruction_3[20:16]] = aluOutput_3;
				end

				else if(instruction_3[31:26] == 6'b001010) // slti instruction
				begin
					registers[instruction_3[20:16]] = aluOutput_3;
				end

				else if(instruction_3[31:26] == 6'b000100) // beq instruction
				begin
					if(Zero_3 == 1'b1)
					begin
						pc[9:0] = aluOutput_3[9:0];
					end
				end

				else if(instruction_3[31:26] == 6'b000101) // bne instruction
				begin
					if(Zero_3 == 1'b0)
					begin
						pc[9:0] = aluOutput_3[9:0];
					end
				end
				// End I-Type Instructions

				// J-Type Instructions
				else if(instruction_3[31:26] == 6'b000010) // j instruction
				begin
					pc[9:0] = aluOutput_3[9:0];
				end
				// End J-Type Instructions
			end

			if(FSM_4 == 3'b101) // Writeback stage
			begin
				//R-Type Instructions
				if(instruction_4[31:26] == 6'b000000)
				begin
					registers[instruction_4[15:11]] = aluOutput_4;
				end

				//I-Type Instructions
				else if(instruction_4[31:26] == 6'b001000) // addi instruction
				begin
					registers[instruction_4[20:16]] = aluOutput_4;
				end

				else if(instruction_4[31:26] == 6'b100011) // lw instruction
				begin
					registers[instruction_4[20:16]] = auxMem_1;
				end

				else if(instruction_4[31:26] == 6'b101011) // sw instruction
				begin
					writeEnable_4 = 1'b0;
					writeEnable = writeEnable_4;
				end

				else if(instruction_4[31:26] == 6'b001100) // andi instruction
				begin
					registers[instruction_4[20:16]] = aluOutput_4;
				end

				else if(instruction_4[31:26] == 6'b001101) // ori instruction
				begin
					registers[instruction_4[20:16]] = aluOutput_4;
				end

				else if(instruction_4[31:26] == 6'b001010) // slti instruction
				begin
					registers[instruction_4[20:16]] = aluOutput_4;
				end

				else if(instruction_4[31:26] == 6'b000100) // beq instruction
				begin
					if(Zero_4 == 1'b1)
					begin
						pc[9:0] = aluOutput_4[9:0];
					end
				end

				else if(instruction_4[31:26] == 6'b000101) // bne instruction
				begin
					if(Zero_4 == 1'b0)
					begin
						pc[9:0] = aluOutput_4[9:0];
					end
				end
				// End I-Type Instructions

				// J-Type Instructions
				else if(instruction_4[31:26] == 6'b000010) // j instruction
				begin
					pc[9:0] = aluOutput_4[9:0];
				end
				// End J-Type Instructions
			end

			if(FSM_5 == 3'b101) // Writeback stage
			begin
				//R-Type Instructions
				if(instruction_5[31:26] == 6'b000000)
				begin
					registers[instruction_5[15:11]] = aluOutput_5;
				end

				//I-Type Instructions
				else if(instruction_5[31:26] == 6'b001000) // addi instruction
				begin
					registers[instruction_5[20:16]] = aluOutput_5;
				end

				else if(instruction_5[31:26] == 6'b100011) // lw instruction
				begin
					registers[instruction_5[20:16]] = auxMem_1;
				end

				else if(instruction_5[31:26] == 6'b101011) // sw instruction
				begin
					writeEnable_5 = 1'b0;
					writeEnable = writeEnable_5;
				end

				else if(instruction_5[31:26] == 6'b001100) // andi instruction
				begin
					registers[instruction_5[20:16]] = aluOutput_5;
				end

				else if(instruction_5[31:26] == 6'b001101) // ori instruction
				begin
					registers[instruction_5[20:16]] = aluOutput_5;
				end

				else if(instruction_5[31:26] == 6'b001010) // slti instruction
				begin
					registers[instruction_5[20:16]] = aluOutput_5;
				end

				else if(instruction_5[31:26] == 6'b000100) // beq instruction
				begin
					if(Zero_5 == 1'b1)
					begin
						pc[9:0] = aluOutput_5[9:0];
					end
				end

				else if(instruction_5[31:26] == 6'b000101) // bne instruction
				begin
					if(Zero_5 == 1'b0)
					begin
						pc[9:0] = aluOutput_5[9:0];
					end
				end
				// End I-Type Instructions

				// J-Type Instructions
				else if(instruction_5[31:26] == 6'b000010) // j instruction
				begin
					pc[9:0] = aluOutput_5[9:0];
				end
				// End J-Type Instructions
			end

			FSM_1 = FSM_1 + 1;
			FSM_2 = FSM_2 + 1;
			FSM_3 = FSM_3 + 1;
			FSM_4 = FSM_4 + 1;
			FSM_5 = FSM_5 + 1;

			if(FSM_1 == 3'b110)
			begin
				FSM_1 = 3'b001;
			end

			if(FSM_2 == 3'b110)
			begin
				FSM_2 = 3'b001;
			end

			if(FSM_3 == 3'b110)
			begin
				FSM_3 = 3'b001;
			end

			if(FSM_4 == 3'b110)
			begin
				FSM_4 = 3'b001;
			end

			if(FSM_5 == 3'b110)
			begin
				FSM_5 = 3'b001;
			end
	end
end
endmodule
