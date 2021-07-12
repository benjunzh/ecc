`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    2020-01-03
// Design Name:
// Module Name:    REGISTER
// Project Name:
// Target Devices:
// Tool versions:
// Description: If LOAD=1, output IN at posedge of CLK
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module register(
           CLK,
           CLEAR,
           LOAD,
           OUT,
           IN );

parameter N = 233; //位宽
input CLK, CLEAR, LOAD;
input [N - 1 : 0] IN;
output [N - 1 : 0] OUT;
reg [N - 1 : 0] OUT;

always @(posedge CLK) begin
    if (CLEAR)begin
    	OUT <= 0;
    end
    else if (LOAD)begin
    	OUT <= IN;
    end
    else begin
    	OUT <= OUT;
    end
end

endmodule
