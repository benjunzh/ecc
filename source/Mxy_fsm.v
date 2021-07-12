`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    22:08:49 10/01/2020
// Design Name:
// Module Name:    Mxy_fsm
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
module Mxy_fsm(
           CLK,
           RST_N,
           ERROR1,
           ERROR2,
           MUL1_OUT_VALID,
           MUL2_OUT_VALID,
           INV_OUT_VALID,
           IN_VALID,
           Z1_zero,
           Z2_zero,
           mul11_sel,
           mul12_sel,
           mul21_sel,
           mul22_sel,
           add21_sel,
           add22_sel,
           Z1_sel,
           Z2_sel,
           X1_sel,
           X2_sel,
           T3_sel,
           T4_sel,
           T3Clear,
           T3Load,
           T4Clear,
           T4Load,
           Z1Clear,
           Z1Load,
           Z2Clear,
           Z2Load,
           X1Clear,
           X1Load,
           X2Clear,
           X2Load,
           MUL1_IN_VALID,
           MUL2_IN_VALID,
           INV_IN_VALID,
           OUT_STATE
       );

input CLK;
input RST_N;
input ERROR1, ERROR2;
input IN_VALID;
input INV_OUT_VALID;
input MUL1_OUT_VALID;
input MUL2_OUT_VALID;
input Z1_zero;
input Z2_zero;

output reg MUL1_IN_VALID;
output reg MUL2_IN_VALID;
output reg INV_IN_VALID;

output reg [1: 0] mul11_sel;
output reg mul12_sel;
output reg mul21_sel;
output reg [1: 0] mul22_sel;

output reg [1: 0] add21_sel;
output reg [1: 0] add22_sel;

output reg [1: 0] Z1_sel;
output reg [1: 0] Z2_sel;
output reg [1: 0] T4_sel;
output reg T3_sel;
output reg X1_sel;
output reg X2_sel;


output reg T3Clear;
output reg T3Load;
output reg T4Clear;
output reg T4Load;
output reg Z1Clear;
output reg Z1Load;
output reg Z2Clear;
output reg Z2Load;
output reg X1Clear;
output reg X1Load;
output reg X2Clear;
output reg X2Load;

output reg [4: 0] OUT_STATE;
reg [4: 0] state;

reg mul1_out_valid_tmp;
reg mul2_out_valid_tmp;
reg [2: 0] wait_cnt;

parameter
    IDLE = 5'b00000,
    INIT = 5'b11000,
    PRE_JUDGE = 5'b11001,
    START = 5'b00001,
    END = 5'b10011;

always @(posedge CLK) begin
    if (!RST_N) begin
        mul1_out_valid_tmp <= 0;
        mul2_out_valid_tmp <= 0;
        MUL1_IN_VALID <= 0;
        MUL2_IN_VALID <= 0;
        INV_IN_VALID <= 0;
        wait_cnt <= 0;

        state <= IDLE;
        OUT_STATE <= 0;

        T3Clear <= 1;
        T4Clear <= 1;
        Z1Clear <= 1;
        Z2Clear <= 1;
        X1Clear <= 1;
        X2Clear <= 1;
    end
    else begin
        OUT_STATE <= state;
        case (state)
            IDLE: begin
                T3Clear <= 0;
                T3Load <= 0;

                T4Clear <= 0;
                T4Load <= 0;

                Z1Clear <= 0;
                Z1Load <= 0;

                Z2Clear <= 0;
                Z2Load <= 0;

                X1Clear <= 0;
                X1Load <= 0;

                X2Clear <= 0;
                X2Load <= 0;

                Z1_sel <= 0;
                Z2_sel <= 0;
                T3_sel <= 0;
                T4_sel <= 0;
                X1_sel <= 0;
                X2_sel <= 0;

                mul11_sel <= 0;
                mul12_sel <= 0;
                mul21_sel <= 0;
                mul22_sel <= 0;

                add21_sel <= 0;
                add22_sel <= 0;

                MUL1_IN_VALID <= 0;
                MUL2_IN_VALID <= 0;
                INV_IN_VALID <= 0;

                wait_cnt <= 0;

                if (IN_VALID) begin
                    state <= INIT;
                end
                else begin
                    state <= IDLE;
                end
            end
            INIT: begin
                //初始化
                T3Clear <= 0;
                T4Clear <= 0;
                X1Clear <= 0;
                X2Clear <= 0;
                Z1Clear <= 0;
                Z2Clear <= 0;

                Z1Load <= 1;
                Z1_sel <= 2'b00;

                Z2Load <= 1;
                Z2_sel <= 2'b00;

                X1Load <= 1;
                X1_sel <= 0;

                X2Load <= 1;
                X2_sel <= 0;

                wait_cnt <= wait_cnt + 1'b1;
                if (!IN_VALID) begin
                    state <= PRE_JUDGE;
                end
            end
            PRE_JUDGE: begin
                //从load信号赋值开始，等待三个周期，让Z1和Z2的判断数据准备好
                if (wait_cnt >= 3'b011) begin
                    if (Z1_zero | Z2_zero) begin
                        state <= IDLE;
                    end
                    else begin
                        wait_cnt <= 0;
                        state <= START;
                    end
                end
                else begin
                    wait_cnt <= wait_cnt + 1'b1;
                end
            end
            START: begin
                //Z2=T1*Z2 start
                MUL1_IN_VALID <= 1;
                mul11_sel <= 2'b10;
                mul12_sel <= 1;

                //T3=Z1*Z2 start
                MUL2_IN_VALID <= 1;
                mul21_sel <= 1;
                mul22_sel <= 2'b10;

                //T4=T1^2
                T4_sel <= 2'b00;
                T4Load <= 1;
                state <= 5'b00010;
            end

            5'b00010: begin
                MUL1_IN_VALID <= 0;
                MUL2_IN_VALID <= 0;
                T4Load <= 0;
                

                //Z2=T1*Z2 finish
                if (MUL1_OUT_VALID == 1) begin
                    mul1_out_valid_tmp <= 1;
                    Z2Load <= 1;
                    Z2_sel <= 2'b11;
                end
                //T3=Z1*Z2 finish
                if (MUL2_OUT_VALID == 1) begin
                    mul2_out_valid_tmp <= 1;
                    T3Load <= 1;
                    T3_sel <= 1;
                end
                if (mul1_out_valid_tmp == 1 && mul2_out_valid_tmp == 1) begin
                    state <= 5'b00011;
                    mul1_out_valid_tmp <= 0;
                    mul2_out_valid_tmp <= 0;
                end

            end
            5'b00011: begin

                Z2Load <= 0;
                T3Load <= 0;

                //T4=T4+T2
                add21_sel <= 2'b10;
                add22_sel <= 2'b01;

                T4Load <= 1;
                T4_sel <= 2'b01;

                state <= 5'b00100;
            end
            5'b00100: begin
                $display("state 5'b00100\n");
                T4Load <= 0;

                //T4=T4*T3
                MUL1_IN_VALID <= 1;
                mul11_sel <= 2'b00;
                mul12_sel <= 0;

                //T3=T3*T1
                MUL2_IN_VALID <= 1;
                mul21_sel <= 0;
                mul22_sel <= 2'b01;

                state <= 5'b00101;
            end
            5'b00101: begin

                MUL1_IN_VALID <= 0;
                MUL2_IN_VALID <= 0;

                if (MUL1_OUT_VALID == 1) begin
                    mul1_out_valid_tmp <= 1;
                    T4Load <= 1;
                    T4_sel <= 2'b10;
                end
                if (MUL2_OUT_VALID == 1) begin
                    mul2_out_valid_tmp <= 1;
                    T3Load <= 1;
                    T3_sel <= 1;
                end
                if (mul1_out_valid_tmp == 1 && mul2_out_valid_tmp == 1) begin
                    state <= 5'b00110;
                    mul1_out_valid_tmp <= 0;
                    mul2_out_valid_tmp <= 0;
                end
            end
            5'b00110: begin
                T3Load <= 0;
                T4Load <= 0;

                //Z1=T1*Z1
                MUL2_IN_VALID <= 1;
                mul21_sel <= 1;
                mul22_sel <= 2'b01;

                //T3=1/T3
                INV_IN_VALID <= 1;

                state <= 5'b00111;
            end
            5'b00111: begin
                INV_IN_VALID <= 0;
                MUL2_IN_VALID <= 0;

                if (MUL2_OUT_VALID == 1) begin
                    state <= 5'b01000;
                    Z1Load <= 1;
                    Z1_sel <= 2'b10;
                end

            end
            5'b01000: begin
                //Z1=X1+Z1
                Z1Load <= 1;
                Z1_sel <= 2'b01;

                //Z2=Z2+X2
                add21_sel <= 2'b01;
                add22_sel <= 2'b00;
                Z2Load <= 1;
                Z2_sel <= 2'b01;

                //X1=X1*Z2
                MUL1_IN_VALID <= 1;
                mul11_sel <= 2'b01; //X1
                mul12_sel <= 1;		//Z2

                state <= 5'b01001;
            end
            5'b01001: begin
                MUL1_IN_VALID <= 0;

                //Z2=Z1*Z2
                MUL2_IN_VALID <= 1;
                mul21_sel <= 1;
                mul22_sel <= 2'b10;

                state <= 5'b01010;
            end
            5'b01010: begin
                MUL2_IN_VALID <= 0;

                if (MUL1_OUT_VALID == 1) begin
                    mul1_out_valid_tmp <= 1;
                    X1Load <= 1;
                    X1_sel <= 1;
                end
                if (MUL2_OUT_VALID == 1) begin
                    mul2_out_valid_tmp <= 1;
                    Z2Load <= 1;
                    Z2_sel <= 2'b10;
                end
                if (mul1_out_valid_tmp == 1 && mul2_out_valid_tmp == 1) begin
                    state <= 5'b01011;
                    mul1_out_valid_tmp <= 0;
                    mul2_out_valid_tmp <= 0;
                end
            end
            5'b01011: begin
                //T4=Z2+T4
                add21_sel <= 2'b10;
                add22_sel <= 2'b00;
                T4Load <= 1;
                T4_sel <= 2'b01;

                state <= 5'b01100;
            end
            5'b01100: begin
                T4Load <= 0;
                if (INV_OUT_VALID == 1) begin
                    T3Load <= 1;
                    T3_sel <= 0;
                    state <= 5'b01101;
                end
            end
            5'b01101: begin
                //T4=T3*T4
                MUL1_IN_VALID <= 1;
                mul11_sel <= 2'b00;	//T4
                mul12_sel <= 0;		//T3

                //X2=T3*X1
                MUL2_IN_VALID <= 1;
                mul21_sel <= 0;
                mul22_sel <= 2'b00;

                state <= 5'b01110;
            end
            5'b01110: begin
                MUL1_IN_VALID <= 0;
                MUL2_IN_VALID <= 0;

                if (MUL1_OUT_VALID == 1) begin

                    mul1_out_valid_tmp <= 1;
                    T4Load <= 1;
                    T4_sel <= 2'b10;
                end
                if (MUL2_OUT_VALID == 1) begin
                    mul2_out_valid_tmp <= 1;
                    X2Load <= 1;
                    X2_sel <= 1;
                end
                if (mul1_out_valid_tmp == 1 && mul2_out_valid_tmp == 1) begin
                    state <= 5'b01111;
                    mul1_out_valid_tmp <= 0;
                    mul2_out_valid_tmp <= 0;
                end
            end
            5'b01111: begin
                T4Load <= 0;
                X2Load <= 0;

                //Z2=X2+T1
                add21_sel <= 2'b11;
                add22_sel <= 2'b10;
                Z2Load <= 1;
                Z2_sel <= 2'b01;

                state <= 5'b10000;
            end
            5'b10000: begin
                //Z2=Z2*T4
                MUL1_IN_VALID <= 1;
                mul11_sel <= 2'b00;
                mul12_sel <= 1;

                state <= 5'b10001;
            end
            5'b10001: begin
                MUL1_IN_VALID <= 0;
                if (MUL1_OUT_VALID == 1) begin
                    Z2Load <= 1;
                    Z2_sel <= 2'b11;
                    state <= 5'b10010;
                end
            end
            5'b10010: begin
                //Z2=Z2+T2
                add21_sel <= 2'b00;
                add22_sel <= 2'b00;
                Z2Load <= 1;
                Z2_sel <= 2'b01;
                state <= 5'b10011;
            end
            END: begin
                Z2Load <= 0;
                state <= 5'b10100;
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end

end

endmodule
