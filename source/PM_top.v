`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    10:36:25 11/16/2020
// Design Name:
// Module Name:    PM_top
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
module PM_top(
           CLK,
           RST_N,
           DIN_P_x,
           DIN_P_y,
           random_z,
           key,
           IN_VALID,
           DOUT_x,
           DOUT_y,
           OUT_VALID
       );

parameter N = 233; //位宽

parameter
    IDLE = 4'b0000,
    INIT = 4'b0001,
    PRE_JUDGE = 4'b0011,
    PRE_COMPUTE = 4'b0010,
    KEY_FIRST_SCAN = 4'b0110,
    KEY_SCAN = 4'b0111,
    KEY_JUDGE = 4'b0101,
    P_AD = 4'b0100,
    STROAGE = 4'b1100,
    Y_REC = 4'b1101,
    OUTPUT = 4'b1111;

parameter
    KEY_IS_ZERO = 2'b01,
    KEY_IS_ONE = 2'b11;

input CLK;
input RST_N;
input IN_VALID;
input [N - 1: 0] DIN_P_x;
input [N - 1: 0] DIN_P_y;
input [N - 1: 0] random_z;
input [N - 1: 0] key;
wire [N - 1: 0] key;
output reg OUT_VALID;
output reg [N - 1: 0] DOUT_x;
output reg [N - 1: 0] DOUT_y;

//寄存器
reg [N - 1: 0] P_x;
reg [N - 1: 0] P_y;
reg [N - 1: 0] P_z;
reg P_x_is_0;

//////////////////////////////////////////////

//寄存器模块
wire X1Clear;
wire X1Load;
wire Z1Clear;
wire Z1Load;
wire X2Clear;
wire X2Load;
wire Z2Clear;
wire Z2Load;
wire [N - 1: 0] X1;
wire [N - 1: 0] Z1;
wire [N - 1: 0] X2;
wire [N - 1: 0] Z2;

//坐标转换模块
wire axis_translate_in_valid;
wire [N - 1: 0] axis_trans_X1;
wire [N - 1: 0] axis_trans_Z1;
wire [N - 1: 0] axis_trans_X2;
wire [N - 1: 0] axis_trans_Z2;
wire axis_translate_out_valid;

//寄存器输入选择器模块
wire [1: 0] X1Sel;
wire [1: 0] Z1Sel;
wire [1: 0] X2Sel;
wire [1: 0] Z2Sel;
wire [N - 1: 0] X1_sel_out;
wire [N - 1: 0] Z1_sel_out;
wire [N - 1: 0] X2_sel_out;
wire [N - 1: 0] Z2_sel_out;

//点加倍点模块例化
wire [N - 1: 0] P_AD_DIN_P1_X;
wire [N - 1: 0] P_AD_DIN_P1_Z;
wire [N - 1: 0] P_AD_DIN_P2_X;
wire [N - 1: 0] P_AD_DIN_P2_Z;
wire [N - 1: 0] P_AD_DIN_P_x;
wire P_AD_IN_VALID;
wire P_AD_OUT_VALID;
wire [N - 1: 0] P_AD_DOUT_A_X;
wire [N - 1: 0] P_AD_DOUT_A_Z;
wire [N - 1: 0] P_AD_DOUT_D_X;
wire [N - 1: 0] P_AD_DOUT_D_Z;

//坐标恢复模块例化
wire Mxy_IN_VALID;
wire Mxy_OUT_VALID;
wire [N - 1: 0] Mxy_DOUT_x;
wire [N - 1: 0] Mxy_DOUT_y;

//密钥扫描模块
wire [N - 1: 0] key_in;
wire key_load;
wire key_check;
wire keyscan_en;
wire find_key_first;
wire ki;
wire key_first_found;
wire [7: 0] key_cnt;
wire [1: 0] key_state;

//点加倍点模块输入选择器
wire AD_X1Sel;
wire AD_Z1Sel;
wire AD_X2Sel;
wire AD_Z2Sel;

//状态机
wire [3: 0] fsm_out_state;

//状态机例化
PM_fsm PM_fsm1(
           .CLK(CLK),
           .RST_N(RST_N),
           .IN_VALID(IN_VALID),
           .ki(ki),
           .key_first_found(key_first_found),
           .key_cnt(key_cnt),
           .P_x_is_0(P_x_is_0),
           .Mxy_OUT_VALID(Mxy_OUT_VALID),
           .axis_translate_out_valid(axis_translate_out_valid),
           .P_AD_OUT_VALID(P_AD_OUT_VALID),
           .keyscan_en(keyscan_en),
           .key_check(key_check),
           .key_load(key_load),
           .find_key_first(find_key_first),
           .key_state(key_state),
           .Mxy_IN_VALID(Mxy_IN_VALID),
           .P_AD_IN_VALID(P_AD_IN_VALID),
           .axis_translate_in_valid(axis_translate_in_valid),
           .X1Clear(X1Clear),
           .X1Load(X1Load),
           .Z1Clear(Z1Clear),
           .Z1Load(Z1Load),
           .X2Clear(X2Clear),
           .X2Load(X2Load),
           .Z2Clear(Z2Clear),
           .Z2Load(Z2Load),
           .AD_X1Sel(AD_X1Sel),
           .AD_Z1Sel(AD_Z1Sel),
           .AD_X2Sel(AD_X2Sel),
           .AD_Z2Sel(AD_Z2Sel),
           .X1Sel(X1Sel),
           .Z1Sel(Z1Sel),
           .X2Sel(X2Sel),
           .Z2Sel(Z2Sel),
           .OUT_STATE(fsm_out_state)
       );

//坐标转换模块例化
axis_translate_top PM_axis_translate(
                       .CLK(CLK),
                       .RST_N(RST_N),
                       .IN_VALID(axis_translate_in_valid),
                       .DIN_P_x(P_x),
                       .DIN_P_z(P_z),
                       .reg_X1_out(axis_trans_X1),
                       .reg_Z1_out(axis_trans_Z1),
                       .reg_X2_out(axis_trans_X2),
                       .reg_Z2_out(axis_trans_Z2),
                       .OUT_VALID(axis_translate_out_valid)
                   );

//寄存器模块例化
register PM_X1(
             .CLK(CLK),
             .CLEAR(X1Clear),
             .LOAD(X1Load),
             .OUT(X1),
             .IN(X1_sel_out) );

register PM_Z1(
             .CLK(CLK),
             .CLEAR(Z1Clear),
             .LOAD(Z1Load),
             .OUT(Z1),
             .IN(Z1_sel_out) );

register PM_X2(
             .CLK(CLK),
             .CLEAR(X2Clear),
             .LOAD(X2Load),
             .OUT(X2),
             .IN(X2_sel_out) );

register PM_Z2(
             .CLK(CLK),
             .CLEAR(Z2Clear),
             .LOAD(Z2Load),
             .OUT(Z2),
             .IN(Z2_sel_out) );

//寄存器输入选择器模块例化
select3to1 PM_X1_sel(
               .SEL(X1Sel),
               .A(P_AD_DOUT_A_X),
               .B(P_AD_DOUT_D_X),
               .C(axis_trans_X1),
               .OUT(X1_sel_out)
           );
select3to1 PM_Z1_sel(
               .SEL(Z1Sel),
               .A(P_AD_DOUT_A_Z),
               .B(P_AD_DOUT_D_Z),
               .C(axis_trans_Z1),
               .OUT(Z1_sel_out)
           );
select3to1 PM_X2_sel(
               .SEL(X2Sel),
               .A(P_AD_DOUT_A_X),
               .B(P_AD_DOUT_D_X),
               .C(axis_trans_X2),
               .OUT(X2_sel_out)
           );
select3to1 PM_Z2_sel(
               .SEL(Z2Sel),
               .A(P_AD_DOUT_A_Z),
               .B(P_AD_DOUT_D_Z),
               .C(axis_trans_Z2),
               .OUT(Z2_sel_out)
           );

//点加倍点模块例化
P_AddDouble_top PM_AD(
                    .CLK(CLK),
                    .RST_N(RST_N),
                    .DIN_P1_X(P_AD_DIN_P1_X),
                    .DIN_P1_Z(P_AD_DIN_P1_Z),
                    .DIN_P2_X(P_AD_DIN_P2_X),
                    .DIN_P2_Z(P_AD_DIN_P2_Z),
                    .DIN_P_x(P_x),
                    .IN_VALID(P_AD_IN_VALID),
                    .OUT_VALID(P_AD_OUT_VALID),
                    .DOUT_A_X(P_AD_DOUT_A_X),
                    .DOUT_A_Z(P_AD_DOUT_A_Z),
                    .DOUT_D_X(P_AD_DOUT_D_X),
                    .DOUT_D_Z(P_AD_DOUT_D_Z)
                );

//点加倍点模块输入选择器例化
select PM_AD_P1_X_sel(
           .SEL(AD_X1Sel),
           .A(X1),
           .B(X2),
           .OUT(P_AD_DIN_P1_X)
       );
select PM_AD_P1_Z_sel(
           .SEL(AD_Z1Sel),
           .A(Z1),
           .B(Z2),
           .OUT(P_AD_DIN_P1_Z)
       );
select PM_AD_P2_X_sel(
           .SEL(AD_X2Sel),
           .A(X1),
           .B(X2),
           .OUT(P_AD_DIN_P2_X)
       );
select PM_AD_P2_Z_sel(
           .SEL(AD_Z2Sel),
           .A(Z1),
           .B(Z2),
           .OUT(P_AD_DIN_P2_Z)
       );

//坐标恢复模块例化
Mxy_top PM_Mxy(
            .CLK(CLK),
            .RST_N(RST_N),
            .DIN_P1_X(X1),
            .DIN_P1_Z(Z1),
            .DIN_P2_X(X2),
            .DIN_P2_Z(Z2),
            .DIN_P_x(P_x),
            .DIN_P_y(P_y),
            .IN_VALID(Mxy_IN_VALID),
            .OUT_VALID(Mxy_OUT_VALID),
            .DOUT_x(Mxy_DOUT_x),
            .DOUT_y(Mxy_DOUT_y)
        );

//密钥扫描模块
keyscan PM_keyscan(
            .CLK(CLK),
            .RST_N(RST_N),
            .key_in(key),
            .key_load(key_load),
            .key_check(key_check),
            .keyscan_en(keyscan_en),
            .keyfind_en(find_key_first),
            .ki(ki),
            .key_first_found(key_first_found),
            .key_cnt(key_cnt),
            .key_state(key_state)
        );

// assign key = 233'h542324;

always @(posedge CLK) begin
    if (!RST_N) begin
        OUT_VALID <= 1'b0;
        P_x_is_0 <= 1'b0;
        P_x <= 0;
        P_y <= 0;
        P_z <= 0;
        DOUT_x <= 0;
        DOUT_y <= 0;
    end
    else begin
        if (IN_VALID) begin
            OUT_VALID <= 1'b0;
            P_x <= DIN_P_x;
            P_y <= DIN_P_y;
            P_z <= random_z;
            DOUT_x <= 0;
            DOUT_y <= 0;
        end
        if (fsm_out_state == PRE_JUDGE) begin
            if (P_x == 0) begin
                P_x_is_0 <= 1'b1;
            end
        end
        if (key_state == KEY_IS_ZERO || P_x_is_0 == 1'b1) begin
            OUT_VALID <= 1'b1;
            DOUT_x <= 0;
            DOUT_y <= 0;
        end
        else if (key_state == KEY_IS_ONE) begin
            OUT_VALID <= 1'b1;
            DOUT_x <= P_x;
            DOUT_y <= P_y;
        end
        else if (fsm_out_state == OUTPUT ) begin
            OUT_VALID <= 1'b1;
            DOUT_x <= Mxy_DOUT_x;
            DOUT_y <= Mxy_DOUT_y;
            $display(" DOUT_x=%h\n DOUT_y=%h\n", Mxy_DOUT_x, Mxy_DOUT_y);
        end
        else begin
            OUT_VALID <= 1'b0;
        end

        //测试
        // if (fsm_out_state == Y_REC) begin
        //     $display($time, "P_AD state:  STROAGE X1=%h\nX2=%h\nZ1=%h\nZ2=%h\n", X1, X2, Z1, Z2);
        // end
    end
end
endmodule
