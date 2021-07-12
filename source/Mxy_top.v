`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    19:47:11 09/29/2020
// Design Name:
// Module Name:    Mxy_top
// Project Name:
// Target Devices:
// Tool versions:
// Description:
// calculate the y cordinate
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module Mxy_top(
           CLK,
           RST_N,
           DIN_P1_X,
           DIN_P1_Z,
           DIN_P2_X,
           DIN_P2_Z,
           DIN_P_x,
           DIN_P_y,
           IN_VALID,
           OUT_VALID,
           DOUT_x,
           DOUT_y
       );

parameter N = 233; //位宽
parameter
    PRE_JUDGE = 5'b11001,
    END = 5'b10011;

input CLK;
input RST_N;
input [N - 1: 0] DIN_P1_X;
input [N - 1: 0] DIN_P1_Z;
input [N - 1: 0] DIN_P2_X;
input [N - 1: 0] DIN_P2_Z;
input [N - 1: 0] DIN_P_x;
input [N - 1: 0] DIN_P_y;
input IN_VALID;
output reg OUT_VALID;
output reg [N - 1: 0] DOUT_x;
output reg [N - 1: 0] DOUT_y;

//输入存储
reg [N - 1: 0] T1;
reg [N - 1: 0] T2;

reg Z1_zero;
reg Z2_zero;

wire [4 : 0] fsm_out_state;

//////////////////////////////////////////////

//乘法器1
wire MUL1_IN_VALID;
wire MUL1_OUT_VALID;
wire [N - 1: 0] DOUT_MUL1;
wire ERROR1;

// 乘法器1输入选择器
wire [1: 0] mul11_sel;
wire mul12_sel;
wire [N - 1: 0] mul11_sel_out;
wire [N - 1: 0] mul12_sel_out;

//////////////////////////////////////////////

//乘法器2
wire MUL2_IN_VALID;
wire MUL2_OUT_VALID;
wire [N - 1: 0] DOUT_MUL2;
wire ERROR2;

// 乘法器2输入选择器
wire mul21_sel;
wire [1: 0] mul22_sel;
wire [N - 1: 0] mul21_sel_out;
wire [N - 1: 0] mul22_sel_out;
//////////////////////////////////////////////

//求逆器
wire [N - 1: 0] DOUT_INV;
wire INV_IN_VALID;
wire INV_OUT_VALID;
//////////////////////////////////////////////

//平方器
wire [N - 1: 0] DOUT_SQUA;
//////////////////////////////////////////////

//加法器
wire [N - 1: 0] DOUT_ADD1;
wire [N - 1: 0] DOUT_ADD2;

//加法器输入选择器
wire [1: 0] add21_sel;
wire [1: 0] add22_sel;
wire [N - 1: 0] add21_sel_out;
wire [N - 1: 0] add22_sel_out;


//寄存器
wire T3Clear, T3Load;
wire T4Clear, T4Load;
wire Z1Clear, Z1Load;
wire Z2Clear, Z2Load;
wire X1Clear, X1Load;
wire X2Clear, X2Load;

wire [N - 1: 0] reg_T3_out;
wire [N - 1: 0] reg_T4_out;
wire [N - 1: 0] reg_X1_out;
wire [N - 1: 0] reg_X2_out;
wire [N - 1: 0] reg_Z1_out;
wire [N - 1: 0] reg_Z2_out;

//寄存器输入选择器
wire [1: 0] Z1_sel;
wire [1: 0] Z2_sel;
wire [1: 0] T4_sel;
wire T3_sel;
wire X1_sel;
wire X2_sel;
wire [N - 1: 0] X1_sel_out;
wire [N - 1: 0] X2_sel_out;
wire [N - 1: 0] T3_sel_out;
wire [N - 1: 0] T4_sel_out;
wire [N - 1: 0] Z1_sel_out;
wire [N - 1: 0] Z2_sel_out;


///////////////// 例化 ////////////////////////
//状态机
Mxy_fsm Mxy_fsm1(
            .CLK(CLK),
            .RST_N(RST_N),
            .ERROR1(ERROR1),
            .ERROR2(ERROR2),
            .MUL1_OUT_VALID(MUL1_OUT_VALID),
            .MUL2_OUT_VALID(MUL2_OUT_VALID),
            .INV_OUT_VALID(INV_OUT_VALID),
            .IN_VALID(IN_VALID),
            .Z1_zero(Z1_zero),
            .Z2_zero(Z2_zero),
            .mul11_sel(mul11_sel),
            .mul12_sel(mul12_sel),
            .mul21_sel(mul21_sel),
            .mul22_sel(mul22_sel),
            .add21_sel(add21_sel),
            .add22_sel(add22_sel),
            .Z1_sel(Z1_sel),
            .Z2_sel(Z2_sel),
            .X1_sel(X1_sel),
            .X2_sel(X2_sel),
            .T3_sel(T3_sel),
            .T4_sel(T4_sel),
            .T3Clear(T3Clear),
            .T3Load(T3Load),
            .T4Clear(T4Clear),
            .T4Load(T4Load),
            .Z1Clear(Z1Clear),
            .Z1Load(Z1Load),
            .Z2Clear(Z2Clear),
            .Z2Load(Z2Load),
            .X1Clear(X1Clear),
            .X1Load(X1Load),
            .X2Clear(X2Clear),
            .X2Load(X2Load),
            .MUL1_IN_VALID(MUL1_IN_VALID),
            .MUL2_IN_VALID(MUL2_IN_VALID),
            .INV_IN_VALID(INV_IN_VALID),
            .OUT_STATE(fsm_out_state)
        );

//平方器
square Mxy_squa( .DIN(T1),
                 .DOUT(DOUT_SQUA));

//求逆器
inv_top Mxy_inv(
            .CLK(CLK),
            .RST_N(RST_N),
            .IN_VALID(INV_IN_VALID),
            .DIN(reg_T3_out),
            .DOUT(DOUT_INV),
            .OUT_VALID(INV_OUT_VALID)
        );

//加法器
add Mxy_adder1(
        .DIN1(reg_X1_out),
        .DIN2(reg_Z1_out),
        .DOUT(DOUT_ADD1)
    );
add Mxy_adder2(
        .DIN1(add21_sel_out),
        .DIN2(add22_sel_out),
        .DOUT(DOUT_ADD2)
    );

//加法器输入选择器
select4to1 Mxy_adder_in21_sel(
               .SEL(add21_sel),
               .A(T1),
               .B(reg_T4_out),
               .C(reg_X2_out),
               .D(T2),
               .OUT(add21_sel_out)
           );

select3to1 Mxy_adder_in22_sel(
               .SEL(add22_sel),
               .A(reg_X2_out),
               .B(T2),
               .C(reg_Z2_out),
               .OUT(add22_sel_out)
           );

//乘法器例化
mul_fault Mxy_mult1( .CLK(CLK),
                     .RST_N(RST_N),
                     .A(mul11_sel_out),
                     .B(mul12_sel_out),
                     .IN_VALID(MUL1_IN_VALID),
                     .DOUT(DOUT_MUL1),
                     .OUT_VALID(MUL1_OUT_VALID),
                     .ERROR(ERROR1)
                   );

mul_fault Mxy_mult2( .CLK(CLK),
                     .RST_N(RST_N),
                     .A(mul21_sel_out),
                     .B(mul22_sel_out),
                     .IN_VALID(MUL2_IN_VALID),
                     .DOUT(DOUT_MUL2),
                     .OUT_VALID(MUL2_OUT_VALID),
                     .ERROR(ERROR2)
                   );
//乘法器输入选择器
select3to1 Mxy_mul_in11_sel(
               .SEL(mul11_sel),
               .A(T1),
               .B(reg_X1_out),
               .C(reg_T4_out),
               .OUT(mul11_sel_out)
           );

select Mxy_mul_in12_sel(
           .SEL(mul12_sel),
           .A(reg_Z2_out),
           .B(reg_T3_out),
           .OUT(mul12_sel_out)
       );

select Mxy_mul_in21_sel(
           .SEL(mul21_sel),
           .A(reg_Z1_out),
           .B(reg_T3_out),
           .OUT(mul21_sel_out)
       );

select3to1 Mxy_mul_in22_sel(
               .SEL(mul22_sel),
               .A(reg_Z2_out),
               .B(T1),
               .C(reg_X1_out),
               .OUT(mul22_sel_out)
           );

//////////////////////////////////////////////
//寄存器
register Mxy_T3(
             .CLK(CLK),
             .CLEAR(T3Clear),
             .LOAD(T3Load),
             .OUT(reg_T3_out),
             .IN(T3_sel_out) );

register Mxy_T4(
             .CLK(CLK),
             .CLEAR(T4Clear),
             .LOAD(T4Load),
             .OUT(reg_T4_out),
             .IN(T4_sel_out) );

register Mxy_Z1(
             .CLK(CLK),
             .CLEAR(Z1Clear),
             .LOAD(Z1Load),
             .OUT(reg_Z1_out),
             .IN(Z1_sel_out) );

register Mxy_Z2(
             .CLK(CLK),
             .CLEAR(Z2Clear),
             .LOAD(Z2Load),
             .OUT(reg_Z2_out),
             .IN(Z2_sel_out) );

register Mxy_X1(
             .CLK(CLK),
             .CLEAR(X1Clear),
             .LOAD(X1Load),
             .OUT(reg_X1_out),
             .IN(X1_sel_out) );

register Mxy_X2(
             .CLK(CLK),
             .CLEAR(X2Clear),
             .LOAD(X2Load),
             .OUT(reg_X2_out),
             .IN(X2_sel_out) );

//寄存器输入选择器
select Mxy_T3_sel(
           .SEL(T3_sel),
           .A(DOUT_MUL2),
           .B(DOUT_INV),
           .OUT(T3_sel_out)
       );
select3to1 Mxy_T4_sel(
               .SEL(T4_sel),
               .A(DOUT_MUL1),
               .B(DOUT_ADD2),
               .C(DOUT_SQUA),
               .OUT(T4_sel_out)
           );
select3to1 Mxy_Z1_sel(
               .SEL(Z1_sel),
               .A(DOUT_MUL2),
               .B(DOUT_ADD1),
               .C(DIN_P1_Z),
               .OUT(Z1_sel_out)
           );
select4to1 Mxy_Z2_sel(
               .SEL(Z2_sel),
               .A(DOUT_MUL1),
               .B(DOUT_MUL2),
               .C(DOUT_ADD2),
               .D(DIN_P2_Z),
               .OUT(Z2_sel_out)
           );
select Mxy_X1_sel(
           .SEL(X1_sel),
           .A(DOUT_MUL1),
           .B(DIN_P1_X),
           .OUT(X1_sel_out)
       );
select Mxy_X2_sel(
           .SEL(X2_sel),
           .A(DOUT_MUL2),
           .B(DIN_P2_X),
           .OUT(X2_sel_out)
       );

always @(posedge CLK) begin
    if (!RST_N) begin
        T1 <= 0;
        T2 <= 0;
        OUT_VALID <= 1'b0;
        DOUT_x <= 0;
        DOUT_y <= 0;
        Z1_zero <= 0;
        Z2_zero <= 0;
    end
    else if (IN_VALID) begin
        T1 <= DIN_P_x;
        T2 <= DIN_P_y;
        OUT_VALID <= 1'b0;
        DOUT_x <= 0;
        DOUT_y <= 0;
        Z1_zero <= 0;
        Z2_zero <= 0;
    end
    else begin
        if (fsm_out_state == PRE_JUDGE) begin
            if (reg_Z1_out == {N{1'b0}}) begin
                DOUT_x <= 0;
                DOUT_y <= 0;
                OUT_VALID <= 1;
                Z1_zero <= 1;
            end
            if (reg_Z2_out == {N{1'b0}}) begin
                DOUT_x <= T1;
                DOUT_y <= T1 ^ T2;
                OUT_VALID <= 1;
                Z2_zero <= 1;
            end
        end

        // if (fsm_out_state == END) begin
        //     $display("END X2=%h\nZ2=%h\n", reg_X2_out, reg_Z2_out);
        // end

        // if (fsm_out_state == 5'b00110) begin
        //     $display("5'b00011 T3=%h\nT4=%h\n", reg_T3_out, reg_T4_out);
        // end

        if (fsm_out_state == END) begin
            DOUT_x <= reg_X2_out;
            DOUT_y <= reg_Z2_out;
            $display("DOUT_x=%h\nDOUT_y=%h\n", reg_X2_out, reg_Z2_out);
            OUT_VALID <= 1;
        end
        else begin
            OUT_VALID <= 1'b0;
        end
    end
end
endmodule
