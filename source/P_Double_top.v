`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    22:36:26 12/03/2020
// Design Name:
// Module Name:    P_Double_top
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
module P_Double_top(
           CLK,
           RST_N,
           IN_VALID,
           DIN_X,
           DIN_Z,
           DOUT_X,
           DOUT_Z,
           OUT_VALID
       );

parameter N = 233; //位宽
parameter
    IDLE = 4'b0000,
    INIT = 4'b0001,
    START = 4'b0010,
    S1 = 4'b0011,
    S2 = 4'b0100,
    S3 = 4'b0101,
    S4 = 4'b0110,
    OUTPUT = 4'b0111;

input CLK;
input RST_N;
input IN_VALID;
input [N - 1: 0] DIN_X;
input [N - 1: 0] DIN_Z;
output reg OUT_VALID;
output [N - 1: 0] DOUT_X;
output [N - 1: 0] DOUT_Z;

//乘法器
wire ERROR;
wire MUL_IN_VALID;
wire MUL_OUT_VALID;
wire [N - 1: 0] DOUT_MULT;

//寄存器
wire X1Clear, X1Load;
wire Z1Clear, Z1Load;
//wire T1Clear, T1Load;
wire [N - 1: 0] reg_Z1_out;
wire [N - 1: 0] reg_X1_out;
wire [N - 1: 0] reg_T1_out;

//加法器
wire [N - 1: 0] DOUT_ADD;

//平方器
wire [N - 1: 0] squa_X1_out;
wire [N - 1: 0] squa_Z1_out;

//选择器
wire [N - 1: 0] X1_sel_out;
wire [N - 1: 0] Z1_sel_out;
wire [1: 0] X1_sel;
wire Z1_sel;

wire [3: 0] fsm_out_state;

P_Double_fsm PDouble_fsm(
                 .CLK(CLK),
                 .RST_N(RST_N),
                 .ERROR(ERROR),
                 .MUL_OUT_VALID(MUL_OUT_VALID),
                 .IN_VALID(IN_VALID),
                 .X1Clear(X1Clear),
                 .X1Load(X1Load),
                 .Z1Clear(Z1Clear),
                 .Z1Load(Z1Load),
                 //.T1Clear(T1Clear),
                 // .T1Load(T1Load),
                 .MUL_IN_VALID(MUL_IN_VALID),
                 .OUT_STATE(fsm_out_state),
                 .X1_sel(X1_sel),
                 .Z1_sel(Z1_sel)
             );

mul_fault PDouble_mult1( .CLK(CLK),
                         .RST_N(RST_N),
                         .A(reg_Z1_out),
                         .B(reg_X1_out),
                         .IN_VALID(MUL_IN_VALID),
                         .DOUT(DOUT_MULT),
                         .OUT_VALID(MUL_OUT_VALID),
                         .ERROR(ERROR)
                       );

register PDouble_X1(
             .CLK(CLK),
             .CLEAR(X1Clear),
             .LOAD(X1Load),
             .OUT(reg_X1_out),
             .IN(X1_sel_out) );

register PDouble_Z1(
             .CLK(CLK),
             .CLEAR(Z1Clear),
             .LOAD(Z1Load),
             .OUT(reg_Z1_out),
             .IN(Z1_sel_out) );

// register PDouble_T1(
//              .CLK(CLK),
//              .CLEAR(T1Clear),
//              .LOAD(T1Load),
//              .OUT(reg_T1_out),
//              .IN(DOUT_MULT) );

square PDouble_squaX1( .DIN(reg_X1_out),
                       .DOUT(squa_X1_out));

square PDouble_squaZ1( .DIN(reg_Z1_out),
                       .DOUT(squa_Z1_out));

select3to1 PDouble_X1_sel(
               .SEL(X1_sel),
               .A(DIN_X),
               .B(squa_X1_out),
               .C(DOUT_ADD),
               .OUT(X1_sel_out)
           );

select PDouble_Z1_sel(
           .SEL(Z1_sel),
           .A(DIN_Z),
           .B(squa_Z1_out),
           .OUT(Z1_sel_out)
       );

//加法器
add P_AD_adder1(
        .DIN1(reg_X1_out),
        .DIN2(reg_Z1_out),
        .DOUT(DOUT_ADD)
    );

assign DOUT_X = reg_X1_out;
assign DOUT_Z = DOUT_MULT;

always @(posedge CLK) begin
    if (!RST_N) begin
        OUT_VALID <= 0;
    end
    else begin
        //$display("reg_X1_out=%h\n, reg_Z1_out=%h\n",reg_X1_out, reg_Z1_out);
        if (fsm_out_state == OUTPUT) begin
            OUT_VALID <= 1;
            $display("P_Double_top\nDOUT_X=%h\n, DOUT_Z=%h\n", DOUT_X, DOUT_Z);
        end
        else begin
            OUT_VALID <= 1'b0;
        end
    end
end
endmodule
