`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    2020-01-03
// Design Name:
// Module Name:    SELECT
// Project Name:
// Target Devices:
// Tool versions:
// Description: SEL=1, output A. SEL=0, output B.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module select(
           SEL,
           A,
           B,
           OUT
       );
parameter N = 233; //位宽
input SEL;
input [N - 1 : 0] A;
input [N - 1 : 0] B;
output [N - 1 : 0] OUT;

assign OUT = SEL ? A : B;




endmodule
