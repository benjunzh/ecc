`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    17:08:45 12/04/2020
// Design Name:
// Module Name:    PV_fsm
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
module PV_fsm(
           CLK,
           RST_N,
           ERROR1,
           ERROR2,
           MUL1_OUT_VALID,
           mode,
           IN_VALID,
           mul11_sel,
           mul12_sel,
           add12_sel,
           X1_sel,
           X2_sel,
           Z2_sel,
           X1Clear,
           X1Load,
           X2Clear,
           X2Load,
           Z1Clear,
           Z1Load,
           Z2Clear,
           Z2Load,
           MUL1_IN_VALID,
           OUT_STATE
       );

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
    OUTPUT = 4'b1101;

input CLK;
input RST_N;

input ERROR1, ERROR2;
input IN_VALID;
input MUL1_OUT_VALID;
input mode;

output reg mul11_sel;
output reg mul12_sel;
output reg add12_sel;
output reg [1: 0] X1_sel;
output reg [1: 0] X2_sel;
output reg Z2_sel;

output reg X1Clear;
output reg X1Load;
output reg X2Clear;
output reg X2Load;
output reg Z1Clear;
output reg Z1Load;
output reg Z2Clear;
output reg Z2Load;

output reg MUL1_IN_VALID;

output reg [3: 0] OUT_STATE;

reg [3: 0] state;

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

		MUL1_IN_VALID<=0;

        mul11_sel<=0;
        mul12_sel<=0;
        add12_sel<=0;
        X1_sel<=0;
        X2_sel<=0;
        Z2_sel<=0;

        OUT_STATE <= 0;
        state <= 0;

    end
    else begin
        OUT_STATE <= state;

        //Pv+P2=2*P2
        if (mode == 0) begin
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

                    if (IN_VALID) begin
                        state <= INIT;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                INIT: begin
                    X1Load <= 1;
                    Z1Load <= 1;
                    X2Load <= 1;
                    Z2Load <= 1;
                    X1_sel <= 0;
                    X2_sel <= 0;
                    Z2_sel <= 0;

                    if (!IN_VALID) begin
                        state <= START;
                    end
                end
                START: begin
                    X1Load <= 0;
                    Z1Load <= 0;
                    X2Load <= 0;
                    Z2Load <= 0;
                    MUL1_IN_VALID <= 1;
                    
                    mul11_sel <= 1;
                    mul12_sel <= 1;
                    state<=S1;
                    $display($time, "PV MUL START\n");
                end
                S1: begin
                    MUL1_IN_VALID <= 0;
                    
                    if (MUL1_OUT_VALID == 1) begin
                       
                        X1Load<=1;
                        X1_sel<=2'b10;

                        MUL1_IN_VALID <= 1;
                        mul11_sel <= 0;
                        mul12_sel <= 0;
                        state <= S2;
                    end
                end
                S2: begin
                    X1Load<=0;
                    MUL1_IN_VALID <= 0;
                    if (MUL1_OUT_VALID == 1) begin
                        X2Load<=1;
                        X2_sel<=2'b10;
                        state <= OUTPUT;
                    end
                end
                OUTPUT: begin
                    X2Load<=0;
                	$display($time, "PV module state=OUTPUT\n");
                    state <= IDLE;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
        else begin
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

                    if (IN_VALID) begin
                        state <= INIT;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                INIT: begin
                    X1Load <= 1;
                    Z2Load <= 1;
                    X1_sel <= 0;
                    Z2_sel <= 0;
                    if (!IN_VALID) begin
                        state <= START;
                    end
                end
                START: begin
                    $display("start PV\n");
                    //X2=X1^2
                    X1Load <= 0;
                    Z1Load <= 0;
                    Z2Load <= 0;
                    X2_sel <= 2'b01;
                    X2Load <= 1;
                    state <= S1;
                end
                S1: begin
                    //X1=X1*Z2 
                    X2Load <= 0;
                    MUL1_IN_VALID <= 1;
                    mul11_sel <= 1;
                    mul12_sel <= 0;
                    state<=S2;
                end
                S2: begin
                    MUL1_IN_VALID <= 0;
                    if (MUL1_OUT_VALID == 1) begin
                        X2Load<=1;
                        X2_sel<=2'b10;
                        MUL1_IN_VALID <= 1;
                        mul11_sel <= 1;
                        mul12_sel <= 1;
                        state <= S3;
                    end
                end
                S3: begin
                    X2Load <= 0;
                    MUL1_IN_VALID <= 0;
                    
                    //Z2=Z2^2
                    Z2Load <= 1;
                    Z2_sel <= 1;

                    state<=S4;
                end
                S4: begin
                    Z2Load <= 0;
                    
                    if (MUL1_OUT_VALID == 1) begin
                        X1Load<=1;
                        X1_sel<=2'b10;
                        state <= S5;
                    end
                end
                S5: begin
                    X1Load<=1;
                    X1_sel <= 2'b01;
                    add12_sel <= 1;

                    state <= S6;
                end
                S6: begin
                    X1Load <= 1;
                    add12_sel <= 0;
                    state <= OUTPUT;
                end
                OUTPUT: begin
                    X1Load <= 0;
                    state <= IDLE;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end

    end
end
endmodule
