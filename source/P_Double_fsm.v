`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    22:36:45 12/03/2020
// Design Name:
// Module Name:    P_Double_fsm
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
module P_Double_fsm(
           CLK,
           RST_N,
           ERROR,
           MUL_OUT_VALID,
           IN_VALID,
           X1Clear,
           X1Load,
           Z1Clear,
           Z1Load,
           //T1Clear,
           //T1Load,
           MUL_IN_VALID,
           OUT_STATE,
           X1_sel,
           Z1_sel
       );

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
input ERROR;                              //乘法器检测到错误
input MUL_OUT_VALID;                      //乘法器输出有效
input IN_VALID;

output reg X1Clear;
output reg X1Load;
output reg Z1Clear;
output reg Z1Load;
//output reg T1Clear;
//output reg T1Load;

output reg MUL_IN_VALID;
output reg [3 : 0] OUT_STATE;
output reg [1: 0] X1_sel;
output reg Z1_sel;

reg [3: 0] state;

always @(posedge CLK) begin
    if (!RST_N) begin
        state <= IDLE;
        OUT_STATE <= 0;
        MUL_IN_VALID <= 0;

        X1Clear <= 1;
        Z1Clear <= 1;
        //T1Clear <= 1;

        X1Load <= 0;
        Z1Load <= 0;
        //T1Load <= 0;
    end
    else begin
        OUT_STATE <= state;
        case (state)
            IDLE: begin

                X1Load <= 0;
                Z1Load <= 0;
                //T1Load <= 0;

                MUL_IN_VALID <= 0;

                if (IN_VALID) begin
                    state <= INIT;
                end
                else begin
                    state <= IDLE;
                end
            end
            INIT: begin
                X1Clear <= 0;
                Z1Clear <= 0;
                //T1Clear <= 0;

                X1Load <= 1;
                Z1Load <= 1;
                //T1Load <= 0;

                X1_sel <= 2'b10;
                Z1_sel <= 1;
                if (!IN_VALID) begin
                    state <= START;
                end

            end
            START: begin
                //X1=X1^2 Z1=Z1^2
                X1Load <= 1;
                Z1Load <= 1;

                Z1_sel <= 0;
                X1_sel <= 2'b01;

                state <= S1;
            end
            S1: begin
                X1Load <= 0;
                Z1Load <= 0;

                MUL_IN_VALID <= 1;

                state <= S2;
            end
            S2: begin
                MUL_IN_VALID <= 0;

                //X1=X1^2 Z1=Z1^2
                X1Load <= 1;
                Z1Load <= 1;

                Z1_sel <= 0;
                X1_sel <= 2'b01;

                state <= S3;
            end
            S3: begin
                //X1=X1+Z1
                X1_sel <= 0;
                Z1Load <= 0;
                X1Load <= 1;

                state <= S4;
            end
            S4: begin
                X1Load <= 0;
                if (MUL_OUT_VALID == 1) begin
                    //T1Load <= 1;
                    state <= OUTPUT;
                end
            end
            OUTPUT: begin
                //T1Load <= 0;
                state <= IDLE;
            end
            default: begin
                state <= IDLE;
            end
        endcase

        //于任意状态下跳转至初始化状态 增加于2020-12-19
        if (IN_VALID==1) begin
            //$display("P_Double state %d jump to INIT\n",state);
            state<=INIT;
        end
    end
end
endmodule
