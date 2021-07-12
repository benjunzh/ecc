`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    2020-01-02
// Design Name:
// Module Name:    INV_TOP
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
module inv_top(
           CLK,
           RST_N,
           IN_VALID,
           DIN,
           DOUT,
           OUT_VALID
       );
parameter N = 233; //位宽

input CLK;
input RST_N;
input IN_VALID;
input [N - 1 : 0] DIN;
output reg [N - 1 : 0] DOUT;
output reg OUT_VALID;

/*---- temp variable ----*/

wire [N - 1 : 0] s1_out;
wire [N - 1 : 0] s2_out;
wire [N - 1 : 0] t_sel_out;
wire [N - 1 : 0] reg_x_out;
wire [N - 1 : 0] reg_t_out;
wire XSel, ESel, TLoad, TClear, XLoad, XClear;
wire [1: 0] TSel;
wire [5 : 0] fsm_out_state;
wire [N - 1 : 0] DOUT_SQUA1;
wire [N - 1 : 0] DOUT_SQUA2;
wire [N - 1 : 0] DOUT_SQUA3;
wire [N - 1 : 0] DOUT_SQUA4;
wire [N - 1 : 0] DOUT_MULT;
wire IN_VALID_tmp;
wire OUT_VALID_tmp;
wire ERROR;
reg [N - 1 : 0] DIN_temp;

/*--------------例化计算模块------------------*/
mul_fault INV_mult1( .CLK(CLK),
                     .RST_N(RST_N),
                     .A(reg_x_out),
                     .B(reg_t_out),
                     .IN_VALID(IN_VALID_tmp),
                     .DOUT(DOUT_MULT),
                     .OUT_VALID(OUT_VALID_tmp),
                     .ERROR(ERROR)
                   );

square INV_squa1( .DIN(s2_out),
                  .DOUT(DOUT_SQUA1));
square INV_squa2( .DIN(DOUT_SQUA1),
                  .DOUT(DOUT_SQUA2));
square INV_squa3( .DIN(DOUT_SQUA2),
                  .DOUT(DOUT_SQUA3));
square INV_squa4( .DIN(DOUT_SQUA3),
                  .DOUT(DOUT_SQUA4));

select INV_s1(
           .SEL(XSel),
           .A(DOUT_MULT),
           .B(DIN_temp),
           .OUT(s1_out)
       );

select INV_s2(
           .SEL(ESel),
           .A(reg_x_out),
           .B(reg_t_out),
           .OUT(s2_out)
       );

register INV_x(
             .CLK(CLK),
             .CLEAR(XClear),
             .LOAD(XLoad),
             .OUT(reg_x_out),
             .IN(s1_out) );

register INV_t(
             .CLK(CLK),
             .CLEAR(TClear),
             .LOAD(TLoad),
             .OUT(reg_t_out),
             .IN(t_sel_out) );

select4to1 INV_t_sel(
               .SEL(TSel),
               .A(DOUT_SQUA4),
               .B(DOUT_SQUA3),
               .C(DOUT_SQUA2),
               .D(DOUT_SQUA1),
               .OUT(t_sel_out)
           );

inv_fsm INV_mf(
            .CLK(CLK),
            .RST_N(RST_N),
            .ERROR(ERROR),
            .IN_VALID(IN_VALID),
            .TLoad(TLoad),
            .TClear(TClear),
            .XLoad(XLoad),
            .XClear(XClear),
            .XSel(XSel),
            .ESel(ESel),
            .TSel(TSel),
            .MUL_OUT_VALID(OUT_VALID_tmp),
            .MUL_IN_VALID(IN_VALID_tmp),
            .OUT_STATE(fsm_out_state)
        );

always @(posedge CLK) begin
    if (!RST_N) begin
        DIN_temp <= 0;
        OUT_VALID <= 1'b0;
    end
    else if (IN_VALID) begin
        DIN_temp <= DIN;
    end
    else begin
        // $monitor($time, "IN_VALID_tmp=%d, OUT_VALID_tmp=%d\n",IN_VALID_tmp,OUT_VALID_tmp);
        // if (fsm_out_state==5 || fsm_out_state==4)begin
        //   $display("\nreg_x_out=%h, reg_t_out=%h\n",reg_x_out, reg_t_out);
        // end

        //输出state在数据上比状态机内部state慢一拍
        if (fsm_out_state == 6'b101001) begin
            $display($time, "INV_DOUT=%h", reg_t_out);
            DOUT <= reg_t_out;
            OUT_VALID <= 1'b1;
        end
        else begin
            DOUT <= reg_t_out;
            OUT_VALID <= 1'b0;
        end
    end
end

/*------------------------------------------*/

endmodule

