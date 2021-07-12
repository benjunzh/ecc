`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    10:56:02 09/30/2020
// Design Name:
// Module Name:    select4to1
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module select5to1(
           SEL,
           A,
           B,
           C,
           D,
           E,
           OUT
       );
parameter N = 233; //位宽
input [2: 0] SEL;
input [N - 1 : 0] A;
input [N - 1 : 0] B;
input [N - 1 : 0] C;
input [N - 1 : 0] D;
input [N - 1 : 0] E;
output [N - 1 : 0] OUT;

assign OUT = (SEL == 3'b000) ? E : (SEL == 3'b001) ? D : (SEL == 3'b010) ? C : (SEL == 3'b011) ? B:A;
endmodule
