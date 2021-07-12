`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    11:07:52 08/25/2020
// Design Name:
// Module Name:    P_AddDouble
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
module P_AddDouble_top(
           CLK,
           RST_N,
           DIN_P1_X,
           DIN_P1_Z,
           DIN_P2_X,
           DIN_P2_Z,
           DIN_P_x,
           IN_VALID,
           OUT_VALID,
           DOUT_A_X,
           DOUT_A_Z,
           DOUT_D_X,
           DOUT_D_Z
       );

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
    S7 = 4'b1101,
    S8 = 4'b1111,
    S9 = 4'b1110,
    S10 = 4'b1010,
    S11 = 4'b1011,
    OUTPUT = 4'b1001;

input CLK;
input RST_N;
input [N - 1: 0] DIN_P1_X;
input [N - 1: 0] DIN_P1_Z;
input [N - 1: 0] DIN_P2_X;
input [N - 1: 0] DIN_P2_Z;
input [N - 1: 0] DIN_P_x;
input IN_VALID;
output reg OUT_VALID;

output [N - 1: 0] DOUT_A_X;
output [N - 1: 0] DOUT_A_Z;
output [N - 1: 0] DOUT_D_X;
output [N - 1: 0] DOUT_D_Z;


//输入存储
//reg [N - 1: 0] x;
wire [N - 1: 0] X1;
wire [N - 1: 0] Z1;
wire [N - 1: 0] X2;
wire [N - 1: 0] Z2;

wire [N - 1: 0] T1;
//////////////////////////////////////////////

//乘法器1
wire MUL1_IN_VALID;
wire MUL1_OUT_VALID;
wire [N - 1: 0] DOUT_MUL1;
wire ERROR1;

// 乘法器1输入选择器
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
wire mul22_sel;
wire [N - 1: 0] mul21_sel_out;
wire [N - 1: 0] mul22_sel_out;

//////////////////////////////////////////////

//乘法器3
wire MUL3_IN_VALID;
wire MUL3_OUT_VALID;
wire [N - 1: 0] DOUT_MUL3;
wire ERROR3;
//////////////////////////////////////////////

//平方器
wire [N - 1: 0] DOUT_SQUA;
wire [N - 1: 0] squa_sel_out;

//平方器输入选择器
wire [1: 0] squa_sel;
//////////////////////////////////////////////

//加法器
wire [N - 1: 0] DOUT_ADD1;
wire [N - 1: 0] DOUT_ADD2;
wire [N - 1: 0] DOUT_ADD3;

//////////////////////////////////////////////

//寄存器
wire T1Clear;
wire T1Load;
wire X1Clear;
wire X1Load;
wire Z1Clear;
wire Z1Load;
wire X2Clear;
wire X2Load;
wire Z2Clear;
wire Z2Load;

wire [N - 1: 0] X1_sel_out;
wire [N - 1: 0] Z1_sel_out;
wire [N - 1: 0] X2_sel_out;
wire [N - 1: 0] Z2_sel_out;
wire [N - 1: 0] T1_sel_out;

//寄存器选择器
wire [1: 0] X1Sel;
wire [1: 0] Z1Sel;
wire [1: 0] X2Sel;
wire Z2Sel;
wire T1Sel;

//输出
wire [N - 1: 0] A_x;
wire [N - 1: 0] A_z;
wire [N - 1: 0] D_x;
wire [N - 1: 0] D_z;


//////////////////////////////////////////////

wire [3 : 0] fsm_out_state;


//状态机
P_AddDouble_fsm P_AD_fsm(
                    .CLK(CLK),
                    .RST_N(RST_N),
                    .ERROR1(ERROR1),
                    .ERROR2(ERROR2),
                    .ERROR3(ERROR3),
                    .MUL1_OUT_VALID(MUL1_OUT_VALID),
                    .MUL2_OUT_VALID(MUL2_OUT_VALID),
                    .MUL3_OUT_VALID(MUL3_OUT_VALID),
                    .IN_VALID(IN_VALID),
                    .mul12_sel(mul12_sel),
                    .mul22_sel(mul22_sel),
                    .squa_sel(squa_sel),
                    .T1Clear(T1Clear),
                    .T1Load(T1Load),
                    .X1Clear(X1Clear),
                    .X1Load(X1Load),
                    .Z1Clear(Z1Clear),
                    .Z1Load(Z1Load),
                    .X2Clear(X2Clear),
                    .X2Load(X2Load),
                    .Z2Clear(Z2Clear),
                    .Z2Load(Z2Load),
                    .X1Sel(X1Sel),
                    .Z1Sel(Z1Sel),
                    .X2Sel(X2Sel),
                    .Z2Sel(Z2Sel),
                    .T1Sel(T1Sel),
                    .MUL1_IN_VALID(MUL1_IN_VALID),
                    .MUL2_IN_VALID(MUL2_IN_VALID),
                    .MUL3_IN_VALID(MUL3_IN_VALID),
                    .OUT_STATE(fsm_out_state)
                );

//乘法器例化
mul_fault P_AD_mult1( .CLK(CLK),
                      .RST_N(RST_N),
                      .A(X1),
                      .B(mul12_sel_out),
                      .IN_VALID(MUL1_IN_VALID),
                      .DOUT(DOUT_MUL1),
                      .OUT_VALID(MUL1_OUT_VALID),
                      .ERROR(ERROR1)
                    );

mul_fault P_AD_mult2( .CLK(CLK),
                      .RST_N(RST_N),
                      .A(Z1),
                      .B(mul22_sel_out),
                      .IN_VALID(MUL2_IN_VALID),
                      .DOUT(DOUT_MUL2),
                      .OUT_VALID(MUL2_OUT_VALID),
                      .ERROR(ERROR2)
                    );

mul_fault P_AD_mult3( .CLK(CLK),
                      .RST_N(RST_N),
                      .A(T1),
                      .B(X2),
                      .IN_VALID(MUL3_IN_VALID),
                      .DOUT(DOUT_MUL3),
                      .OUT_VALID(MUL3_OUT_VALID),
                      .ERROR(ERROR3)
                    );

//乘法器输入选择器
select P_AD_mul_in12_sel(
           .SEL(mul12_sel),
           .A(Z1),
           .B(Z2),
           .OUT(mul12_sel_out)
       );


select P_AD_mul_in22_sel(
           .SEL(mul22_sel),
           .A(X2),
           .B(DIN_P_x),
           .OUT(mul22_sel_out)
       );

//平方器例化
square P_AD_squa( .DIN(squa_sel_out),
                  .DOUT(DOUT_SQUA));

//平方器输入选择器
select4to1 P_AD_squa_in_sel(
               .SEL(squa_sel),
               .A(X1),
               .B(Z1),
               .C(X2),
               .D(T1),
               .OUT(squa_sel_out)
           );

//加法器
add P_AD_adder1(
        .DIN1(X1),
        .DIN2(Z1),
        .DOUT(DOUT_ADD1)
    );
add P_AD_adder2(
        .DIN1(T1),
        .DIN2(X2),
        .DOUT(DOUT_ADD2)
    );
add P_AD_adder3(
        .DIN1(X1),
        .DIN2(T1),
        .DOUT(DOUT_ADD3)
    );

//寄存器
register P_AD_T1(
             .CLK(CLK),
             .CLEAR(T1Clear),
             .LOAD(T1Load),
             .OUT(T1),
             .IN(T1_sel_out) );

select P_AD_T1_sel(
           .SEL(T1Sel),
           .A(DOUT_MUL2),
           .B(DOUT_SQUA),
           .OUT(T1_sel_out)
       );

register P_AD_X1(
             .CLK(CLK),
             .CLEAR(X1Clear),
             .LOAD(X1Load),
             .OUT(X1),
             .IN(X1_sel_out) );

select3to1 P_AD_X1_sel(
               .SEL(X1Sel),
               .A(DOUT_MUL1),
               .B(DOUT_ADD3),
               .C(DIN_P1_X),
               .OUT(X1_sel_out)
           );

register P_AD_Z1(
             .CLK(CLK),
             .CLEAR(Z1Clear),
             .LOAD(Z1Load),
             .OUT(Z1),
             .IN(Z1_sel_out) );

select4to1 P_AD_Z1_sel(
               .SEL(Z1Sel),
               .A(DOUT_MUL2),
               .B(DOUT_ADD1),
               .C(DOUT_SQUA),
               .D(DIN_P1_Z),
               .OUT(Z1_sel_out)
           );

register P_AD_X2(
             .CLK(CLK),
             .CLEAR(X2Clear),
             .LOAD(X2Load),
             .OUT(X2),
             .IN(X2_sel_out) );

select3to1 P_AD_X2_sel(
               .SEL(X2Sel),
               .A(DOUT_SQUA),
               .B(DOUT_ADD2),
               .C(DIN_P2_X),
               .OUT(X2_sel_out)
           );

register P_AD_Z2(
             .CLK(CLK),
             .CLEAR(Z2Clear),
             .LOAD(Z2Load),
             .OUT(Z2),
             .IN(Z2_sel_out) );

select P_AD_Z2_sel(
           .SEL(Z2Sel),
           .A(DOUT_MUL3),
           .B(DIN_P2_Z),
           .OUT(Z2_sel_out)
       );

assign DOUT_A_X = X1;
assign DOUT_A_Z = Z1;
assign DOUT_D_X = X2;
assign DOUT_D_Z = Z2;

always @(posedge CLK) begin
    if (!RST_N) begin
        //x <= 0;
        OUT_VALID <= 1'b0;
    end
    else if (IN_VALID) begin
        //x <= DIN_P_x;
        OUT_VALID <= 1'b0;
    end
    else begin

        //$display("reg_T4_out=%h\n, D_x=%h\nA_z=%h\n", reg_T4_out, D_x, A_z);
        // if (fsm_out_state == 4'b1001) begin

        //     $display("4'b1001 add_in1=%h\nD_z=%h\nreg_T3=%h\n",add_in1,D_z, reg_T3_out);
        //     //$display("t1=%h\n\n",D_x);
        // end
        // if (fsm_out_state == 4'b1000) begin
        //     $display("S6 Z1=%h\n",Z1);
        //     //$display("t1=%h\n\n",D_x);
        // end
        // if (fsm_out_state == 4'b1001) begin
        //     $display("S7 Z1=%h\n",Z1);
        //     //$display("t1=%h\n\n",D_x);
        // end

        if (fsm_out_state == OUTPUT) begin
            OUT_VALID <= 1;
            $display("AddDouble Finished!\n");
            $display("DOUT_A_X=%h\n", DOUT_A_X);
            $display("DOUT_A_Z=%h\n", DOUT_A_Z);
            $display("DOUT_D_X=%h\n", DOUT_D_X);
            $display("DOUT_D_Z=%h\n", DOUT_D_Z);
        end
        else begin
            OUT_VALID <= 1'b0;
        end
    end
end
endmodule
