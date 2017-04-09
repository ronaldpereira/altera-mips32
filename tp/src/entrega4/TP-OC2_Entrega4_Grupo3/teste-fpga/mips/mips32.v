module mips32(
input CLOCK_50, // FPGA Clock 50 MHz
input [3:0] KEY, // FPGA KEY input (for FPGA testing)
input [1:0] SW, // FPGA Slide Switch input
output [7:0] LEDG, // Green led (Clock [25] counter)
output [31:0] LEDR, // Red Led (PC counter)
output [6:0] HEX0, // First seven segments display
output [6:0] HEX1, // Second seven segments display
output [6:0] HEX2, // Third seven segments display
output [6:0] HEX3, // Fourth seven segments display
output [6:0] HEX4, // Fifth seven segments display
output [6:0] HEX5, // Sixth seven segments display
output [6:0] HEX6, // Seventh seven segments display
output [6:0] HEX7 // Eighth seven segments display
);

reg [31:0] clk = 32'd0; // Clock

reg [2:0] FSM_1; // Finite State Machine -> tells which stage the processor is (IF, ID, EX, MEM, WB)
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

reg forwarding_A1; // Forwarding auxiliar on A register
reg forwarding_A2;
reg forwarding_A3;
reg forwarding_A4;
reg forwarding_A5;
  
reg forwarding_B1; // Forwarding auxiliar on B register
reg forwarding_B2;
reg forwarding_B3;
reg forwarding_B4;
reg forwarding_B5;

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

reg [31:0] hexInput; // Hex Display input

wire [31:0] out_mem_inst; // Instruction Memory output
wire [31:0] out_mem_data; // Data Memory output

mem_inst mem_i(.address(pc), .clock(clk[24]), .q(out_mem_inst));

mem_data mem_d(.address(aluOutput[9:0]), .clock(clk[24]), .data(registers[instruction[20:16]]), .wren(writeEnable), .q(out_mem_data));

displayDecoder DP7(.entrada(hexInput[31:0]),.zero(Zero),.saida0(HEX0),.saida1(HEX1),.saida2(HEX2),.saida3(HEX3),.saida4(HEX4),.saida5(HEX5),.saida6(HEX6),.saida7(HEX7));

	assign LEDG[0] = clk[25];

	always@(posedge CLOCK_50)
	begin
		clk = clk + 1;
	end

	always@(posedge clk[24])
	begin
		if(SW	== 2'b00 && instruction[31:26] == 6'b000000) // Shows on hex the destiny register output of a R-Type instruction
		begin
			hexInput <= registers[instruction[15:11]];
		end

		else if(SW == 2'b00 && (instruction[31:26] == 6'b001000 || instruction[31:26] == 6'b100011 || instruction[31:26] == 6'b101011 || instruction[31:26] == 6'b001100 || instruction[31:26] == 6'b001101 || instruction[31:26] == 6'b001010 || instruction[31:26] == 6'b000100 || instruction[31:26] == 6'b000101)) // Shows on hex the destiny register of a I-Type instruction
		begin
			hexInput <= registers[instruction[20:16]];
		end

		else if(SW == 2'b00 && instruction[31:26] == 6'b000010) // Shows on hex display the destiny register of a J-Type instruction
		begin
			hexInput[31:10] <= 22'b0000000000000000000000;
			hexInput[9:0] <= pc[9:0]; // On jump instructions, the destiny register is the pc
		end

		else if(SW == 2'b01)
		begin
			hexInput <= aluOutput;
		end

		else if(SW == 2'b10)
		begin
			hexInput[31:10] <= 22'b0000000000000000000000;
			hexInput[9:0] <= pc[9:0];
		end
	end

	always@(posedge clk[25])
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

			forwarding_A1 = 1'b0;
			forwarding_A2 = 1'b0;
			forwarding_A3 = 1'b0;
			forwarding_A4 = 1'b0;
			forwarding_A5 = 1'b0;
      
      forwarding_B1 = 1'b0;
			forwarding_B2 = 1'b0;
			forwarding_B3 = 1'b0;
			forwarding_B4 = 1'b0;
			forwarding_B5 = 1'b0;

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
          if(forwarding_A1 == 1'b0)
          begin
						A_1 = registers[instruction_1[25:21]];
          end
          
          if(forwarding_B1 == 1'b0)
          begin
						B_1 = registers[instruction_1[20:16]];
          end
				end

				else if(instruction_1[31:26] == 6'b000000 && instruction_1[5:0] == 6'b100010) // sub instruction
				begin
					FSM2_1 = 16'h0002; // sub
					if(forwarding_A1 == 1'b0)
          begin
						A_1 = registers[instruction_1[25:21]];
          end
          
          if(forwarding_B1 == 1'b0)
          begin
						B_1 = registers[instruction_1[20:16]];
          end
				end

				else if(instruction_1[31:26] == 6'b000000 && instruction_1[5:0] == 6'b100100) // and instruction
				begin
					FSM2_1 = 16'h0003; // and
					if(forwarding_A1 == 1'b0)
          begin
						A_1 = registers[instruction_1[25:21]];
          end
          
          if(forwarding_B1 == 1'b0)
          begin
						B_1 = registers[instruction_1[20:16]];
          end

				end

				else if(instruction_1[31:26] == 6'b000000 && instruction_1[5:0] == 6'b100111) // nor instruction
				begin
					FSM2_1 = 16'h0004; // nor
				if(forwarding_A1 == 1'b0)
          begin
						A_1 = registers[instruction_1[25:21]];
          end
          
          if(forwarding_B1 == 1'b0)
          begin
						B_1 = registers[instruction_1[20:16]];
          end
				end

				else if(instruction_1[31:26] == 6'b000000 && instruction_1[5:0] == 6'b100110) // xor instruction
				begin
					FSM2_1 = 16'h0005; // xor
					if(forwarding_A1 == 1'b0)
          begin
						A_1 = registers[instruction_1[25:21]];
          end
          
          if(forwarding_B1 == 1'b0)
          begin
						B_1 = registers[instruction_1[20:16]];
          end
				end

				else if(instruction_1[31:26] == 6'b000000 && instruction_1[5:0] == 6'b101010) // slt instruction
				begin
					FSM2_1 = 16'h0006; // slt
          
          
					if(forwarding_A1 == 1'b0)
          begin
						A_1 = registers[instruction_1[25:21]];
          end
          
          if(forwarding_B1 == 1'b0)
          begin
						B_1 = registers[instruction_1[20:16]];
          end
				end

				else if(instruction_1[31:26] == 6'b000000 && instruction_1[5:0] == 6'b000000) // sll instruction
				begin
					FSM2_1 = 16'h0007; // sll
					if(forwarding_A1 == 1'b0)
          begin
						A_1 = registers[instruction_1[25:21]];
          end
					B_1 = registers[instruction_1[10:6]];
				end

				else if(instruction_1[31:26] == 6'b000000 && instruction_1[5:0] == 6'b000010) // srl instruction
				begin
					FSM2_1 = 16'h0008; // srl
					if(forwarding_A1 == 1'b0)
          begin
						A_1 = registers[instruction_1[25:21]];
          end
					B_1 = registers[instruction_1[10:6]];
				end

				else if(instruction_1[31:26] == 6'b000000 && instruction_1[5:0] == 6'b100101) // or instruction
				begin
					FSM2_1 = 16'h0009; // or
					if(forwarding_A1 == 1'b0)
          begin
						A_1 = registers[instruction_1[25:21]];
          end
          
          if(forwarding_B1 == 1'b0)
          begin
						B_1 = registers[instruction_1[20:16]];
          end

				end
				// End R-Type Instructions

				// I-Type Instructions
				else if(instruction_1[31:26] == 6'b001000) // addi instruction
				begin
					FSM2_1 = 16'h000A_1; // addi
					if(forwarding_A1 == 1'b0)
					begin
						A_1 = registers[instruction_1[25:21]];
					end
					imm_1[15:0] = instruction_1[15:0];
					imm_1[31:16] = instruction_1[15]; // Immediate signal extension
				end

				else if(instruction_1[31:26] == 6'b100011) // lw instruction
				begin
					FSM2_1 = 16'h000B_1; // lw
					if(forwarding_A1 == 1'b0)
					begin
						A_1 = registers[instruction_1[25:21]];
					end
					imm_1[15:0] = instruction_1[15:0];
					imm_1[31:16] = instruction_1[15]; // Immediate signal extension
				end

				else if(instruction_1[31:26] == 6'b101011) // sw instruction
				begin
					FSM2_1 = 16'h000C; // sw
					if(forwarding_A1 == 1'b0)
          begin
						A_1 = registers[instruction_1[25:21]];
          end
					imm_1[15:0] = instruction_1[15:0];
					imm_1[31:16] = instruction_1[15]; // Immediate signal extension
				end

				else if(instruction_1[31:26] == 6'b001100) // andi instruction
				begin
					FSM2_1 = 16'h000D; // andi
					if(forwarding_A1 == 1'b0)
					begin
						A_1 = registers[instruction_1[25:21]];
					end
					imm_1[15:0] = instruction_1[15:0];
					imm_1[31:16] = instruction_1[15]; // Immediate signal extension
				end

				else if(instruction_1[31:26] == 6'b001101) // ori instruction
				begin
					FSM2_1 = 16'h000E; // ori
					if(forwarding_A1 == 1'b0)
					begin
						A_1 = registers[instruction_1[25:21]];
					end
					imm_1[15:0] = instruction_1[15:0];
					imm_1[31:16] = instruction_1[15]; // Immediate signal extension
				end

				else if(instruction_1[31:26] == 6'b001010) // slti instruction
				begin
					FSM2_1 = 16'h000F; // slti
					if(forwarding_A1 == 1'b0)
					begin
						A_1 = registers[instruction_1[25:21]];
					end
					imm_1[15:0] = instruction_1[15:0];
					imm_1[31:16] = instruction_1[15]; // Immediate signal extension
				end

				else if(instruction_1[31:26] == 6'b000100) // beq instruction
				begin
					FSM2_1 = 16'h0010; // beq
					if(forwarding_A1 == 1'b0)
					begin
						A_1 = registers[instruction_1[25:21]];
					end
					 if(forwarding_B1 == 1'b0)
					begin
						B_1 = registers[instruction_1[20:16]];
					end
					imm_1[15:0] = instruction_1[15:0];
					imm_1[31:16] = instruction_1[15]; // Immediate signal extension
				end

				else if(instruction_1[31:26] == 6'b000101) // bne instruction
				begin
					FSM2_1 = 16'h0011; // bne
					if(forwarding_A1 == 1'b0)
					begin
						A_1 = registers[instruction_1[25:21]];
					end
					 if(forwarding_B1 == 1'b0)
					begin
						B_1 = registers[instruction_1[20:16]];
					end
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
					if(forwarding_A2 == 1'b0)
					begin
						A_2 = registers[instruction_2[25:21]];
					end
					if(forwarding_B2 == 1'b0)
					begin
						B_2 = registers[instruction_2[20:16]];
					end
				end

				else if(instruction_2[31:26] == 6'b000000 && instruction_2[5:0] == 6'b100010) // sub instruction
				begin
					FSM2_2 = 16'h0002; // sub
					if(forwarding_A2 == 1'b0)
          begin
            A_2 = registers[instruction_2[25:21]];
          end
					if(forwarding_B2 == 1'b0)
          begin
            B_2 = registers[instruction_2[20:16]];
          end
				end

				else if(instruction_2[31:26] == 6'b000000 && instruction_2[5:0] == 6'b100100) // and instruction
				begin
					FSM2_2 = 16'h0003; // and
					if(forwarding_A2 == 1'b0)
          begin
            A_2 = registers[instruction_2[25:21]];
          end
					if(forwarding_B2 == 1'b0)
          begin
            B_2 = registers[instruction_2[20:16]];
          end
				end

				else if(instruction_2[31:26] == 6'b000000 && instruction_2[5:0] == 6'b100111) // nor instruction
				begin
					FSM2_2 = 16'h0004; // nor
					if(forwarding_A2 == 1'b0)
          begin
            A_2 = registers[instruction_2[25:21]];
          end
					if(forwarding_B2 == 1'b0)
          begin
            B_2 = registers[instruction_2[20:16]];
          end
				end

				else if(instruction_2[31:26] == 6'b000000 && instruction_2[5:0] == 6'b100110) // xor instruction
				begin
					FSM2_2 = 16'h0005; // xor
					if(forwarding_A2 == 1'b0)
          begin
            A_2 = registers[instruction_2[25:21]];
          end
					if(forwarding_B2 == 1'b0)
          begin
            B_2 = registers[instruction_2[20:16]];
          end
				end

				else if(instruction_2[31:26] == 6'b000000 && instruction_2[5:0] == 6'b101010) // slt instruction
				begin
					FSM2_2 = 16'h0006; // slt
					if(forwarding_A2 == 1'b0)
          begin
            A_2 = registers[instruction_2[25:21]];
          end
					if(forwarding_B2 == 1'b0)
          begin
            B_2 = registers[instruction_2[20:16]];
          end
				end

				else if(instruction_2[31:26] == 6'b000000 && instruction_2[5:0] == 6'b000000) // sll instruction
				begin
					FSM2_2 = 16'h0007; // sll
					if(forwarding_A2 == 1'b0)
          begin
            A_2 = registers[instruction_2[25:21]];
          end
					B_2 = registers[instruction_2[10:6]];
				end

				else if(instruction_2[31:26] == 6'b000000 && instruction_2[5:0] == 6'b000010) // srl instruction
				begin
					FSM2_2 = 16'h0008; // srl
					if(forwarding_A2 == 1'b0)
          begin
            A_2 = registers[instruction_2[25:21]];
          end
					B_2 = registers[instruction_2[10:6]];
				end

				else if(instruction_2[31:26] == 6'b000000 && instruction_2[5:0] == 6'b100101) // or instruction
				begin
					FSM2_2 = 16'h0009; // or
					if(forwarding_A2 == 1'b0)
          begin
            A_2 = registers[instruction_2[25:21]];
          end
					if(forwarding_B2 == 1'b0)
          begin
            B_2 = registers[instruction_2[20:16]];
          end

				end
				// End R-Type Instructions

				// I-Type Instructions
				else if(instruction_2[31:26] == 6'b001000) // addi instruction
				begin
					FSM2_2 = 16'h000A_2; // addi
					if(forwarding_A2 == 1'b0)
          begin
            A_2 = registers[instruction_2[25:21]];
          end
					imm_2[15:0] = instruction_2[15:0];
					imm_2[31:16] = instruction_2[15]; // Immediate signal extension
				end

				else if(instruction_2[31:26] == 6'b100011) // lw instruction
				begin
					FSM2_2 = 16'h000B_2; // lw
					if(forwarding_A2 == 1'b0)
          begin
            A_2 = registers[instruction_2[25:21]];
          end
					imm_2[15:0] = instruction_2[15:0];
					imm_2[31:16] = instruction_2[15]; // Immediate signal extension
				end

				else if(instruction_2[31:26] == 6'b101011) // sw instruction
				begin
					FSM2_2 = 16'h000C; // sw
					if(forwarding_A2 == 1'b0)
          begin
            A_2 = registers[instruction_2[25:21]];
          end
					imm_2[15:0] = instruction_2[15:0];
					imm_2[31:16] = instruction_2[15]; // Immediate signal extension
				end

				else if(instruction_2[31:26] == 6'b001100) // andi instruction
				begin
					FSM2_2 = 16'h000D; // andi
					if(forwarding_A2 == 1'b0)
          begin
            A_2 = registers[instruction_2[25:21]];
          end
					imm_2[15:0] = instruction_2[15:0];
					imm_2[31:16] = instruction_2[15]; // Immediate signal extension
				end

				else if(instruction_2[31:26] == 6'b001101) // ori instruction
				begin
					FSM2_2 = 16'h000E; // ori
					if(forwarding_A2 == 1'b0)
          begin
            A_2 = registers[instruction_2[25:21]];
          end
					imm_2[15:0] = instruction_2[15:0];
					imm_2[31:16] = instruction_2[15]; // Immediate signal extension
				end

				else if(instruction_2[31:26] == 6'b001010) // slti instruction
				begin
					FSM2_2 = 16'h000F; // slti
					if(forwarding_A2 == 1'b0)
          begin
            A_2 = registers[instruction_2[25:21]];
          end
					imm_2[15:0] = instruction_2[15:0];
					imm_2[31:16] = instruction_2[15]; // Immediate signal extension
				end

				else if(instruction_2[31:26] == 6'b000100) // beq instruction
				begin
					FSM2_2 = 16'h0010; // beq
					if(forwarding_A2 == 1'b0)
          begin
            A_2 = registers[instruction_2[25:21]];
          end
					if(forwarding_B2 == 1'b0)
          begin
            B_2 = registers[instruction_2[20:16]];
          end
					imm_2[15:0] = instruction_2[15:0];
					imm_2[31:16] = instruction_2[15]; // Immediate signal extension
				end

				else if(instruction_2[31:26] == 6'b000101) // bne instruction
				begin
					FSM2_2 = 16'h0011; // bne
					if(forwarding_A2 == 1'b0)
          begin
            A_2 = registers[instruction_2[25:21]];
          end
					if(forwarding_B2 == 1'b0)
          begin
            B_2 = registers[instruction_2[20:16]];
          end
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
					if(forwarding_A3 == 1'b0)
          begin
            A_3 = registers[instruction_3[25:21]];
          end
					if(forwarding_B3 == 1'b0)
          begin
            B_3 = registers[instruction_3[20:16]];
          end
				end

				else if(instruction_3[31:26] == 6'b000000 && instruction_3[5:0] == 6'b100010) // sub instruction
				begin
					FSM2_3 = 16'h0002; // sub
					if(forwarding_A3 == 1'b0)
          begin
            A_3 = registers[instruction_3[25:21]];
          end
					if(forwarding_B3 == 1'b0)
          begin
            B_3 = registers[instruction_3[20:16]];
          end
				end

				else if(instruction_3[31:26] == 6'b000000 && instruction_3[5:0] == 6'b100100) // and instruction
				begin
					FSM2_3 = 16'h0003; // and
					if(forwarding_A3 == 1'b0)
          begin
            A_3 = registers[instruction_3[25:21]];
          end
					if(forwarding_B3 == 1'b0)
          begin
            B_3 = registers[instruction_3[20:16]];
          end
				end

				else if(instruction_3[31:26] == 6'b000000 && instruction_3[5:0] == 6'b100111) // nor instruction
				begin
					FSM2_3 = 16'h0004; // nor
					if(forwarding_A3 == 1'b0)
          begin
            A_3 = registers[instruction_3[25:21]];
          end
					if(forwarding_B3 == 1'b0)
          begin
            B_3 = registers[instruction_3[20:16]];
          end
				end

				else if(instruction_3[31:26] == 6'b000000 && instruction_3[5:0] == 6'b100110) // xor instruction
				begin
					FSM2_3 = 16'h0005; // xor
					if(forwarding_A3 == 1'b0)
          begin
            A_3 = registers[instruction_3[25:21]];
          end
					if(forwarding_B3 == 1'b0)
          begin
            B_3 = registers[instruction_3[20:16]];
          end
				end

				else if(instruction_3[31:26] == 6'b000000 && instruction_3[5:0] == 6'b101010) // slt instruction
				begin
					FSM2_3 = 16'h0006; // slt
					if(forwarding_A3 == 1'b0)
          begin
            A_3 = registers[instruction_3[25:21]];
          end
					if(forwarding_B3 == 1'b0)
          begin
            B_3 = registers[instruction_3[20:16]];
          end
				end

				else if(instruction_3[31:26] == 6'b000000 && instruction_3[5:0] == 6'b000000) // sll instruction
				begin
					FSM2_3 = 16'h0007; // sll
					if(forwarding_A3 == 1'b0)
          begin
            A_3 = registers[instruction_3[25:21]];
          end
					B_3 = registers[instruction_3[10:6]];
				end

				else if(instruction_3[31:26] == 6'b000000 && instruction_3[5:0] == 6'b000010) // srl instruction
				begin
					FSM2_3 = 16'h0008; // srl
					if(forwarding_A3 == 1'b0)
          begin
            A_3 = registers[instruction_3[25:21]];
          end
					B_3 = registers[instruction_3[10:6]];
				end

				else if(instruction_3[31:26] == 6'b000000 && instruction_3[5:0] == 6'b100101) // or instruction
				begin
					FSM2_3 = 16'h0009; // or
					if(forwarding_A3 == 1'b0)
          begin
            A_3 = registers[instruction_3[25:21]];
          end
					if(forwarding_B3 == 1'b0)
          begin
            B_3 = registers[instruction_3[20:16]];
          end

				end
				// End R-Type Instructions

				// I-Type Instructions
				else if(instruction_3[31:26] == 6'b001000) // addi instruction
				begin
					FSM2_3 = 16'h000A_3; // addi
					if(forwarding_A3 == 1'b0)
          begin
            A_3 = registers[instruction_3[25:21]];
          end
					imm_3[15:0] = instruction_3[15:0];
					imm_3[31:16] = instruction_3[15]; // Immediate signal extension
				end

				else if(instruction_3[31:26] == 6'b100011) // lw instruction
				begin
					FSM2_3 = 16'h000B_3; // lw
					if(forwarding_A3 == 1'b0)
          begin
            A_3 = registers[instruction_3[25:21]];
          end
					imm_3[15:0] = instruction_3[15:0];
					imm_3[31:16] = instruction_3[15]; // Immediate signal extension
				end

				else if(instruction_3[31:26] == 6'b101011) // sw instruction
				begin
					FSM2_3 = 16'h000C; // sw
					if(forwarding_A3 == 1'b0)
          begin
            A_3 = registers[instruction_3[25:21]];
          end
					imm_3[15:0] = instruction_3[15:0];
					imm_3[31:16] = instruction_3[15]; // Immediate signal extension
				end

				else if(instruction_3[31:26] == 6'b001100) // andi instruction
				begin
					FSM2_3 = 16'h000D; // andi
					if(forwarding_A3 == 1'b0)
          begin
            A_3 = registers[instruction_3[25:21]];
          end
					imm_3[15:0] = instruction_3[15:0];
					imm_3[31:16] = instruction_3[15]; // Immediate signal extension
				end

				else if(instruction_3[31:26] == 6'b001101) // ori instruction
				begin
					FSM2_3 = 16'h000E; // ori
					if(forwarding_A3 == 1'b0)
          begin
            A_3 = registers[instruction_3[25:21]];
          end
					imm_3[15:0] = instruction_3[15:0];
					imm_3[31:16] = instruction_3[15]; // Immediate signal extension
				end

				else if(instruction_3[31:26] == 6'b001010) // slti instruction
				begin
					FSM2_3 = 16'h000F; // slti
					if(forwarding_A3 == 1'b0)
          begin
            A_3 = registers[instruction_3[25:21]];
          end
					imm_3[15:0] = instruction_3[15:0];
					imm_3[31:16] = instruction_3[15]; // Immediate signal extension
				end

				else if(instruction_3[31:26] == 6'b000100) // beq instruction
				begin
					FSM2_3 = 16'h0010; // beq
					if(forwarding_A3 == 1'b0)
          begin
            A_3 = registers[instruction_3[25:21]];
          end
					if(forwarding_B3 == 1'b0)
          begin
            B_3 = registers[instruction_3[20:16]];
          end
					imm_3[15:0] = instruction_3[15:0];
					imm_3[31:16] = instruction_3[15]; // Immediate signal extension
				end

				else if(instruction_3[31:26] == 6'b000101) // bne instruction
				begin
					FSM2_3 = 16'h0011; // bne
					if(forwarding_A3 == 1'b0)
          begin
            A_3 = registers[instruction_3[25:21]];
          end
					if(forwarding_B3 == 1'b0)
          begin
            B_3 = registers[instruction_3[20:16]];
          end
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
					if(forwarding_A4 == 1'b0)
          begin
            A_4 = registers[instruction_4[25:21]];
          end
					if(forwarding_B4 == 1'b0)
          begin
            B_4 = registers[instruction_4[20:16]];
          end
				end

				else if(instruction_4[31:26] == 6'b000000 && instruction_4[5:0] == 6'b100010) // sub instruction
				begin
					FSM2_4 = 16'h0002; // sub
					if(forwarding_A4 == 1'b0)
          begin
            A_4 = registers[instruction_4[25:21]];
          end
					if(forwarding_B4 == 1'b0)
          begin
            B_4 = registers[instruction_4[20:16]];
          end
				end

				else if(instruction_4[31:26] == 6'b000000 && instruction_4[5:0] == 6'b100100) // and instruction
				begin
					FSM2_4 = 16'h0003; // and
					if(forwarding_A4 == 1'b0)
          begin
            A_4 = registers[instruction_4[25:21]];
          end
					if(forwarding_B4 == 1'b0)
          begin
            B_4 = registers[instruction_4[20:16]];
          end

				end

				else if(instruction_4[31:26] == 6'b000000 && instruction_4[5:0] == 6'b100111) // nor instruction
				begin
					FSM2_4 = 16'h0004; // nor
					if(forwarding_A4 == 1'b0)
          begin
            A_4 = registers[instruction_4[25:21]];
          end
					if(forwarding_B4 == 1'b0)
          begin
            B_4 = registers[instruction_4[20:16]];
          end
				end

				else if(instruction_4[31:26] == 6'b000000 && instruction_4[5:0] == 6'b100110) // xor instruction
				begin
					FSM2_4 = 16'h0005; // xor
					if(forwarding_A4 == 1'b0)
          begin
            A_4 = registers[instruction_4[25:21]];
          end
					if(forwarding_B4 == 1'b0)
          begin
            B_4 = registers[instruction_4[20:16]];
          end
				end

				else if(instruction_4[31:26] == 6'b000000 && instruction_4[5:0] == 6'b101010) // slt instruction
				begin
					FSM2_4 = 16'h0006; // slt
					if(forwarding_A4 == 1'b0)
          begin
            A_4 = registers[instruction_4[25:21]];
          end
					if(forwarding_B4 == 1'b0)
          begin
            B_4 = registers[instruction_4[20:16]];
          end
				end

				else if(instruction_4[31:26] == 6'b000000 && instruction_4[5:0] == 6'b000000) // sll instruction
				begin
					FSM2_4 = 16'h0007; // sll
					if(forwarding_A4 == 1'b0)
          begin
            A_4 = registers[instruction_4[25:21]];
          end
					B_4 = registers[instruction_4[10:6]];
				end

				else if(instruction_4[31:26] == 6'b000000 && instruction_4[5:0] == 6'b000010) // srl instruction
				begin
					FSM2_4 = 16'h0008; // srl
					if(forwarding_A4 == 1'b0)
          begin
            A_4 = registers[instruction_4[25:21]];
          end
					B_4 = registers[instruction_4[10:6]];
				end

				else if(instruction_4[31:26] == 6'b000000 && instruction_4[5:0] == 6'b100101) // or instruction
				begin
					FSM2_4 = 16'h0009; // or
					if(forwarding_A4 == 1'b0)
          begin
            A_4 = registers[instruction_4[25:21]];
          end
					if(forwarding_B4 == 1'b0)
          begin
            B_4 = registers[instruction_4[20:16]];
          end

				end
				// End R-Type Instructions

				// I-Type Instructions
				else if(instruction_4[31:26] == 6'b001000) // addi instruction
				begin
					FSM2_4 = 16'h000A_4; // addi
					if(forwarding_A4 == 1'b0)
          begin
            A_4 = registers[instruction_4[25:21]];
          end
					imm_4[15:0] = instruction_4[15:0];
					imm_4[31:16] = instruction_4[15]; // Immediate signal extension
				end

				else if(instruction_4[31:26] == 6'b100011) // lw instruction
				begin
					FSM2_4 = 16'h000B_4; // lw
					if(forwarding_A4 == 1'b0)
          begin
            A_4 = registers[instruction_4[25:21]];
          end
					imm_4[15:0] = instruction_4[15:0];
					imm_4[31:16] = instruction_4[15]; // Immediate signal extension
				end

				else if(instruction_4[31:26] == 6'b101011) // sw instruction
				begin
					FSM2_4 = 16'h000C; // sw
					if(forwarding_A4 == 1'b0)
          begin
            A_4 = registers[instruction_4[25:21]];
          end
					imm_4[15:0] = instruction_4[15:0];
					imm_4[31:16] = instruction_4[15]; // Immediate signal extension
				end

				else if(instruction_4[31:26] == 6'b001100) // andi instruction
				begin
					FSM2_4 = 16'h000D; // andi
					if(forwarding_A4 == 1'b0)
          begin
            A_4 = registers[instruction_4[25:21]];
          end
					imm_4[15:0] = instruction_4[15:0];
					imm_4[31:16] = instruction_4[15]; // Immediate signal extension
				end

				else if(instruction_4[31:26] == 6'b001101) // ori instruction
				begin
					FSM2_4 = 16'h000E; // ori
					if(forwarding_A4 == 1'b0)
          begin
            A_4 = registers[instruction_4[25:21]];
          end
					imm_4[15:0] = instruction_4[15:0];
					imm_4[31:16] = instruction_4[15]; // Immediate signal extension
				end

				else if(instruction_4[31:26] == 6'b001010) // slti instruction
				begin
					FSM2_4 = 16'h000F; // slti
					if(forwarding_A4 == 1'b0)
          begin
            A_4 = registers[instruction_4[25:21]];
          end
					imm_4[15:0] = instruction_4[15:0];
					imm_4[31:16] = instruction_4[15]; // Immediate signal extension
				end

				else if(instruction_4[31:26] == 6'b000100) // beq instruction
				begin
					FSM2_4 = 16'h0010; // beq
					if(forwarding_A4 == 1'b0)
          begin
            A_4 = registers[instruction_4[25:21]];
          end
					if(forwarding_B4 == 1'b0)
          begin
            B_4 = registers[instruction_4[20:16]];
          end
					imm_4[15:0] = instruction_4[15:0];
					imm_4[31:16] = instruction_4[15]; // Immediate signal extension
				end

				else if(instruction_4[31:26] == 6'b000101) // bne instruction
				begin
					FSM2_4 = 16'h0011; // bne
					if(forwarding_A4 == 1'b0)
          begin
            A_4 = registers[instruction_4[25:21]];
          end
					if(forwarding_B4 == 1'b0)
          begin
            B_4 = registers[instruction_4[20:16]];
          end
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
					if(forwarding_A5 == 1'b0)
          begin
            A_5 = registers[instruction_5[25:21]];
          end
					if(forwarding_B5 == 1'b0)
          begin
            B_5 = registers[instruction_5[20:16]];
          end
				end

				else if(instruction_5[31:26] == 6'b000000 && instruction_5[5:0] == 6'b100010) // sub instruction
				begin
					FSM2_5 = 16'h0002; // sub
					if(forwarding_A5 == 1'b0)
          begin
            A_5 = registers[instruction_5[25:21]];
          end
					if(forwarding_B5 == 1'b0)
          begin
            B_5 = registers[instruction_5[20:16]];
          end
				end

				else if(instruction_5[31:26] == 6'b000000 && instruction_5[5:0] == 6'b100100) // and instruction
				begin
					FSM2_5 = 16'h0003; // and
					if(forwarding_A5 == 1'b0)
          begin
            A_5 = registers[instruction_5[25:21]];
          end
					if(forwarding_B5 == 1'b0)
          begin
            B_5 = registers[instruction_5[20:16]];
          end

				end

				else if(instruction_5[31:26] == 6'b000000 && instruction_5[5:0] == 6'b100111) // nor instruction
				begin
					FSM2_5 = 16'h0004; // nor
					if(forwarding_A5 == 1'b0)
          begin
            A_5 = registers[instruction_5[25:21]];
          end
					if(forwarding_B5 == 1'b0)
          begin
            B_5 = registers[instruction_5[20:16]];
          end
				end

				else if(instruction_5[31:26] == 6'b000000 && instruction_5[5:0] == 6'b100110) // xor instruction
				begin
					FSM2_5 = 16'h0005; // xor
					if(forwarding_A5 == 1'b0)
          begin
            A_5 = registers[instruction_5[25:21]];
          end
					if(forwarding_B5 == 1'b0)
          begin
            B_5 = registers[instruction_5[20:16]];
          end
				end

				else if(instruction_5[31:26] == 6'b000000 && instruction_5[5:0] == 6'b101010) // slt instruction
				begin
					FSM2_5 = 16'h0006; // slt
					if(forwarding_A5 == 1'b0)
          begin
            A_5 = registers[instruction_5[25:21]];
          end
					if(forwarding_B5 == 1'b0)
          begin
            B_5 = registers[instruction_5[20:16]];
          end
				end

				else if(instruction_5[31:26] == 6'b000000 && instruction_5[5:0] == 6'b000000) // sll instruction
				begin
					FSM2_5 = 16'h0007; // sll
					if(forwarding_A5 == 1'b0)
          begin
            A_5 = registers[instruction_5[25:21]];
          end
					B_5 = registers[instruction_5[10:6]];
				end

				else if(instruction_5[31:26] == 6'b000000 && instruction_5[5:0] == 6'b000010) // srl instruction
				begin
					FSM2_5 = 16'h0008; // srl
					if(forwarding_A5 == 1'b0)
          begin
            A_5 = registers[instruction_5[25:21]];
          end
					B_5 = registers[instruction_5[10:6]];
				end

				else if(instruction_5[31:26] == 6'b000000 && instruction_5[5:0] == 6'b100101) // or instruction
				begin
					FSM2_5 = 16'h0009; // or
					if(forwarding_A5 == 1'b0)
          begin
            A_5 = registers[instruction_5[25:21]];
          end
					if(forwarding_B5 == 1'b0)
          begin
            B_5 = registers[instruction_5[20:16]];
          end

				end
				// End R-Type Instructions

				// I-Type Instructions
				else if(instruction_5[31:26] == 6'b001000) // addi instruction
				begin
					FSM2_5 = 16'h000A_5; // addi
					if(forwarding_A5 == 1'b0)
          begin
            A_5 = registers[instruction_5[25:21]];
          end
					imm_5[15:0] = instruction_5[15:0];
					imm_5[31:16] = instruction_5[15]; // Immediate signal extension
				end

				else if(instruction_5[31:26] == 6'b100011) // lw instruction
				begin
					FSM2_5 = 16'h000B_5; // lw
					if(forwarding_A5 == 1'b0)
          begin
            A_5 = registers[instruction_5[25:21]];
          end
					imm_5[15:0] = instruction_5[15:0];
					imm_5[31:16] = instruction_5[15]; // Immediate signal extension
				end

				else if(instruction_5[31:26] == 6'b101011) // sw instruction
				begin
					FSM2_5 = 16'h000C; // sw
					if(forwarding_A5 == 1'b0)
          begin
            A_5 = registers[instruction_5[25:21]];
          end
					imm_5[15:0] = instruction_5[15:0];
					imm_5[31:16] = instruction_5[15]; // Immediate signal extension
				end

				else if(instruction_5[31:26] == 6'b001100) // andi instruction
				begin
					FSM2_5 = 16'h000D; // andi
					if(forwarding_A5 == 1'b0)
          begin
            A_5 = registers[instruction_5[25:21]];
          end
					imm_5[15:0] = instruction_5[15:0];
					imm_5[31:16] = instruction_5[15]; // Immediate signal extension
				end

				else if(instruction_5[31:26] == 6'b001101) // ori instruction
				begin
					FSM2_5 = 16'h000E; // ori
					if(forwarding_A5 == 1'b0)
          begin
            A_5 = registers[instruction_5[25:21]];
          end
					imm_5[15:0] = instruction_5[15:0];
					imm_5[31:16] = instruction_5[15]; // Immediate signal extension
				end

				else if(instruction_5[31:26] == 6'b001010) // slti instruction
				begin
					FSM2_5 = 16'h000F; // slti
					if(forwarding_A5 == 1'b0)
          begin
            A_5 = registers[instruction_5[25:21]];
          end
					imm_5[15:0] = instruction_5[15:0];
					imm_5[31:16] = instruction_5[15]; // Immediate signal extension
				end

				else if(instruction_5[31:26] == 6'b000100) // beq instruction
				begin
					FSM2_5 = 16'h0010; // beq
					if(forwarding_A5 == 1'b0)
          begin
            A_5 = registers[instruction_5[25:21]];
          end
					if(forwarding_B5 == 1'b0)
          begin
            B_5 = registers[instruction_5[20:16]];
          end
					imm_5[15:0] = instruction_5[15:0];
					imm_5[31:16] = instruction_5[15]; // Immediate signal extension
				end

				else if(instruction_5[31:26] == 6'b000101) // bne instruction
				begin
					FSM2_5 = 16'h0011; // bne
					if(forwarding_A5 == 1'b0)
          begin
            A_5 = registers[instruction_5[25:21]];
          end
					if(forwarding_B5 == 1'b0)
          begin
            B_5 = registers[instruction_5[20:16]];
          end
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
				aluOutput = aluOutput_1;
				instruction = instruction_1;

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
        
        forwarding_A1 = 1'b0;
        forwarding_B1 = 1'b0;
			end

			else if(FSM_2 == 3'b011) // Execute
			begin
				aluOutput = aluOutput_2;
				instruction = instruction_2;

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
        
        forwarding_A2 = 1'b0;
				forwarding_B2 = 1'b0;
      end

			else if(FSM_3 == 3'b011) // Execute
			begin
				aluOutput = aluOutput_3;
				instruction = instruction_3;

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
        
      forwarding_A3 = 1'b0;
      forwarding_B3 = 1'b0;
			end

			else if(FSM_4 == 3'b011) // Execute
			begin
				aluOutput = aluOutput_4;
				instruction = instruction_4;

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
        
        forwarding_A4 = 1'b0;
        forwarding_B4 = 1'b0;
			end

			else if(FSM_5 == 3'b011) // Execute
			begin
				aluOutput = aluOutput_5;
				instruction = instruction_5;

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
        
        forwarding_A5 = 1'b0;
        forwarding_B5 = 1'b0;
			end

			if(FSM_1 == 3'b100) // Memory stage
			begin
				//Forwarding verification
				if(instruction_1[15:11] == instruction_2[25:21] && instruction_1[15:11] != 0)
				begin
					A_2 = aluOutput_1;
					forwarding_A2 = 1'b1;
				end

				if(instruction_1[15:11] == instruction_2[20:16] && instruction_1[15:11] != 0)
				begin
					B_2 = aluOutput_1;
					forwarding_B2 = 1'b1;
				end

				if(instruction_1[15:11] == instruction_3[25:21] && instruction_1[15:11] != 0)
				begin
					A_3 = aluOutput_1;
					forwarding_A3 = 1'b1;
				end

				if(instruction_1[15:11] == instruction_3[20:16] && instruction_1[15:11] != 0)
				begin
					B_3 = aluOutput_1;
					forwarding_B3 = 1'b1;
				end

				if(instruction_1[15:11] == instruction_4[25:21] && instruction_1[15:11] != 0)
				begin
					A_4 = aluOutput_1;
					forwarding_A4 = 1'b1;
				end

				if(instruction_1[15:11] == instruction_4[20:16] && instruction_1[15:11] != 0)
				begin
					B_4 = aluOutput_1;
					forwarding_B4 = 1'b1;
				end

				if(instruction_1[15:11] == instruction_5[25:21] && instruction_1[15:11] != 0)
				begin
					A_5 = aluOutput_1;
					forwarding_A5 = 1'b1;
				end

				if(instruction_1[15:11] == instruction_5[20:16] && instruction_1[15:11] != 0)
				begin
					B_5 = aluOutput_1;
					forwarding_B5 = 1'b1;
				end
				// End of forwarding stage

				if(FSM2_1 == 16'h000B) // lw
				begin
					writeEnable = writeEnable_1;
					auxMem_1 = out_mem_data;
          
          // Load forwarding
          if(instruction_1[20:16] == instruction_2[25:21])
		 			begin
		  			A_2 = auxMem_1;
						forwarding_A2 = 1'b1;
          end

		  		if(instruction_1[20:16] == instruction_2[20:16])
          begin
		  			B_2 = auxMem_1;
						forwarding_B2 = 1'b1;
		  		end

		  		if(instruction_1[20:16] == instruction_3[25:21])
          begin
      			A_3 = auxMem_1;
						forwarding_A3 = 1'b1;
		  		end

		  		if(instruction_1[20:16] == instruction_3[20:16])
		  		begin
		  			B_3 = auxMem_1;
						forwarding_B3 = 1'b1;
		  		end

		  		if(instruction_1[20:16] == instruction_4[25:21])
		  		begin
		  			A_4 = auxMem_1;
						forwarding_A4 = 1'b1;
		  		end

		  		if(instruction_1[20:16] == instruction_4[20:16])
		  		begin
		  			B_4 = auxMem_1;
						forwarding_B4 = 1'b1;
		  		end

		  		if(instruction_1[20:16] == instruction_5[25:21])
		  		begin
            A_5 = auxMem_1;
						forwarding_A5 = 1'b1;
		  		end

		  		if(instruction_1[20:16] == instruction_5[20:16])
		 			begin
            B_5 = auxMem_1;
						forwarding_B5 = 1'b1;
		  		end
				//End Load forwarding
				end

				else if(FSM2_1 == 16'h000C) // sw
				begin
					writeEnable_1 = 1'b1; // Enable the write on data memory
					writeEnable = writeEnable_1;
				end
			end

			if(FSM_2 == 3'b100) // Memory stage
			begin
				//Forwarding verification
				if(instruction_2[15:11] == instruction_1[25:21] && instruction_2[15:11] != 0)
				begin
					A_1 = aluOutput_2;
					forwarding_A1 = 1'b1;
				end

				if(instruction_2[15:11] == instruction_1[20:16] && instruction_2[15:11] != 0)
				begin
					B_1 = aluOutput_2;
					forwarding_B1 = 1'b1;
				end

				if(instruction_2[15:11] == instruction_3[25:21] && instruction_2[15:11] != 0)
				begin
					A_3 = aluOutput_2;
					forwarding_A3 = 1'b1;
				end

				if(instruction_2[15:11] == instruction_3[20:16] && instruction_2[15:11] != 0)
				begin
					B_3 = aluOutput_2;
					forwarding_B3 = 1'b1;
				end

				if(instruction_2[15:11] == instruction_4[25:21] && instruction_2[15:11] != 0)
				begin
					A_4 = aluOutput_2;
					forwarding_A4 = 1'b1;
				end

				if(instruction_2[15:11] == instruction_4[20:16] && instruction_2[15:11] != 0)
				begin
					B_4 = aluOutput_2;
					forwarding_B4 = 1'b1;
				end

				if(instruction_2[15:11] == instruction_5[25:21] && instruction_2[15:11] != 0)
				begin
					A_5 = aluOutput_2;
					forwarding_A5 = 1'b1;
				end

				if(instruction_2[15:11] == instruction_5[20:16] && instruction_2[15:11] != 0)
				begin
					B_5 = aluOutput_2;
					forwarding_B5 = 1'b1;
				end
				// End of forwarding stage

				if(FSM2_2 == 16'h000B) // lw
				begin
					writeEnable = writeEnable_2;
					auxMem_2 = out_mem_data;
          
          // Load forwarding
          if(instruction_2[20:16] == instruction_1[25:21])
		 			begin
		  			A_1 = auxMem_2;
						forwarding_A1 = 1'b1;
          end

          if(instruction_2[20:16] == instruction_1[20:16])
          begin
		  			B_1 = auxMem_2;
						forwarding_B1 = 1'b1;
		  		end

          if(instruction_2[20:16] == instruction_3[25:21])
          begin
      			A_3 = auxMem_2;
						forwarding_A3 = 1'b1;
		  		end

          if(instruction_2[20:16] == instruction_3[20:16])
		  		begin
		  			B_3 = auxMem_2;
						forwarding_B3 = 1'b1;
		  		end

          if(instruction_2[20:16] == instruction_4[25:21])
		  		begin
		  			A_4 = auxMem_2;
						forwarding_A4 = 1'b1;
		  		end

          if(instruction_2[20:16] == instruction_4[20:16])
		  		begin
		  			B_4 = auxMem_2;
						forwarding_B4 = 1'b1;
		  		end

          if(instruction_2[20:16] == instruction_5[25:21])
		  		begin
            A_5 = auxMem_2;
						forwarding_A5 = 1'b1;
		  		end

          if(instruction_2[20:16] == instruction_5[20:16])
		 			begin
            B_5 = auxMem_2;
						forwarding_B5 = 1'b1;
		  		end
				//End Load forwarding
				end

				else if(FSM2_2 == 16'h000C) // sw
				begin
					writeEnable_2 = 1'b1; // Enable the write on data memory
					writeEnable = writeEnable_2;
				end
			end

			if(FSM_3 == 3'b100) // Memory stage
			begin
				//Forwarding verification
				if(instruction_3[15:11] == instruction_1[25:21] && instruction_3[15:11] != 0)
				begin
					A_1 = aluOutput_3;
					forwarding_A1 = 1'b1;
				end

				if(instruction_3[15:11] == instruction_1[20:16] && instruction_3[15:11] != 0)
				begin
					B_1 = aluOutput_3;
					forwarding_B1 = 1'b1;
				end

				if(instruction_3[15:11] == instruction_2[25:21] && instruction_3[15:11] != 0)
				begin
					A_2 = aluOutput_3;
					forwarding_A2 = 1'b1;
				end

				if(instruction_3[15:11] == instruction_2[20:16] && instruction_3[15:11] != 0)
				begin
					B_2 = aluOutput_3;
					forwarding_B2 = 1'b1;
				end

				if(instruction_3[15:11] == instruction_4[25:21] && instruction_3[15:11] != 0)
				begin
					A_4 = aluOutput_3;
					forwarding_A4 = 1'b1;
				end

				if(instruction_3[15:11] == instruction_4[20:16] && instruction_3[15:11] != 0)
				begin
					B_4 = aluOutput_3;
					forwarding_B4 = 1'b1;
				end

				if(instruction_3[15:11] == instruction_5[25:21] && instruction_3[15:11] != 0)
				begin
					A_5 = aluOutput_3;
					forwarding_A5 = 1'b1;
				end

				if(instruction_3[15:11] == instruction_5[20:16] && instruction_3[15:11] != 0)
				begin
					B_5 = aluOutput_3;
					forwarding_B5 = 1'b1;
				end
				// End of forwarding stage

				if(FSM2_3 == 16'h000B) // lw
				begin
					writeEnable = writeEnable_3;
					auxMem_3 = out_mem_data;
          
          // Load forwarding
          if(instruction_3[20:16] == instruction_1[25:21])
		 			begin
		  			A_1 = auxMem_3;
						forwarding_A1 = 1'b1;
          end

          if(instruction_3[20:16] == instruction_1[20:16])
          begin
		  			B_1 = auxMem_3;
						forwarding_B1 = 1'b1;
		  		end

          if(instruction_3[20:16] == instruction_2[25:21])
          begin
      			A_2 = auxMem_3;
						forwarding_A2 = 1'b1;
		  		end

          if(instruction_3[20:16] == instruction_2[20:16])
		  		begin
		  			B_2 = auxMem_3;
						forwarding_B2 = 1'b1;
		  		end

          if(instruction_3[20:16] == instruction_4[25:21])
		  		begin
		  			A_4 = auxMem_3;
						forwarding_A4 = 1'b1;
		  		end

          if(instruction_3[20:16] == instruction_4[20:16])
		  		begin
		  			B_4 = auxMem_3;
						forwarding_B4 = 1'b1;
		  		end

          if(instruction_3[20:16] == instruction_5[25:21])
		  		begin
            A_5 = auxMem_3;
						forwarding_A5 = 1'b1;
		  		end

          if(instruction_3[20:16] == instruction_5[20:16])
		 			begin
            B_5 = auxMem_3;
						forwarding_B5 = 1'b1;
		  		end
				//End Load forwarding
				end

				else if(FSM2_3 == 16'h000C) // sw
				begin
					writeEnable_3 = 1'b1; // Enable the write on data memory
					writeEnable = writeEnable_3;
				end
			end

			if(FSM_4 == 3'b100) // Memory stage
			begin
				//Forwarding verification
				if(instruction_4[15:11] == instruction_1[25:21] && instruction_4[15:11] != 0)
				begin
					A_1 = aluOutput_4;
					forwarding_A1 = 1'b1;
				end

				if(instruction_4[15:11] == instruction_1[20:16] && instruction_4[15:11] != 0)
				begin
					B_1 = aluOutput_4;
					forwarding_B1 = 1'b1;
				end

				if(instruction_4[15:11] == instruction_2[25:21] && instruction_4[15:11] != 0)
				begin
					A_2 = aluOutput_4;
					forwarding_A2 = 1'b1;
				end

				if(instruction_4[15:11] == instruction_2[20:16] && instruction_4[15:11] != 0)
				begin
					B_2 = aluOutput_4;
					forwarding_B2 = 1'b1;
				end

				if(instruction_4[15:11] == instruction_3[25:21] && instruction_4[15:11] != 0)
				begin
					A_3 = aluOutput_4;
					forwarding_A3 = 1'b1;
				end

				if(instruction_4[15:11] == instruction_3[20:16] && instruction_4[15:11] != 0)
				begin
					B_3 = aluOutput_4;
					forwarding_B3 = 1'b1;
				end

				if(instruction_4[15:11] == instruction_5[25:21] && instruction_4[15:11] != 0)
				begin
					A_5 = aluOutput_4;
					forwarding_A5 = 1'b1;
				end

				if(instruction_4[15:11] == instruction_5[20:16] && instruction_4[15:11] != 0)
				begin
					B_5 = aluOutput_4;
					forwarding_B5 = 1'b1;
				end
				// End of forwarding stage

				if(FSM2_4 == 16'h000B) // lw
				begin
					writeEnable = writeEnable_4;
					auxMem_4 = out_mem_data;
          
          // Load forwarding
          if(instruction_4[20:16] == instruction_1[25:21])
		 			begin
		  			A_1 = auxMem_4;
						forwarding_A1 = 1'b1;
          end

          if(instruction_4[20:16] == instruction_1[20:16])
          begin
		  			B_1 = auxMem_4;
						forwarding_B1 = 1'b1;
		  		end

          if(instruction_4[20:16] == instruction_2[25:21])
          begin
      			A_2 = auxMem_4;
						forwarding_A2 = 1'b1;
		  		end

          if(instruction_4[20:16] == instruction_2[20:16])
		  		begin
		  			B_2 = auxMem_4;
						forwarding_B2 = 1'b1;
		  		end

          if(instruction_4[20:16] == instruction_3[25:21])
		  		begin
		  			A_3 = auxMem_4;
						forwarding_A3 = 1'b1;
		  		end

          if(instruction_4[20:16] == instruction_3[20:16])
		  		begin
		  			B_3 = auxMem_4;
						forwarding_B3 = 1'b1;
		  		end

          if(instruction_4[20:16] == instruction_5[25:21])
		  		begin
            A_5 = auxMem_4;
						forwarding_A5 = 1'b1;
		  		end

          if(instruction_4[20:16] == instruction_5[20:16])
		 			begin
            B_5 = auxMem_4;
						forwarding_B5 = 1'b1;
		  		end
				//End Load forwarding
				end

				else if(FSM2_4 == 16'h000C) // sw
				begin
					writeEnable_4 = 1'b1; // Enable the write on data memory
					writeEnable = writeEnable_4;
				end
			end

			if(FSM_5 == 3'b100) // Memory stage
			begin
				//Forwarding verification
				if(instruction_5[15:11] == instruction_1[25:21] && instruction_5[15:11] != 0)
				begin
					A_1 = aluOutput_5;
					forwarding_A1 = 1'b1;
				end

				if(instruction_5[15:11] == instruction_1[20:16] && instruction_5[15:11] != 0)
				begin
					B_1 = aluOutput_5;
					forwarding_B1 = 1'b1;
				end

				if(instruction_5[15:11] == instruction_2[25:21] && instruction_5[15:11] != 0)
				begin
					A_2 = aluOutput_5;
					forwarding_A2 = 1'b1;
				end

				if(instruction_5[15:11] == instruction_2[20:16] && instruction_5[15:11] != 0)
				begin
					B_2 = aluOutput_5;
					forwarding_B2 = 1'b1;
				end

				if(instruction_5[15:11] == instruction_3[25:21] && instruction_5[15:11] != 0)
				begin
					A_3 = aluOutput_5;
					forwarding_A3 = 1'b1;
				end

				if(instruction_5[15:11] == instruction_3[20:16] && instruction_5[15:11] != 0)
				begin
					B_3 = aluOutput_5;
					forwarding_B3 = 1'b1;
				end

				if(instruction_5[15:11] == instruction_4[25:21] && instruction_5[15:11] != 0)
				begin
					A_4 = aluOutput_5;
					forwarding_A4 = 1'b1;
				end

				if(instruction_5[15:11] == instruction_4[20:16] && instruction_5[15:11] != 0)
				begin
					B_4 = aluOutput_5;
					forwarding_B4 = 1'b1;
				end
				// End of forwarding stage

				if(FSM2_5 == 16'h000B) // lw
				begin
					writeEnable = writeEnable_5;
					auxMem_5 = out_mem_data;
          
          // Load forwarding
          if(instruction_5[20:16] == instruction_1[25:21])
		 			begin
		  			A_1 = auxMem_5;
						forwarding_A1 = 1'b1;
          end

          if(instruction_5[20:16] == instruction_1[20:16])
          begin
		  			B_1 = auxMem_5;
						forwarding_B1 = 1'b1;
		  		end

          if(instruction_5[20:16] == instruction_2[25:21])
          begin
      			A_2 = auxMem_5;
						forwarding_A2 = 1'b1;
		  		end

          if(instruction_5[20:16] == instruction_2[20:16])
		  		begin
		  			B_2 = auxMem_5;
						forwarding_B2 = 1'b1;
		  		end

          if(instruction_5[20:16] == instruction_3[25:21])
		  		begin
		  			A_3 = auxMem_5;
						forwarding_A3 = 1'b1;
		  		end

          if(instruction_5[20:16] == instruction_3[20:16])
		  		begin
		  			B_3 = auxMem_5;
						forwarding_B3 = 1'b1;
		  		end

          if(instruction_5[20:16] == instruction_4[25:21])
		  		begin
            A_4 = auxMem_5;
						forwarding_A4 = 1'b1;
		  		end

          if(instruction_5[20:16] == instruction_4[20:16])
		 			begin
            B_4 = auxMem_5;
						forwarding_B4 = 1'b1;
		  		end
				//End Load forwarding
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
					registers[instruction_2[20:16]] = auxMem_2;
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
					registers[instruction_3[20:16]] = auxMem_3;
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
					registers[instruction_4[20:16]] = auxMem_4;
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
					registers[instruction_5[20:16]] = auxMem_5;
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
