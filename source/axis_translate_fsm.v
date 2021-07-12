`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    20:32:24 11/16/2020
// Design Name:
// Module Name:    axis_translate_fsm
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
module axis_translate_fsm(
           CLK,
           RST_N,
           ERROR,
           MUL_OUT_VALID,
           IN_VALID,
           X1Clear,
           X1Load,
           X2Clear,
           X2Load,
           Z2Clear,
           Z2Load,
           T1Clear,
           T1Load,
           T2Clear,
           T2Load,
           MUL_IN_VALID,
           OUT_STATE,
           squa_sel,
           T1_sel,
           T2_sel
       );

parameter
    IDLE = 4'b0000,
    INIT = 4'b0001,
    START = 4'b0010,
    S1 = 4'b0011,
    S2 = 4'b0100,
    S3 = 4'b0101,
    S4 = 4'b0110,
    S5 = 4'b0111,
    S6 = 4'b1000,
    S7 = 4'b1001,
    S8 = 4'b1010,
    END = 4'b1011;

input CLK;
input RST_N;
input ERROR;                              //乘法器检测到错误
input MUL_OUT_VALID;                      //乘法器输出有效
input IN_VALID;

output reg X1Clear;
output reg X1Load;
output reg X2Clear;
output reg X2Load;
output reg Z2Clear;
output reg Z2Load;
output reg T1Clear;
output reg T1Load;
output reg T2Clear;
output reg T2Load;

output reg MUL_IN_VALID;
output reg [3 : 0] OUT_STATE;
output reg T1_sel;
output reg T2_sel;

output reg [1: 0] squa_sel;

reg [3: 0] state;

always @(posedge CLK) begin
    if (!RST_N) begin
        state <= IDLE;
        OUT_STATE <= 0;
        MUL_IN_VALID <= 0;
        X1Clear <= 1;
        X2Clear <= 1;
        Z2Clear <= 1;
        T1Clear <= 1;
        T2Clear <= 1;
    end
    else begin
        OUT_STATE <= state;
        case (state)
            IDLE: begin
                // X1Clear <= 1;
                // X2Clear <= 1;
                // Z2Clear <= 1;
                // T1Clear <= 1;
                // T2Clear <= 1;
                X1Load <= 0;
                X2Load <= 0;
                Z2Load <= 0;
                T1Load <= 0;
                T2Load <= 0;
                // T1_sel <= 0;
                // T2_sel <= 0;
                // squa_sel <= 2'b00;

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
                X2Clear <= 0;
                Z2Clear <= 0;
                T1Clear <= 0;
                T2Clear <= 0;

                X1Load <= 0;
                X2Load <= 0;
                Z2Load <= 0;

                T1Load <= 1;
                T2Load <= 1;

                T1_sel <= 1;
                T2_sel <= 1;
                if (!IN_VALID) begin
                    state <= START;
                end

            end
            START: begin
                MUL_IN_VALID <= 1;
                state <= S1;
            end
            S1: begin
                //x*Z1
                MUL_IN_VALID <= 0;
                squa_sel <= 2'b01;
                T2Load <= 1;
                T2_sel <= 0;
                state <= S2;
            end
            S2: begin
                T2Load <= 0;
                if (MUL_OUT_VALID == 1) begin
                    $display("mul finish\n");
                    X1Load <= 1;
                    T1_sel <= 0;
                    state <= S3;
                end
            end
            S3: begin
                X1Load <= 0;
                squa_sel <= 2'b00;
                T1Load <= 1;
                state <= S4;
            end
            S4: begin
                T1Load <= 0;
                MUL_IN_VALID <= 1;
                state <= S5;
            end
            S5: begin
                MUL_IN_VALID <= 0;
                squa_sel <= 2'b01;
                T2Load <= 1;
                state <= S6;
            end
            S6: begin
                squa_sel <= 2'b10;
                T1Load <= 1;
                T2Load <= 0;
                state <= S7;
            end
            S7: begin
                T1Load <= 0;
                X2Load <= 1;
                state <= S8;
            end
            S8: begin
                X2Load <= 0;
                if (MUL_OUT_VALID == 1) begin
                    Z2Load <= 1;
                    state <= END;
                end
            end
            END: begin
                state <= IDLE;
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end
end
endmodule
