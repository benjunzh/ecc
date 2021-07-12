`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    11:05:11 12/04/2020
// Design Name:
// Module Name:    axis_translate_fault
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
module axis_translate_fault(
           CLK,
           RST_N,
           IN_VALID,
           DIN_P_x,
           DIN_P_z,
           reg_X1_out,
           OUT_VALID
       );

parameter N = 233; //位宽

input CLK;
input RST_N;
input IN_VALID;
input [N - 1: 0] DIN_P_x;
input [N - 1: 0] DIN_P_z;
output OUT_VALID;
output [N - 1: 0] reg_X1_out;

//乘法器
wire ERROR;

mul_fault Trans_fault_mult1( .CLK(CLK),
                             .RST_N(RST_N),
                             .A(DIN_P_x),
                             .B(DIN_P_z),
                             .IN_VALID(IN_VALID),
                             .DOUT(reg_X1_out),
                             .OUT_VALID(OUT_VALID),
                             .ERROR(ERROR)
                           );

endmodule
