`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    20:13:16 11/27/2020
// Design Name:
// Module Name:    P_ADD_top
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
module P_ADD_top(
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
           DOUT_A_Z
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
    OUTPUT = 4'b1110;

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


//输入存储
//reg [N - 1: 0] x;
reg [N - 1: 0] Z2;
wire [N - 1: 0] X1;
wire [N - 1: 0] Z1;
wire [N - 1: 0] X2;
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

//平方器
wire [N - 1: 0] DOUT_SQUA;
wire [N - 1: 0] squa_sel_out;

//////////////////////////////////////////////

//加法器
wire [N - 1: 0] DOUT_ADD1;
wire [N - 1: 0] DOUT_ADD2;

//////////////////////////////////////////////

//寄存器
wire X1Clear;
wire X1Load;
wire Z1Clear;
wire Z1Load;
wire X2Clear;
wire X2Load;

wire [N - 1: 0] X1_sel_out;
wire [N - 1: 0] Z1_sel_out;
wire [N - 1: 0] X2_sel_out;

//寄存器选择器
wire [1: 0] X1Sel;
wire [1: 0] Z1Sel;
wire X2Sel;

//输出
wire [N - 1: 0] A_x;
wire [N - 1: 0] A_z;



//////////////////////////////////////////////

wire [3 : 0] fsm_out_state;


//状态机
P_ADD_fsm P_ADD_fsm1(
              .CLK(CLK),
              .RST_N(RST_N),
              .ERROR1(ERROR1),
              .ERROR2(ERROR2),
              .MUL1_OUT_VALID(MUL1_OUT_VALID),
              .MUL2_OUT_VALID(MUL2_OUT_VALID),
              .IN_VALID(IN_VALID),
              .mul12_sel(mul12_sel),
              .mul22_sel(mul22_sel),
              .X1Clear(X1Clear),
              .X1Load(X1Load),
              .Z1Clear(Z1Clear),
              .Z1Load(Z1Load),
              .X2Clear(X2Clear),
              .X2Load(X2Load),
              .X1Sel(X1Sel),
              .Z1Sel(Z1Sel),
              .X2Sel(X2Sel),
              .MUL1_IN_VALID(MUL1_IN_VALID),
              .MUL2_IN_VALID(MUL2_IN_VALID),
              .OUT_STATE(fsm_out_state)
          );

//乘法器例化
mul_fault P_ADD_mult1( .CLK(CLK),
                       .RST_N(RST_N),
                       .A(X1),
                       .B(mul12_sel_out),
                       .IN_VALID(MUL1_IN_VALID),
                       .DOUT(DOUT_MUL1),
                       .OUT_VALID(MUL1_OUT_VALID),
                       .ERROR(ERROR1)
                     );

mul_fault P_ADD_mult2( .CLK(CLK),
                       .RST_N(RST_N),
                       .A(Z1),
                       .B(mul22_sel_out),
                       .IN_VALID(MUL2_IN_VALID),
                       .DOUT(DOUT_MUL2),
                       .OUT_VALID(MUL2_OUT_VALID),
                       .ERROR(ERROR2)
                     );

//乘法器输入选择器
select P_ADD_mul_in12_sel(
           .SEL(mul12_sel),
           .A(Z1),
           .B(Z2),
           .OUT(mul12_sel_out)
       );


select P_ADD_mul_in22_sel(
           .SEL(mul22_sel),
           .A(X2),
           .B(DIN_P_x),
           .OUT(mul22_sel_out)
       );

//平方器例化
square P_ADD_squa( .DIN(Z1),
                   .DOUT(DOUT_SQUA));


//加法器
add P_ADD_adder1(
        .DIN1(X1),
        .DIN2(Z1),
        .DOUT(DOUT_ADD1)
    );
add P_ADD_adder2(
        .DIN1(X1),
        .DIN2(X2),
        .DOUT(DOUT_ADD2)
    );

//寄存器
register P_ADD_X1(
             .CLK(CLK),
             .CLEAR(X1Clear),
             .LOAD(X1Load),
             .OUT(X1),
             .IN(X1_sel_out) );

select3to1 P_ADD_X1_sel(
               .SEL(X1Sel),
               .A(DOUT_MUL1),
               .B(DOUT_ADD2),
               .C(DIN_P1_X),
               .OUT(X1_sel_out)
           );

register P_ADD_Z1(
             .CLK(CLK),
             .CLEAR(Z1Clear),
             .LOAD(Z1Load),
             .OUT(Z1),
             .IN(Z1_sel_out) );

select4to1 P_ADD_Z1_sel(
               .SEL(Z1Sel),
               .A(DOUT_MUL2),
               .B(DOUT_ADD1),
               .C(DOUT_SQUA),
               .D(DIN_P1_Z),
               .OUT(Z1_sel_out)
           );

register P_ADD_X2(
             .CLK(CLK),
             .CLEAR(X2Clear),
             .LOAD(X2Load),
             .OUT(X2),
             .IN(X2_sel_out) );

select P_ADD_X2_sel(
           .SEL(X2Sel),
           .A(DOUT_MUL2),
           .B(DIN_P2_X),
           .OUT(X2_sel_out)
       );


assign DOUT_A_X = X1;
assign DOUT_A_Z = Z1;

always @(posedge CLK) begin
    if (!RST_N) begin
        //x <= 0;
        Z2 <= 0;
        OUT_VALID <= 1'b0;
    end
    else if (IN_VALID) begin
        //x <= DIN_P_x;
        Z2 <= DIN_P2_Z;
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
            $display("Add Finished!\n");
            $display("ADD_X=%h\n", DOUT_A_X);
            $display("ADD_Z=%h\n", DOUT_A_Z);
        end
        else begin
            OUT_VALID <= 1'b0;
        end
    end
end

endmodule
