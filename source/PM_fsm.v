`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    14:28:07 11/15/2020
// Design Name:
// Module Name:    PM_fsm
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
module PM_fsm(
           CLK,
           RST_N,
           IN_VALID,
           ki,
           key_first_found,
           key_cnt,
           P_x_is_0,
           key_state,
           Mxy_OUT_VALID,
           axis_translate_out_valid,
           P_AD_OUT_VALID,
           keyscan_en,
           key_check,
           key_load,
           find_key_first,
           Mxy_IN_VALID,
           P_AD_IN_VALID,
           axis_translate_in_valid,
           X1Clear,
           X1Load,
           Z1Clear,
           Z1Load,
           X2Clear,
           X2Load,
           Z2Clear,
           Z2Load,
           AD_X1Sel,
           AD_Z1Sel,
           AD_X2Sel,
           AD_Z2Sel,
           X1Sel,
           Z1Sel,
           X2Sel,
           Z2Sel,
           OUT_STATE
       );

input CLK;
input RST_N;
input IN_VALID;
input ki;
input key_first_found;
input P_x_is_0;
input [1: 0] key_state;
input [7: 0] key_cnt;
input Mxy_OUT_VALID;
input axis_translate_out_valid;
input P_AD_OUT_VALID;

output reg key_load;
output reg key_check;
output reg keyscan_en;
output reg find_key_first;
output reg P_AD_IN_VALID;
output reg Mxy_IN_VALID;
output reg axis_translate_in_valid;

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
output reg [1: 0] Z2Sel;

output reg AD_X1Sel;
output reg AD_Z1Sel;
output reg AD_X2Sel;
output reg AD_Z2Sel;

output reg [3: 0] OUT_STATE;

reg [1: 0] delay_cnt;
reg [3: 0] state;

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

always @(posedge CLK) begin
    if (!RST_N) begin

        X1Clear <= 1;
        X1Load <= 0;

        Z1Clear <= 1;
        Z1Load <= 0;

        X2Clear <= 1;
        X2Load <= 0;

        Z2Clear <= 1;
        Z2Load <= 0;

        X1Sel <= 0;
        Z1Sel <= 0;
        X2Sel <= 0;
        Z2Sel <= 0;
        AD_X1Sel <= 0;
        AD_Z1Sel <= 0;
        AD_X2Sel <= 0;
        AD_Z2Sel <= 0;

        key_load <= 0;
        key_check <= 0;
        keyscan_en <= 0;
        find_key_first <= 0;
        P_AD_IN_VALID <= 0;
        Mxy_IN_VALID <= 0;
        axis_translate_in_valid <= 0;

        OUT_STATE <= 0;
        state <= 0;
        delay_cnt <= 0;
    end
    else begin
        OUT_STATE <= state;
        case (state)
            IDLE: begin
                X1Clear <= 0;
                Z1Clear <= 0;
                X2Clear <= 0;
                Z2Clear <= 0;
                X1Load <= 0;
                Z1Load <= 0;
                X2Load <= 0;
                Z2Load <= 0;

                delay_cnt <= 0;
                X1Sel <= 0;
                Z1Sel <= 0;
                X2Sel <= 0;
                Z2Sel <= 0;
                AD_X1Sel <= 0;
                AD_Z1Sel <= 0;
                AD_X2Sel <= 0;
                AD_Z2Sel <= 0;

                key_load <= 0;
                key_check <= 0;
                keyscan_en <= 0;
                find_key_first <= 0;
                P_AD_IN_VALID <= 0;
                Mxy_IN_VALID <= 0;
                axis_translate_in_valid <= 0;

                if (IN_VALID) begin
                    state <= INIT;
                end
                else begin
                    state <= IDLE;
                end
            end
            INIT: begin
                key_load <= 1; //????????????
                if (!IN_VALID) begin
                    key_load <= 0;
                    state <= PRE_JUDGE;
                    key_check <= 1; //?????????????????????????????????????????????????????????????????????????????????1???0
                end
            end
            PRE_JUDGE: begin
                $display($time, "PRE_JUDGE key_state=%h\n", key_state);
                key_check <= 0; 

                //???????????????????????????????????????????????????clock
                //clock1 ????????????????????????key_check????????????
                //clock2 ????????????key_state??????
                //clock3 ??????????????????key_state
                if (delay_cnt < 2) begin
                    delay_cnt <= delay_cnt + 1;
                end
                else begin
                    delay_cnt <= 0;

                    if (key_state == KEY_IS_ZERO || key_state == KEY_IS_ONE || P_x_is_0 == 1'b1) begin
                        state <= OUTPUT;
                    end
                    else begin
                        axis_translate_in_valid <= 1; //??????????????????
                        find_key_first <= 1; //??????????????????????????????????????????
                        state <= PRE_COMPUTE;
                    end
                end
            end
            PRE_COMPUTE: begin
                // $display($time, "PRE_COMPUTE\n");
                //$display($time, "cnt=%h\n",key_cnt);
                axis_translate_in_valid <= 0;
                find_key_first <= 0;

                if (axis_translate_out_valid == 1) begin
                    X1Load <= 1;
                    Z1Load <= 1;
                    X2Load <= 1;
                    Z2Load <= 1;
                    X1Sel <= 0;
                    Z1Sel <= 0;
                    X2Sel <= 0;
                    Z2Sel <= 0;
                    state <= KEY_FIRST_SCAN;
                end
            end
            KEY_FIRST_SCAN: begin
                //??????KEY_FIRST_SCAN?????????PRE_COMPUTE?????????????????????KEY_FIRST_SCAN????????????????????????
                X1Load <= 0;
                Z1Load <= 0;
                X2Load <= 0;
                Z2Load <= 0;
                if (!key_first_found) begin
                    state <= KEY_FIRST_SCAN;
                end
                else begin
                    state <= KEY_SCAN;
                end
            end
            KEY_SCAN: begin
                //$display($time, " start key scan\n");
                keyscan_en <= 1;
                state <= KEY_JUDGE;
            end

            KEY_JUDGE: begin
                //$display("KEY_JUDGE ki=%h\n", ki);
                
                keyscan_en <= 0;
                //???????????????????????????????????????????????????clock
                //clock1 keyscan_en??????
                //clock2 ????????????????????????keyscan_en????????????
                //clock3 ????????????ki??????
                //clock4 ??????????????????ki
                //clock1???KEY_SCAN?????? clock4???KEY_JUDGE?????? ??????WAIT1??????????????????????????????

                if (delay_cnt < 2) begin
                    delay_cnt <= delay_cnt + 1;
                end
                else begin
                    delay_cnt <= 0;
                    P_AD_IN_VALID <= 1; //???????????????????????????????????????????????????
                    if (ki == 1) begin
                        AD_X1Sel <= 0;
                        AD_Z1Sel <= 0;
                        AD_X2Sel <= 1;
                        AD_Z2Sel <= 1;
                    end
                    else begin
                        AD_X1Sel <= 1;
                        AD_Z1Sel <= 1;
                        AD_X2Sel <= 0;
                        AD_Z2Sel <= 0;
                    end
                    state <= P_AD;
                end
            end
            P_AD: begin
                P_AD_IN_VALID <= 0;
                if (P_AD_OUT_VALID == 1) begin
                    X1Load <= 1;
                    Z1Load <= 1;
                    X2Load <= 1;
                    Z2Load <= 1;
                    state <= STROAGE;
                    if (ki == 1) begin
                        $display($time, " P_AD finish : ki == 1\n");
                        //P1=P_add P2=P_double
                        X1Sel <= 2'b10;
                        Z1Sel <= 2'b10;
                        X2Sel <= 2'b01;
                        Z2Sel <= 2'b01;
                    end
                    else begin
                        $display($time, " P_AD finish : ki == 0\n");
                        //P2=P_add P1=P_double
                        X1Sel <= 2'b01;
                        Z1Sel <= 2'b01;
                        X2Sel <= 2'b10;
                        Z2Sel <= 2'b10;
                    end
                end
            end
            STROAGE: begin

                X1Load <= 0;
                Z1Load <= 0;
                X2Load <= 0;
                Z2Load <= 0;
                if (key_cnt == 233) begin
                    state <= Y_REC;
                    Mxy_IN_VALID <= 1;
                end
                else begin
                    state <= KEY_SCAN;
                end
            end
            Y_REC: begin
                Mxy_IN_VALID <= 0;
                if (Mxy_OUT_VALID == 1) begin
                    state <= OUTPUT;
                end
            end
            
            OUTPUT: begin
                $display($time, "OUTPUT\n");
                state <= IDLE;
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end
end
endmodule
