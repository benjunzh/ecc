`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    11:01:47 08/28/2020
// Design Name:
// Module Name:    add
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
module add(
           DIN1,
           DIN2,
           DOUT
       );
input [232 : 0] DIN1;
input [232 : 0] DIN2;
output [232 : 0] DOUT;
assign DOUT = DIN1 ^ DIN2;

endmodule
