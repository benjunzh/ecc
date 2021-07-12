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
module select4to1(
           SEL,
           A,
           B,
           C,
           D,
           OUT
       );
parameter N = 233; //位宽
input [1: 0] SEL;
input [N - 1 : 0] A;
input [N - 1 : 0] B;
input [N - 1 : 0] C;
input [N - 1 : 0] D;
output [N - 1 : 0] OUT;

assign OUT = (SEL == 2'b00) ? D : (SEL == 2'b01) ? C : (SEL == 2'b10) ? B : A;
endmodule
