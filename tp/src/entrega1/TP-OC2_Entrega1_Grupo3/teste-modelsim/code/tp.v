module tp(
input CLOCK_50, // FPGA Clock 50 MHz
//input [3:0] KEY, // FPGA KEY input (for FPGA testing)
output [8:0] LEDG, // Green led (Clock [25] counter)
output [6:0] HEX0, // First seven segments display
output [6:0] HEX1 // Second seven segments display
);

reg [3:0] KEY = 3'b000; // ModelSim Simulation on Key[0] of FPGA input

reg [31:0] clk = 32'd0; // Clock
reg [2:0] FSM; // Finite State Machine -> tells which stage the processor is (IF, ID, EX, MEMl, WB)
reg [15:0] FSM2; // Finite State Machine (auxiliar) -> tells which OpCode
integer i; // Auxiliar to the for loop

reg [9:0] pc; // Program Counter (goes 1 to 1)
reg [31:0] instruction; // Instruction input
reg [31:0] registers [31:0]; // Register bank
reg [31:0] aluOutput; // Output of the ALU
reg Zero; // Branch auxiliar
reg [31:0] A; // First operand
reg [31:0] B; // Second operand
reg [15:0] imm; // Immediate operand
reg [25:0] jmem; // Jump memory address

wire [31:0] out_mem_inst; // Memory instruction input

mem_inst mem_i(.address(pc),.clock(clk[0]),.q(out_mem_inst));

displayDecoder DP7_0(.entrada(registers[0][2:0]),.saida(HEX0));
displayDecoder DP7_1(.entrada(FSM),.saida(HEX1));

	assign LEDG[0] = clk[1];

	always@(posedge CLOCK_50)
	begin
		clk = clk + 1;
	end

	always@(posedge clk[1])
	begin
		if(KEY[0] == 0)
		begin
			FSM = 3'b001;
			FSM2 = 16'h0000;
			aluOutput = 32'd0;
			Zero = 1'b0;

			pc = 10'd0;
			instruction = 32'd0;

			for(i = 0; i < 32; i = i + 1)
			begin
				registers[i] = i;
			end

			KEY[0] = 1;
		end

		else
		begin
			if(FSM == 3'b001) // Instruction fetch
			begin
				pc = pc + 1;
				instruction = out_mem_inst;
				FSM = 3'd2;
				FSM2 = 16'h0000;
			end

			else if(FSM == 3'b010) // Instruction decode
			begin
				// R-Type Instructions
				if(instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100000) // add instruction
				begin
					FSM2 = 16'h0001; // add
					A = registers[instruction[25:21]];
					B = registers[instruction[20:16]];
				end

				else if(instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100010) // sub instruction
				begin
					FSM2 = 16'h0002; // sub
					A = registers[instruction[25:21]];
					B = registers[instruction[20:16]];
				end

				else if(instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100100) // and instruction
				begin
					FSM2 = 16'h0003; // and
					A = registers[instruction[25:21]];
					B = registers[instruction[20:16]];

				end

				else if(instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100111) // nor instruction
				begin
					FSM2 = 16'h0004; // nor
					A = registers[instruction[25:21]];
					B = registers[instruction[20:16]];
				end

				else if(instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100110) // xor instruction
				begin
					FSM2 = 16'h0005; // xor
					A = registers[instruction[25:21]];
					B = registers[instruction[20:16]];
				end

				else if(instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b101010) // slt instruction
				begin
					FSM2 = 16'h0006; // slt
					A = registers[instruction[25:21]];
					B = registers[instruction[20:16]];
				end

				else if(instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b000000) // sll instruction
				begin
					FSM2 = 16'h0007; // sll
					A = registers[instruction[25:21]];
					B = registers[instruction[10:6]];
				end

				else if(instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b000010) // srl instruction
				begin
					FSM2 = 16'h0008; // srl
					A = registers[instruction[25:21]];
					B = registers[instruction[10:6]];
				end

				else if(instruction[31:26] == 6'b000000 && instruction[5:0] == 6'b100101) // or instruction
				begin
					FSM2 = 16'h0009; // or
					A = registers[instruction[25:21]];
					B = registers[instruction[20:16]];

				end
				// End R-Type Instructions

				// I-Type Instructions
				else if(instruction[31:26] == 6'b001000) // addi instruction
				begin
					FSM2 = 16'h000A; // addi
					A = registers[instruction[25:21]];
					//B = registers[instruction[20:16]];
					imm = instruction[15:0];
				end

				else if(instruction[31:26] == 6'b100011) // lw instruction
				begin
					FSM2 = 16'h000B; // lw
					A = registers[instruction[25:21]];
					//B = registers[instruction[20:16]];
					imm = instruction[15:0];
				end

				else if(instruction[31:26] == 6'b101011) // sw instruction
				begin
					FSM2 = 16'h000C; // sw
					A = registers[instruction[20:16]];
					//B = registers[instruction[25:21]];
					imm = instruction[15:0];
				end

				else if(instruction[31:26] == 6'b001100) // andi instruction
				begin
					FSM2 = 16'h000D; // andi
					A = registers[instruction[25:21]];
					//B = registers[instruction[20:16]];
					imm = instruction[15:0];
				end

				else if(instruction[31:26] == 6'b001101) // ori instruction
				begin
					FSM2 = 16'h000E; // ori
					A = registers[instruction[25:21]];
					//B = registers[instruction[20:16]];
					imm = instruction[15:0];
				end

				else if(instruction[31:26] == 6'b001010) // slti instruction
				begin
					FSM2 = 16'h000F; // slti
					A = registers[instruction[25:21]];
					//B = registers[instruction[20:16]];
					imm = instruction[15:0];
				end

				else if(instruction[31:26] == 6'b000100) // beq instruction
				begin
					FSM2 = 16'h0010; // beq
					A = registers[instruction[25:21]];
					B = registers[instruction[20:16]];
					imm = instruction[15:0];
				end

				else if(instruction[31:26] == 6'b000101) // bne instruction
				begin
					FSM2 = 16'h0011; // bne
					A = registers[instruction[25:21]];
					B = registers[instruction[20:16]];
					imm = instruction[15:0];
				end
				// End I-Type Instructions

				// J-Type Instructions
				else if(instruction[31:26] == 6'b000010) // j
				begin
					FSM2 = 16'h0012; // j
					jmem = instruction[25:0];
				end
				// End J-Type Instructions

				FSM = 3'b011;
			end

			else if(FSM == 3'b011) // Execute
			begin
				if(FSM2 == 16'h0001)// execute add
				begin
					aluOutput = A + B;
				end

				if(FSM2 == 16'h0002)// execute sub
				begin
					aluOutput = A - B;
				end

				if(FSM2 == 16'h0003)// execute and
				begin
					aluOutput = A & B;
				end

				if(FSM2 == 16'h0004)// execute nor
				begin
					aluOutput = ~(A | B);
				end

				if(FSM2 == 16'h0005)// execute xor
				begin
					aluOutput = A ^ B;
				end

				if(FSM2 == 16'h0006)// execute slt
				begin
					if(A < B)
					begin
						aluOutput = 32'd1;
					end

					else
					begin
						aluOutput = 32'd0;
					end
				end

				if(FSM2 == 16'h0007)// execute sll
				begin
					aluOutput = A << B;
				end

				if(FSM2 == 16'h0008)// execute srl
				begin
					aluOutput = A >> B;
				end

				if(FSM2 == 16'h0009)// execute or
				begin
					aluOutput = A | B;
				end

				if(FSM2 == 16'h000A)// execute addi
				begin
					aluOutput = A + imm;
				end

				if(FSM2 == 16'h000B)// execute lw
				begin
					aluOutput = A + imm;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput[i] = aluOutput[15];
					end
				end

				if(FSM2 == 16'h000C)// execute sw
				begin
					aluOutput = A + imm;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput[i] = aluOutput[15];
					end
				end

				if(FSM2 == 16'h000D)// execute andi
				begin
					aluOutput = A & imm;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput[i] = aluOutput[15];
					end
				end

				if(FSM2 == 16'h000E)// execute ori
				begin
					aluOutput = A | imm;

					for(i = 16; i < 32; i = i + 1)
					begin
						aluOutput[i] = aluOutput[15];
					end
				end

				if(FSM2 == 16'h000F)// execute slti
				begin
					if(A < imm)
					begin
						aluOutput = 32'd1;
					end

					else
					begin
						aluOutput = 32'd0;
					end
				end

				if(FSM2 == 16'h0010)// execute beq
				begin
					if((A - B) == 0)
					begin
						Zero = 1'b1;
						aluOutput = (pc + 1) + imm;
					end

					else
					begin
						Zero = 1'b0;
						aluOutput = 0;
					end
				end

				if(FSM2 == 16'h0011)// execute bne
				begin
					if((A - B) != 0)
					begin
						Zero = 1'b1;
						aluOutput = (pc + 1) + imm;
					end

					else
					begin
						Zero = 1'b0;
						aluOutput = 0;
					end
				end

				if(FSM2 == 16'h0012)// execute j
				begin
					aluOutput = jmem << 2;
					pc = pc + 1;

					aluOutput[28] = pc[6];
					aluOutput[29] = pc[7];
					aluOutput[30] = pc[8];
					aluOutput[31] = pc[9];
					
					pc = pc - 1; // Rescuing the value of pc
				end

				FSM = 3'b001;
			end
		end
	end
endmodule
