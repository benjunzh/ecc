`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    15:29:39 12/04/2020
// Design Name:
// Module Name:    PV_top
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
module PV_top(
           CLK,
           RST_N,
           mode,
           DIN_P1_X,
           DIN_P1_Z,
           DIN_P2_X,
           DIN_P2_Z,
           IN_VALID,
           SUCCESS,
           OUT_VALID
       );


//DIN_P1_X存储x
//DIN_P2_Z存储y
parameter N = 233; //位宽
parameter
    IDLE = 4'b0000,
    INIT = 4'b0001,
    START = 4'b0011,
    S1 = 4'b0010,
    S2 = 4'b0110,
    S3 = 4'b0111,
    S4 = 4'b0101,
    S5 = 4'b0100,
    S6 = 4'b1100,
    OUTPUT = 4'b1101;

input CLK;
input RST_N;
input mode;
input IN_VALID;
input [N - 1: 0] DIN_P1_X;
input [N - 1: 0] DIN_P1_Z;
input [N - 1: 0] DIN_P2_X;
input [N - 1: 0] DIN_P2_Z;

output reg SUCCESS;
output reg OUT_VALID;
//////////////////////////////////////////////

//乘法器1
wire MUL1_IN_VALID;
wire MUL1_OUT_VALID;
wire [N - 1: 0] DOUT_MUL1;
wire ERROR1;

//////////////////////////////////////////////

// 乘法器1输入选择器
wire mul11_sel;
wire mul12_sel;
wire [N - 1: 0] mul11_sel_out;
wire [N - 1: 0] mul12_sel_out;
//////////////////////////////////////////////

//平方器
wire [N - 1: 0] DOUT_SQUA1;
wire [N - 1: 0] DOUT_SQUA2;
//////////////////////////////////////////////

//加法器
wire [N - 1: 0] DOUT_ADD1;
wire [N - 1: 0] add12_sel_out;

//寄存器
wire X1Clear, X1Load;
wire X2Clear, X2Load;
wire Z1Clear, Z1Load;
wire Z2Clear, Z2Load;
wire [N - 1: 0] X1;
wire [N - 1: 0] X2;
wire [N - 1: 0] Z1;
wire [N - 1: 0] Z2;

//寄存器输入选择器
wire [1: 0] X1_sel;
wire [1: 0] X2_sel;
wire Z2_sel;
wire [N - 1: 0] X1_sel_out;
wire [N - 1: 0] X2_sel_out;
wire [N - 1: 0] Z2_sel_out;

//状态机
wire [3: 0] fsm_out_state;


///////////////// 例化 ////////////////////////
PV_fsm PV_fsm1(
           .CLK(CLK),
           .RST_N(RST_N),
           .ERROR1(ERROR1),
           .ERROR2(ERROR2),
           .MUL1_OUT_VALID(MUL1_OUT_VALID),
           .mode(mode),
           .IN_VALID(IN_VALID),
           .mul11_sel(mul11_sel),
           .mul12_sel(mul12_sel),
           .add12_sel(add12_sel),
           .X1_sel(X1_sel),
           .X2_sel(X2_sel),
           .Z2_sel(Z2_sel),
           .X1Clear(X1Clear),
           .X1Load(X1Load),
           .X2Clear(X2Clear),
           .X2Load(X2Load),
           .Z1Clear(Z1Clear),
           .Z1Load(Z1Load),
           .Z2Clear(Z2Clear),
           .Z2Load(Z2Load),
           .MUL1_IN_VALID(MUL1_IN_VALID),
           .OUT_STATE(fsm_out_state)
       );
//////////////////////////////////////////////
//寄存器
register PV_X1(
             .CLK(CLK),
             .CLEAR(X1Clear),
             .LOAD(X1Load),
             .OUT(X1),
             .IN(X1_sel_out) );

register PV_X2(
             .CLK(CLK),
             .CLEAR(X2Clear),
             .LOAD(X2Load),
             .OUT(X2),
             .IN(X2_sel_out) );
register PV_Z1(
             .CLK(CLK),
             .CLEAR(Z1Clear),
             .LOAD(Z1Load),
             .OUT(Z1),
             .IN(DIN_P1_Z) );

register PV_Z2(
             .CLK(CLK),
             .CLEAR(Z2Clear),
             .LOAD(Z2Load),
             .OUT(Z2),
             .IN(Z2_sel_out) );

//寄存器输入选择器
select3to1 PV_X1_sel(
               .SEL(X1_sel),
               .A(DOUT_MUL1),
               .B(DOUT_ADD1),
               .C(DIN_P1_X),
               .OUT(X1_sel_out)
           );
select3to1 PV_X2_sel(
               .SEL(X2_sel),
               .A(DOUT_MUL1),
               .B(DOUT_SQUA1),
               .C(DIN_P2_X),
               .OUT(X2_sel_out)
           );
select PV_Z2_sel(
           .SEL(Z2_sel),
           .A(DOUT_SQUA2),
           .B(DIN_P2_Z),
           .OUT(Z2_sel_out)
       );

//平方器
square PV_squa1( .DIN(X1),
                 .DOUT(DOUT_SQUA1));
square PV_squa2( .DIN(Z2),
                 .DOUT(DOUT_SQUA2));

//乘法器例化
mul_fault PV_mult1( .CLK(CLK),
                    .RST_N(RST_N),
                    .A(mul11_sel_out),
                    .B(mul12_sel_out),
                    .IN_VALID(MUL1_IN_VALID),
                    .DOUT(DOUT_MUL1),
                    .OUT_VALID(MUL1_OUT_VALID),
                    .ERROR(ERROR1)
                  );

//乘法器输入选择器
select PV_mul_in11_sel(
           .SEL(mul11_sel),
           .A(X1),
           .B(Z1),
           .OUT(mul11_sel_out)
       );
select PV_mul_in12_sel(
           .SEL(mul12_sel),
           .A(Z2),
           .B(X2),
           .OUT(mul12_sel_out)
       );

//加法器
add PV_adder1(
        .DIN1(X1),
        .DIN2(add12_sel_out),
        .DOUT(DOUT_ADD1)
    );

//加法器输入选择器
select PV_adder_in12_sel(
           .SEL(add12_sel),
           .A(Z2),
           .B(X2),
           .OUT(add12_sel_out)
       );

always @(posedge CLK) begin
    if (!RST_N) begin
        OUT_VALID <= 1'b0;
        SUCCESS <= 0;
    end
    else begin
        if (fsm_out_state == OUTPUT) begin
            OUT_VALID <= 1;
            $display("mode=%d\n",mode);
            if (mode == 0 && X1 == X2) begin
            	$display($time, "\nX1=%h\nX2=%h\n\n", X1, X2);
                SUCCESS <= 1;
            end
            else if (mode == 1 && X1 == 1) begin
                SUCCESS <= 1;
                $display("point vertification success\n");
            end
            else begin
                SUCCESS <= 0;
                $display("SUCCESS = 0\n");
            end
        end
        else begin
        	OUT_VALID <= 0;
            SUCCESS <= 0;
        end
    end
end
endmodule
