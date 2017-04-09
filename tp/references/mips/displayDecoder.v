module displayDecoder(

	input[31:0]		entrada,
	input zero,
	output reg [6:0]		saida0, saida1, saida2, saida3, saida4, saida5, saida6, saida7
);


	always@(entrada) //sempre que mudar a entrada
	begin
			saida0[5] = ~(entrada[0]);
			saida0[0] = ~(entrada[1]);
			saida0[1] = ~(entrada[2]);			saida0[2] = ~(entrada[3]);
			saida0[3] = ~(entrada[4]);
			saida0[4] = ~(entrada[5]);
			saida0[6] = ~(entrada[6]);
			saida1[5] = ~(entrada[7]);
			saida1[0] = ~(entrada[8]);
			saida1[1] = ~(entrada[9]);
			saida1[2] = ~(entrada[10]);
			saida1[3] = ~(entrada[11]);
			saida1[4] = ~(entrada[12]);
			saida1[6] = ~(entrada[13]);
			saida2[5] = ~(entrada[14]);
			saida2[0] = ~(entrada[15]);
			saida2[1] = ~(entrada[16]);
			saida2[2] = ~(entrada[17]);
			saida2[3] = ~(entrada[18]);
			saida2[4] = ~(entrada[19]);
			saida2[6] = ~(entrada[20]);
			saida3[5] = ~(entrada[21]);
			saida3[0] = ~(entrada[22]);
			saida3[1] = ~(entrada[23]);
			saida3[2] = ~(entrada[24]);
			saida3[3] = ~(entrada[25]);
			saida3[4] = ~(entrada[26]);
			saida3[6] = ~(entrada[27]);
			saida4[5] = ~(entrada[28]);
			saida4[0] = ~(entrada[29]);
			saida4[1] = ~(entrada[30]);
			saida4[2] = ~(entrada[31]);
			saida4[3] = ~(zero);
			saida4[4] = 1'b1;
			saida4[6] = 1'b1;
			saida5[5] = 1'b1;
			saida5[0] = 1'b1;
			saida5[1] = 1'b1;
			saida5[2] = 1'b1;
			saida5[3] = 1'b1;
			saida5[4] = 1'b1;
			saida5[6] = 1'b1;
			saida6[5] = 1'b1;
			saida6[0] = 1'b1;
			saida6[1] = 1'b1;
			saida6[2] = 1'b1;
			saida6[3] = 1'b1;
			saida6[4] = 1'b1;
			saida6[6] = 1'b1;
			saida7[5] = 1'b1;
			saida7[0] = 1'b1;
			saida7[1] = 1'b1;
			saida7[2] = 1'b1;
			saida7[3] = 1'b1;
			saida7[4] = 1'b1;
			saida7[6] = 1'b1;
	end
    
endmodule

/*

HEX 7 Schema:
    0
	___
 5|	| 1
  | 6 |
   ___
 4|	| 2
  |	|
	___
    3


*/