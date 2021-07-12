`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    19:46:57 08/27/2020
// Design Name:
// Module Name:    P_AddDouble_fsm
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
module P_AddDouble_fsm(
           CLK,
           RST_N,
           ERROR1,
           ERROR2,
           ERROR3,
           MUL1_OUT_VALID,
           MUL2_OUT_VALID,
           MUL3_OUT_VALID,
           IN_VALID,
           mul12_sel,
           mul22_sel,
           squa_sel,
           T1Clear,
           T1Load,
           X1Clear,
           X1Load,
           Z1Clear,
           Z1Load,
           X2Clear,
           X2Load,
           Z2Clear,
           Z2Load,
           X1Sel,
           Z1Sel,
           X2Sel,
           Z2Sel,
           T1Sel,
           MUL1_IN_VALID,
           MUL2_IN_VALID,
           MUL3_IN_VALID,
           OUT_STATE
       );


input CLK;
input RST_N;
input ERROR1, ERROR2, ERROR3;
input IN_VALID;
input MUL1_OUT_VALID;
input MUL2_OUT_VALID;
input MUL3_OUT_VALID;

output reg mul12_sel;
output reg mul22_sel;
output reg [1: 0] squa_sel;

output reg T1Clear;
output reg T1Load;
output reg X1Clear;
output reg X1Load;
output reg Z1Clear;
output reg Z1Load;
output reg X2Clear;
output reg X2Load;
output reg Z2Clear;
output reg Z2Load;
output reg [1: 0] X1Sel;
output reg [1: 0] Z1Sel;
output reg [1: 0] X2Sel;
output reg Z2Sel;
output reg T1Sel;
output reg MUL1_IN_VALID;
output reg MUL2_IN_VALID;
output reg MUL3_IN_VALID;

output reg [3: 0] OUT_STATE;
reg [3: 0] state;

reg mul1_out_valid_tmp;
reg mul2_out_valid_tmp;
reg mul3_out_valid_tmp;

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

always @(posedge CLK) begin
    if (!RST_N) begin
        mul1_out_valid_tmp <= 0;
        mul2_out_valid_tmp <= 0;
        mul3_out_valid_tmp <= 0;
        MUL1_IN_VALID <= 0;
        MUL2_IN_VALID <= 0;
        MUL3_IN_VALID <= 0;

        T1Clear <= 1;
        X1Clear <= 1;
        Z1Clear <= 1;
        X2Clear <= 1;
        Z2Clear <= 1;

        T1Load <= 0;
        X1Load <= 0;
        Z1Load <= 0;
        X2Load <= 0;
        Z2Load <= 0;

        state <= 0;
        OUT_STATE <= 0;
    end
    else begin
        OUT_STATE <= state;
        if (MUL1_OUT_VALID == 1) begin
            mul1_out_valid_tmp <= 1;
        end
        if (MUL2_OUT_VALID == 1) begin
            mul2_out_valid_tmp <= 1;
        end
        if (MUL3_OUT_VALID == 1) begin
            mul3_out_valid_tmp <= 1;
        end

        case (state)
            IDLE: begin
                T1Clear <= 0;
                T1Load <= 0;

                X1Clear <= 0;
                X1Load <= 0;

                Z1Clear <= 0;
                Z1Load <= 0;

                X2Clear <= 0;
                X2Load <= 0;

                Z2Clear <= 0;
                Z2Load <= 0;

                mul12_sel <= 0;
                mul22_sel <= 0;

                squa_sel <= 0;

                MUL1_IN_VALID <= 0;
                MUL2_IN_VALID <= 0;
                MUL3_IN_VALID <= 0;

                if (IN_VALID) begin
                    state <= INIT;
                end
                else begin
                    state <= IDLE;
                end
            end
            INIT: begin
                mul1_out_valid_tmp <= 0;
                mul2_out_valid_tmp <= 0;
                mul3_out_valid_tmp <= 0;

                T1Load <= 0;

                X1Load <= 1;
                X1Sel <= 0;

                Z1Load <= 1;
                Z1Sel <= 0;

                X2Load <= 1;
                X2Sel <= 0;

                Z2Load <= 1;
                Z2Sel <= 0;

                if (!IN_VALID) begin
                    state <= START;
                end
            end
            START: begin
                T1Load <= 0;
                X1Load <= 0;
                Z1Load <= 0;
                Z2Load <= 0;

                //执行乘法和平方运算
                mul12_sel <= 0;
                mul22_sel <= 1;

                MUL1_IN_VALID <= 1;
                MUL2_IN_VALID <= 1;

                //X2=X1^2
                squa_sel <= 2'b11; //X1
                X2Sel <= 2'b10;
                X2Load <= 1;


                state <= S1;
            end
            S1: begin
                $display("P_AD first two multiplication in adding\n");
                MUL1_IN_VALID <= 0;
                MUL2_IN_VALID <= 0;

                //T1=Z1^2
                squa_sel <= 2'b10; //select Z1
                T1Sel <= 0;
                T1Load <= 1;
                X2Load <= 0;
                state <= S2;

            end
            S2: begin
                T1Load <= 0;
                MUL3_IN_VALID <= 1;
                state <= S3;
            end
            S3: begin
                $display("P_AD first multiplication in double\n");
                MUL3_IN_VALID <= 0;
                squa_sel <= 2'b01; //X2=X2^2
                X2Load <= 1;
                state <= S4;
            end
            S4: begin
                X2Load <= 0;
                T1Load <= 1;
                squa_sel <= 2'b00; //T1=T1^2
                state <= S5;
            end
            S5: begin
                //X2=T1+X2
                T1Load <= 0;
                X2Sel <= 2'b01;
                X2Load <= 1;
                state <= S6;
            end
            S6: begin
                X2Load <= 0;
                //X1=X1*Z2 finished!
                if (MUL1_OUT_VALID == 1) begin
                    X1Sel <= 2'b10;
                    X1Load <= 1;
                end
                //Z1=Z1*X2 finished!
                if (MUL2_OUT_VALID == 1) begin
                    Z1Sel <= 2'b11;
                    Z1Load <= 1;
                end
                if (mul1_out_valid_tmp == 1 && mul2_out_valid_tmp == 1) begin

                    state <= S7;
                    mul1_out_valid_tmp <= 0;
                    mul2_out_valid_tmp <= 0;

                    MUL1_IN_VALID <= 1;
                    mul12_sel <= 1;

                    Z1Load <= 1; //Z1=X1+Z1;
                    Z1Sel <= 2'b10;
                end
            end
            S7: begin
                MUL1_IN_VALID <= 0;
                squa_sel <= 2'b10; //Z1=Z1^2
                Z1Sel <= 2'b01;
                state <= S8;
            end
            S8: begin
                Z1Load <= 0;
                //乘法器输入Z1更新
                MUL2_IN_VALID <= 1;
                mul22_sel <= 0;

                state <= S9;
            end
            S9: begin
                //乘法器读取Z1
                MUL2_IN_VALID <= 0;

                if (mul3_out_valid_tmp == 1) begin
                    mul3_out_valid_tmp <= 0;
                    Z2Load <= 1;
                    Z2Sel <= 1;
                    state <= S10;
                end
            end
            S10: begin
                Z2Load <= 0;
                if (mul1_out_valid_tmp == 1 && mul2_out_valid_tmp == 1) begin
                    state <= S11;
                    mul1_out_valid_tmp <= 0;
                    mul2_out_valid_tmp <= 0;

                    X1Load <= 1; //X1=X1*Z1
                    X1Sel <= 2'b10;
                    T1Load <= 1;
                    T1Sel <= 1;

                end
            end
            S11: begin
                state <= OUTPUT;
                X1Sel <= 2'b01;
                X1Load <= 1;
            end

            OUTPUT: begin
                X1Load <= 0;
                state <= IDLE;
            end
            default: begin
                state <= IDLE;
            end
        endcase

        //于任意状态下跳转至初始化状态 增加于2020-12-19
        if (IN_VALID==1) begin
            $display("P_AD state %d jump to INIT\n",state);
            state<=INIT;
        end
    end

end
endmodule
