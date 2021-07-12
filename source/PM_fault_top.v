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
module PM_fault_top(
           CLK,
           RST_N,
           DIN_P_x,
           DIN_P_y,
           DIN_2P_x,
           random_z,
           key,
           IN_VALID,
           DOUT_x,
           DOUT_y,
           OUT_VALID
       );

parameter N = 233; //位宽

parameter
    IDLE = 5'b00000,
    INIT = 5'b00001,
    PRE_JUDGE = 5'b00011,
    AXIS_TRANS = 5'b00010,
    PRE_COMPUTE = 5'b00110,
    WAIT_PRE_COMPUTE = 5'b00111,
    KEY_FIRST_SCAN = 5'b00101,
    KEY_SCAN = 5'b00100,
    WAIT1 = 5'b01100,
    KEY_JUDGE = 5'b01101,
    WAIT2 = 5'b01111,
    P_AD = 5'b01110,
    STROAGE = 5'b01010,
    COHERENCE_CHECK = 5'b01011,
    DATA_BACKUP = 5'b01001,
    RECOVER = 5'b01000,
    RECOVER_WAIT = 5'b11000,
    SCAN_STATE_CHECK = 5'b11001,
    P_XY = 5'b11011,
    P_XY_OUTPUT = 5'b11010,
    POINT_VERIFY = 5'b11110,
    OUTPUT = 5'b11111;

parameter
    KEY_IS_ZERO = 2'b01,
    KEY_IS_ONE = 2'b11;

input CLK;
input RST_N;
input IN_VALID;
input [N - 1: 0] DIN_P_x;
input [N - 1: 0] DIN_P_y;
input [N - 1: 0] DIN_2P_x;
input [N - 1: 0] random_z;
input [N - 1: 0] key;
output reg OUT_VALID;
output reg [N - 1: 0] DOUT_x;
output reg [N - 1: 0] DOUT_y;

//寄存器
reg [N - 1: 0] P_x;
reg [N - 1: 0] P_y;
reg [N - 1: 0] P_z;
reg P_x_is_0;
reg [N - 1: 0] INIT_Zv;
reg [N - 1: 0] PD_x;

//备份寄存器
reg [N - 1: 0] pre_X1;
reg [N - 1: 0] pre_Z1;
reg [N - 1: 0] pre_X2;
reg [N - 1: 0] pre_Z2;
reg [N - 1: 0] pre_Xv;
reg [N - 1: 0] pre_Zv;

//临时备份寄存器
reg [N - 1: 0] pre_X1_tmp;
reg [N - 1: 0] pre_Z1_tmp;
reg [N - 1: 0] pre_X2_tmp;
reg [N - 1: 0] pre_Z2_tmp;
reg [N - 1: 0] pre_Xv_tmp;
reg [N - 1: 0] pre_Zv_tmp;
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
wire XvClear;
wire XvLoad;
wire ZvClear;
wire ZvLoad;
wire XdClear;
wire XdLoad;
wire ZdClear;
wire ZdLoad;
wire [N - 1: 0] X1;
wire [N - 1: 0] Z1;
wire [N - 1: 0] X2;
wire [N - 1: 0] Z2;
wire [N - 1: 0] Xv;
wire [N - 1: 0] Zv;
wire [N - 1: 0] Xd;
wire [N - 1: 0] Zd;

//坐标转换模块
wire axis_trans_in_valid;
wire [N - 1: 0] axis_trans_X1;
wire axis_trans_out_valid;

//寄存器输入选择器模块
wire [1: 0] X1Sel;
wire [1: 0] Z1Sel;
wire [1: 0] X2Sel;
wire [1: 0] Z2Sel;
wire [1: 0] XvSel;
wire [1: 0] ZvSel;
wire [N - 1: 0] X1_sel_out;
wire [N - 1: 0] Z1_sel_out;
wire [N - 1: 0] X2_sel_out;
wire [N - 1: 0] Z2_sel_out;
wire [N - 1: 0] Zv_sel_out;
wire [N - 1: 0] Xv_sel_out;

//点加模块1例化
wire P_ADD1_IN_VALID;
wire P_ADD1_OUT_VALID;
wire [N - 1: 0] P_ADD1_DOUT_X;
wire [N - 1: 0] P_ADD1_DOUT_Z;

//点加模块2例化
wire P_ADD2_IN_VALID;
wire P_ADD2_OUT_VALID;
wire [N - 1: 0] P_ADD2_DOUT_X;
wire [N - 1: 0] P_ADD2_DOUT_Z;
wire [N - 1: 0] P_ADD2_DIN_P_x;

//点加倍点模块输入选择器
wire Group_Sel1;
wire Group_Sel2;
wire Group_Sel3;
wire Group_Sel4;
wire ADD2_XSel;
wire [N - 1: 0] Group_out1;
wire [N - 1: 0] Group_out2;
wire [N - 1: 0] Group_out3;
wire [N - 1: 0] Group_out4;



//倍点模块例化
wire P_Double_IN_VALID;
wire [N - 1: 0] P_Double_DIN_X;
wire [N - 1: 0] P_Double_DIN_Z;
wire [N - 1: 0] P_Double_DOUT_X;
wire [N - 1: 0] P_Double_DOUT_Z;
wire P_Double_OUT_VALID;


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
wire [1: 0] keysacn_op_code;

//PV模块
wire [N - 1: 0] PV_DIN_P1_X;
wire [N - 1: 0] PV_DIN_P2_Z;
wire PV_IN_VALID;
wire PV_mode;
wire PV_SUCCESS;
wire PV_OUT_VALID;

//PV模块输入选择器
wire [1:0] PV_X1Sel;
wire [1:0] PV_Z2Sel;

//状态机
wire [4: 0] fsm_out_state;

//状态机例化
PM_fault_fsm PM_fault_fsm1(
                 .CLK(CLK),
                 .RST_N(RST_N),
                 .IN_VALID(IN_VALID),
                 .ki(ki),
                 .key_first_found(key_first_found),
                 .key_cnt(key_cnt),
                 .P_x_is_0(P_x_is_0),
                 .Mxy_OUT_VALID(Mxy_OUT_VALID),
                 .P_ADD1_OUT_VALID(P_ADD1_OUT_VALID),
                 .P_ADD2_OUT_VALID(P_ADD2_OUT_VALID),
                 .P_Double_OUT_VALID(P_Double_OUT_VALID),
                 .axis_translate_out_valid(axis_trans_out_valid),
                 .PV_OUT_VALID(PV_OUT_VALID),
                 .PV_SUCCESS(PV_SUCCESS),
                 .keyscan_en(keyscan_en),
                 .keysacn_op_code(keysacn_op_code),
                 .key_check(key_check),
                 .key_load(key_load),
                 .find_key_first(find_key_first),
                 .key_state(key_state),
                 .Mxy_IN_VALID(Mxy_IN_VALID),
                 .P_ADD1_IN_VALID(P_ADD1_IN_VALID),
                 .P_ADD2_IN_VALID(P_ADD2_IN_VALID),
                 .P_Double_IN_VALID(P_Double_IN_VALID),
                 .PV_IN_VALID(PV_IN_VALID),
                 .PV_mode(PV_mode),
                 .axis_translate_in_valid(axis_trans_in_valid),
                 .X1Clear(X1Clear),
                 .X1Load(X1Load),
                 .Z1Clear(Z1Clear),
                 .Z1Load(Z1Load),
                 .X2Clear(X2Clear),
                 .X2Load(X2Load),
                 .Z2Clear(Z2Clear),
                 .Z2Load(Z2Load),
                 .XvClear(XvClear),
                 .XvLoad(XvLoad),
                 .ZvClear(ZvClear),
                 .ZvLoad(ZvLoad),
                 .XdClear(XdClear),
                  .XdLoad(XdLoad),
                  .ZdClear(ZdClear),
                  .ZdLoad(ZdLoad),
                 .Group_Sel1(Group_Sel1),
                  .Group_Sel2(Group_Sel2),
                  .Group_Sel3(Group_Sel3),
                  .Group_Sel4(Group_Sel4),
                 .ADD2_XSel(ADD2_XSel),
                 .PV_X1Sel(PV_X1Sel),
                 .PV_Z2Sel(PV_Z2Sel),
                 .X1Sel(X1Sel),
                 .Z1Sel(Z1Sel),
                 .X2Sel(X2Sel),
                 .Z2Sel(Z2Sel),
                 .XvSel(XvSel),
                 .ZvSel(ZvSel),
                 .OUT_STATE(fsm_out_state)
             );
//PV模块
PV_top PM_PV(
           .CLK(CLK),
           .RST_N(RST_N),
           .mode(PV_mode),
           .DIN_P1_X(PV_DIN_P1_X),
           .DIN_P1_Z(P_ADD2_DOUT_Z),
           .DIN_P2_X(Xd),
           .DIN_P2_Z(PV_DIN_P2_Z),
           .IN_VALID(PV_IN_VALID),
           .SUCCESS(PV_SUCCESS),
           .OUT_VALID(PV_OUT_VALID)
       );

//PV模块选择器
select3to1 PM_PV_P1_X_sel(
           .SEL(PV_X1Sel),
           .A(P_x),
           .B(P_ADD2_DOUT_X),
           .C(Mxy_DOUT_x),
           .OUT(PV_DIN_P1_X)
       );

select3to1 PM_PV_P2_Z_sel(
           .SEL(PV_Z2Sel),
           .A(P_y),
           .B(Zd),
           .C(Mxy_DOUT_y),
           .OUT(PV_DIN_P2_Z)
       );

//坐标转换模块例化
axis_translate_fault PM_fault_axis_translate(
                         .CLK(CLK),
                         .RST_N(RST_N),
                         .IN_VALID(axis_trans_in_valid),
                         .DIN_P_x(P_x),
                         .DIN_P_z(P_z),
                         .reg_X1_out(axis_trans_X1),
                         .OUT_VALID(axis_trans_out_valid)
                     );

//寄存器模块例化
register PM_fault_X1(
             .CLK(CLK),
             .CLEAR(X1Clear),
             .LOAD(X1Load),
             .OUT(X1),
             .IN(X1_sel_out) );

register PM_fault_Z1(
             .CLK(CLK),
             .CLEAR(Z1Clear),
             .LOAD(Z1Load),
             .OUT(Z1),
             .IN(Z1_sel_out) );

register PM_fault_X2(
             .CLK(CLK),
             .CLEAR(X2Clear),
             .LOAD(X2Load),
             .OUT(X2),
             .IN(X2_sel_out) );

register PM_fault_Z2(
             .CLK(CLK),
             .CLEAR(Z2Clear),
             .LOAD(Z2Load),
             .OUT(Z2),
             .IN(Z2_sel_out) );

register PM_fault_Xv(
             .CLK(CLK),
             .CLEAR(XvClear),
             .LOAD(XvLoad),
             .OUT(Xv),
             .IN(Xv_sel_out) );

register PM_fault_Zv(
             .CLK(CLK),
             .CLEAR(ZvClear),
             .LOAD(ZvLoad),
             .OUT(Zv),
             .IN(Zv_sel_out) );

register PM_fault_Xd(
             .CLK(CLK),
             .CLEAR(XdClear),
             .LOAD(XdLoad),
             .OUT(Xd),
             .IN(P_Double_DOUT_X) );

register PM_fault_Zd(
             .CLK(CLK),
             .CLEAR(ZdClear),
             .LOAD(ZdLoad),
             .OUT(Zd),
             .IN(P_Double_DOUT_Z) );

//寄存器输入选择器模块例化
select4to1 PM_fault_X1_sel(
               .SEL(X1Sel),
               .A(Xd),
               .B(pre_X1),
               .C(P_ADD1_DOUT_X),
               .D(axis_trans_X1),
               .OUT(X1_sel_out)
           );
select4to1 PM_fault_Z1_sel(
               .SEL(Z1Sel),
               .A(Zd),
               .B(pre_Z1),
               .C(P_ADD1_DOUT_Z),
               .D(P_z),
               .OUT(Z1_sel_out)
           );
select4to1 PM_fault_X2_sel(
               .SEL(X2Sel),
               .A(Xd),
               .B(pre_X2),
               .C(P_ADD1_DOUT_X),
               .D(P_Double_DOUT_X),
               .OUT(X2_sel_out)
           );
select4to1 PM_fault_Z2_sel(
               .SEL(Z2Sel),
               .A(Zd),
               .B(pre_Z2),
               .C(P_ADD1_DOUT_Z),
               .D(P_Double_DOUT_Z),
               .OUT(Z2_sel_out)
           );

select4to1 PM_fault_Xv_sel(
               .SEL(XvSel),
               .A(pre_Xv),
               .B(X1),
               .C(X2),
               .D(P_ADD2_DOUT_X),
               .OUT(Xv_sel_out)
           );
select4to1 PM_fault_Zv_sel(
               .SEL(ZvSel),
               .A(pre_Zv),
               .B(Z1),
               .C(Z2),
               .D(P_ADD2_DOUT_Z),
               .OUT(Zv_sel_out)
           );


//点加模块1例化
P_ADD_top PM_fault_ADD1(
                    .CLK(CLK),
                    .RST_N(RST_N),
                    .DIN_P1_X(Group_out1),
                    .DIN_P1_Z(Group_out2),
                    .DIN_P2_X(Group_out3),
                    .DIN_P2_Z(Group_out4),
                    .DIN_P_x(P_x),
                    .IN_VALID(P_ADD1_IN_VALID),
                    .OUT_VALID(P_ADD1_OUT_VALID),
                    .DOUT_A_X(P_ADD1_DOUT_X),
                    .DOUT_A_Z(P_ADD1_DOUT_Z)
                );

//点加模块2例化
//function: 负责计算Pv+P1 Pv+P2，一个输入固定为Pv，需要用到基点坐标
P_ADD_top PM_fault_ADD2(
              .CLK(CLK),
              .RST_N(RST_N),
              .DIN_P1_X(Xv),
              .DIN_P1_Z(Zv),
              .DIN_P2_X(Group_out3),
              .DIN_P2_Z(Group_out4),
              .DIN_P_x(P_ADD2_DIN_P_x),
              .IN_VALID(P_ADD2_IN_VALID),
              .OUT_VALID(P_ADD2_OUT_VALID),
              .DOUT_A_X(P_ADD2_DOUT_X),
              .DOUT_A_Z(P_ADD2_DOUT_Z)
          );

//倍点模块例化
P_Double_top PM_fault_P_Double(
                 .CLK(CLK),
                 .RST_N(RST_N),
                 .IN_VALID(P_Double_IN_VALID),
                 .DIN_X(Group_out3),
                 .DIN_Z(Group_out4),
                 .DOUT_X(P_Double_DOUT_X),
                 .DOUT_Z(P_Double_DOUT_Z),
                 .OUT_VALID(P_Double_OUT_VALID)
             );

//点加倍点运算输入选择器例化
select PM_fault_Group_IN_sel1(
           .SEL(Group_Sel1),
           .A(X1),
           .B(X2),
           .OUT(Group_out1)
       );
select PM_fault_Group_IN_sel2(
           .SEL(Group_Sel2),
           .A(Z1),
           .B(Z2),
           .OUT(Group_out2)
       );
select PM_fault_Group_IN_sel3(
           .SEL(Group_Sel3),
           .A(X1),
           .B(X2),
           .OUT(Group_out3)
       );
select PM_fault_Group_IN_sel4(
           .SEL(Group_Sel4),
           .A(Z1),
           .B(Z2),
           .OUT(Group_out4)
       );

//点加模块2输入选择器例化 
select PM_fault_ADD2_P_X_sel(
           .SEL(ADD2_XSel),
           .A(P_x),
           .B(PD_x),
           .OUT(P_ADD2_DIN_P_x)
       );




//坐标恢复模块例化
Mxy_top PM_fault_Mxy(
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
keyscan_fault PM_fault_keyscan(
                  .CLK(CLK),
                  .RST_N(RST_N),
                  .key_in(key),
                  .op_code(keysacn_op_code),
                  .key_load(key_load),
                  .key_check(key_check),
                  .keyscan_en(keyscan_en),
                  .keyfind_en(find_key_first),
                  .ki(ki),
                  .key_first_found(key_first_found),
                  .key_cnt(key_cnt),
                  .key_state(key_state)
              );



always @(posedge CLK) begin
    if (!RST_N) begin
        OUT_VALID <= 1'b0;
        P_x_is_0 <= 1'b0;
        P_x <= 0;
        P_y <= 0;
        P_z <= 0;
        DOUT_x <= 0;
        DOUT_y <= 0;
        INIT_Zv <= 1;
        pre_Z1 <= 0;
        pre_X2 <= 0;
        pre_Z2 <= 0;
        pre_Xv <= 0;
        pre_Zv <= 0;
    end
    else begin
        if (IN_VALID) begin
            OUT_VALID <= 1'b0;
            P_x <= DIN_P_x;
            PD_x <= DIN_2P_x;
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

        if (fsm_out_state == STROAGE) begin
            //点加倍点算完后先存储到临时寄存器
            pre_X1_tmp <= X1;
            pre_Z1_tmp <= Z1;
            pre_X2_tmp <= X2;
            pre_Z2_tmp <= Z2;
            pre_Xv_tmp <= Xv;
            pre_Zv_tmp <= Zv;
            $display($time, "STROAGE\n X1=%h\nZ1=%h\n X2=%h\nZ2=%h\n",X1, Z1, X2, Z2);
        end
        
        if (fsm_out_state == DATA_BACKUP) begin
            pre_X1 <= pre_X1_tmp;
            //$display(" pre_X1=%h\npre_Z1=%h\n", pre_X1_tmp,pre_Z1_tmp);
            pre_Z1 <= pre_Z1_tmp;
            pre_X2 <= pre_X2_tmp;
            pre_Z2 <= pre_Z2_tmp;
            pre_Xv <= pre_Xv_tmp;
            pre_Zv <= pre_Zv_tmp;

            //$display($time, "DATA_BACKUP fsm_out_state=%h\nXv=%h\nZv=%h\n",fsm_out_state, Xv, Zv);
        end

        //test
        // if (fsm_out_state==KEY_FIRST_SCAN) begin
        //   //$display($time, "KEY_FIRST_SCAN X1=%h\nZ1=%h\n X2=%h\nZ2=%h\n",X1, Z1, X2, Z2);
        // end
        // if (fsm_out_state==RECOVER_WAIT) begin
        //   $display($time, "RECOVER X1=%h\nZ1=%h\n", X1, Z1);
        // end
        // if (fsm_out_state==WAIT2) begin
        //   $display($time, "P_AD before\n X1=%h\nZ1=%h\n X2=%h\nZ2=%h\n",X1, Z1, X2, Z2);
        // end
    end
end
endmodule
