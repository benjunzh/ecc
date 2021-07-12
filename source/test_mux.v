`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    10:02:06 11/19/2020
// Design Name:
// Module Name:    test_mux
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
module test_mux(
           input clk,
           input rst,
           input [232: 0] A,
           input [232: 0] B,
           input sel,
           output reg [232: 0] T1,
           output reg [232: 0] T2,
       );

wire [232: 0] T_tmp;

always @(posedge clk) begin
    if (rst) begin
        T1 <= 0;
        T2 <= 0;
    end
    else begin
        if (sel == 0) begin
            T1 <= T_tmp;
        end
        else begin
            T2 <= T_tmp;
        end
    end
end

square P_AD_squa1( .DIN(A),
                   .DOUT(T1_tmp));

select squa_sel(
           .SEL(sel),
           .A(A),
           .B(B),
           .OUT(T_tmp)
       );
endmodule
