`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    15:15:22 11/15/2020
// Design Name:
// Module Name:    keyscan
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
module keyscan_fault(
           CLK,
           RST_N,
           key_in,
           op_code,
           key_load,
           key_check,
           keyscan_en,
           keyfind_en,
           key_first_found,
           ki,
           key_cnt,
           key_state
       );
parameter N = 233; //位宽
parameter
    KEY_IS_ZERO = 2'b01,
    KEY_IS_ONE = 2'b11;

input CLK;
input RST_N;
input key_load;
input key_check;
input keyscan_en;
input keyfind_en;
input [N - 1: 0] key_in;
input [1: 0] op_code; 
//01表示存储到临时备份寄存器 
//10表示从临时备份寄存器存储到备份寄存器 
//11表示从备份寄存器恢复到中间值寄存器

output reg ki;
output reg key_first_found;
output reg [1: 0] key_state; //00表示正常 01表示k为0 11表示k为1.
output reg [7: 0] key_cnt;
reg [N - 1: 0] key;
reg [2: 0] state;

//备份寄存器
reg [7: 0] pre_cnt;
reg [N - 1: 0] pre_key;

//临时备份寄存器
reg [7: 0] pre_cnt_tmp;
reg [N - 1: 0] pre_key_tmp;

parameter
    IDLE = 3'b000,
    INIT = 3'b001,
    PRE_JUDGE = 3'b011,
    KEY_FIRST_SCAN = 3'b010,
    KEY_SCAN = 3'b110;

always @(posedge CLK) begin
    if (!RST_N) begin
        key <= 0;
        key_cnt <= 0;
        ki <= 0;
        key_first_found <= 0;
        key_state <= 0;
        state <= IDLE;
    end
    else begin
        case (state)
            IDLE: begin
                if (key_load == 1) begin
                    state <= INIT;
                end
                if (keyscan_en == 1) begin
                    state <= KEY_SCAN;
                end
                if (keyfind_en == 1) begin
                    state <= KEY_FIRST_SCAN;
                end
                if (op_code == 2'b01) begin
                    pre_key_tmp <= key;
                    pre_cnt_tmp <= key_cnt;
                end
                else if (op_code == 2'b10) begin
                    pre_key <= pre_key_tmp;
                    pre_cnt <= pre_cnt_tmp;
                end
                else if (op_code == 2'b11) begin
                    key <= pre_key;
                    key_cnt <= pre_cnt;
                end
            end
            INIT: begin
                key <= key_in;
                key_cnt <= 0;

                pre_key <= key_in; //初始备份密钥为输入密钥
                pre_cnt <= 0;
                
                key_state <= 2'b00;
                ki <= 0;
                key_first_found <= 0;
                if (key_check == 1) begin
                    state <= PRE_JUDGE;
                end
                else begin
                    state <= INIT;
                end
            end
            PRE_JUDGE: begin
                if (key == 0) begin
                    //$display("KEY_IS_ZERO\n");
                    key_state <= KEY_IS_ZERO;
                end
                if (key == 1) begin
                    key_state <= KEY_IS_ONE;
                end
                state <= IDLE;
            end
            KEY_FIRST_SCAN: begin
                //$display("scan module key=%b\n", key);
                key <= key << 1;
                key_cnt <= key_cnt + 1'b1;
                if (key[N - 1] == 1) begin
                    key_first_found <= 1;
                    ki <= 1;
                    state <= IDLE;
                end
                else begin
                    state <= KEY_FIRST_SCAN;
                end
            end
            KEY_SCAN: begin
                //$display($time, "scan module key=%b\n", key);
                ki <= key[N - 1];
                key <= key << 1;
                key_cnt <= key_cnt + 1'b1;
                state <= IDLE;
            end
            default: begin
                state <= IDLE;
            end
        endcase

    end
end
endmodule
