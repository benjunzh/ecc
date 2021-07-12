`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    17:56:29 11/16/2020
// Design Name:
// Module Name:    axis_translate_top
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
module axis_translate_top(
           CLK,
           RST_N,
           IN_VALID,
           DIN_P_x,
           DIN_P_z,
           reg_X1_out,
           reg_Z1_out,
           reg_X2_out,
           reg_Z2_out,
           OUT_VALID
       );

parameter N = 233; //位宽
parameter END = 4'b1011;

input CLK;
input RST_N;
input IN_VALID;
input [N - 1: 0] DIN_P_x;
input [N - 1: 0] DIN_P_z;
output reg OUT_VALID;

//乘法器
wire ERROR;
wire MUL_IN_VALID;
wire MUL_OUT_VALID;
wire [N - 1: 0] DOUT_MULT;

//寄存器
wire X1Clear, X1Load;
wire X2Clear, X2Load;
wire Z2Clear, Z2Load;
wire T1Clear, T1Load;
wire T2Clear, T2Load;
output [N - 1: 0] reg_X1_out;
output reg [N - 1: 0] reg_Z1_out;
output [N - 1: 0] reg_X2_out;
output [N - 1: 0] reg_Z2_out;
wire [N - 1: 0] reg_T1_out;
wire [N - 1: 0] reg_T2_out;

//加法器
wire [N - 1: 0] DOUT_ADD;

//平方器
wire [N - 1: 0] squa_out;

//选择器
wire [N - 1: 0] squa_sel_out;
wire [N - 1: 0] T1_sel_out;
wire [N - 1: 0] T2_sel_out;
wire T1_sel;
wire T2_sel;
wire [1: 0] squa_sel;

wire [3: 0] fsm_out_state;

axis_translate_fsm Trans_fsm(
                       .CLK(CLK),
                       .RST_N(RST_N),
                       .ERROR(ERROR),
                       .MUL_OUT_VALID(MUL_OUT_VALID),
                       .IN_VALID(IN_VALID),
                       .X1Clear(X1Clear),
                       .X1Load(X1Load),
                       .X2Clear(X2Clear),
                       .X2Load(X2Load),
                       .Z2Clear(Z2Clear),
                       .Z2Load(Z2Load),
                       .T1Clear(T1Clear),
                       .T1Load(T1Load),
                       .T2Clear(T2Clear),
                       .T2Load(T2Load),
                       .MUL_IN_VALID(MUL_IN_VALID),
                       .OUT_STATE(fsm_out_state),
                       .squa_sel(squa_sel),
                       .T1_sel(T1_sel),
                       .T2_sel(T2_sel)
                   );

mul_fault Trans_mult1( .CLK(CLK),
                       .RST_N(RST_N),
                       .A(reg_T1_out),
                       .B(reg_T2_out),
                       .IN_VALID(MUL_IN_VALID),
                       .DOUT(DOUT_MULT),
                       .OUT_VALID(MUL_OUT_VALID),
                       .ERROR(ERROR)
                     );

register Trans_X1(
             .CLK(CLK),
             .CLEAR(X1Clear),
             .LOAD(X1Load),
             .OUT(reg_X1_out),
             .IN(DOUT_MULT) );

register Trans_X2(
             .CLK(CLK),
             .CLEAR(X2Clear),
             .LOAD(X2Load),
             .OUT(reg_X2_out),
             .IN(DOUT_ADD) );

register Trans_Z2(
             .CLK(CLK),
             .CLEAR(Z2Clear),
             .LOAD(Z2Load),
             .OUT(reg_Z2_out),
             .IN(DOUT_MULT) );

register Trans_T1(
             .CLK(CLK),
             .CLEAR(T1Clear),
             .LOAD(T1Load),
             .OUT(reg_T1_out),
             .IN(T1_sel_out) );

register Trans_T2(
             .CLK(CLK),
             .CLEAR(T2Clear),
             .LOAD(T2Load),
             .OUT(reg_T2_out),
             .IN(T2_sel_out) );

square Trans_squa( .DIN(squa_sel_out),
                   .DOUT(squa_out));

select3to1 Trans_squa_sel(
               .SEL(squa_sel),
               .A(reg_T1_out),
               .B(reg_T2_out),
               .C(reg_X1_out),
               .OUT(squa_sel_out)
           );

select Trans_T1_sel(
           .SEL(T1_sel),
           .A(DIN_P_x),
           .B(squa_out),
           .OUT(T1_sel_out)
       );
select Trans_T2_sel(
           .SEL(T2_sel),
           .A(DIN_P_z),
           .B(squa_out),
           .OUT(T2_sel_out)
       );

//加法器
add P_AD_adder1(
        .DIN1(reg_T1_out),
        .DIN2(reg_T2_out),
        .DOUT(DOUT_ADD)
    );

always @(posedge CLK) begin
    if (!RST_N) begin
        OUT_VALID <= 0;
        reg_Z1_out <= 0;
    end
    else begin
        if (IN_VALID) begin
            reg_Z1_out <= DIN_P_z;
        end
        // $display("T2_sel_out=%h\n, reg_T2_out=%h\n",T2_sel_out, reg_T2_out);
        if (fsm_out_state == END) begin
            OUT_VALID <= 1;
            $display("reg_X1_out=%h\n, reg_Z1_out=%h\n, reg_X2_out=%h\n, reg_Z2_out=%h\n", reg_X1_out, reg_Z1_out, reg_X2_out, reg_Z2_out);
        end
        else begin
            OUT_VALID <= 1'b0;
        end
    end
end
endmodule
