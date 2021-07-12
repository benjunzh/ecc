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
module PM_fault_fsm(
           CLK,
           RST_N,
           IN_VALID,
           ki,
           key_first_found,
           key_cnt,
           P_x_is_0,
           key_state,
           Mxy_OUT_VALID,
           P_ADD1_OUT_VALID,
            P_ADD2_OUT_VALID,
           P_Double_OUT_VALID,
           axis_translate_out_valid,
           PV_OUT_VALID,
           PV_SUCCESS,
           keyscan_en,
           keysacn_op_code,
           key_check,
           key_load,
           find_key_first,
           Mxy_IN_VALID,
           P_ADD1_IN_VALID,
            P_ADD2_IN_VALID,
           P_Double_IN_VALID,
           axis_translate_in_valid,
           PV_IN_VALID,
           PV_mode,
           X1Clear,
           X1Load,
           Z1Clear,
           Z1Load,
           X2Clear,
           X2Load,
           Z2Clear,
           Z2Load,
           XvClear,
           XvLoad,
           ZvClear,
           ZvLoad,
           XdClear,
            XdLoad,
            ZdClear,
            ZdLoad,
           Group_Sel1,
            Group_Sel2,
            Group_Sel3,
            Group_Sel4,
           ADD2_XSel,
           PV_X1Sel,
           PV_Z2Sel,
           X1Sel,
           Z1Sel,
           X2Sel,
           Z2Sel,
           XvSel,
           ZvSel,
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
input P_ADD1_OUT_VALID;
input P_ADD2_OUT_VALID;
input P_Double_OUT_VALID;
input PV_OUT_VALID;
input PV_SUCCESS;

output reg key_load;
output reg key_check;
output reg keyscan_en;
output reg [1: 0] keysacn_op_code;
output reg find_key_first;
output reg P_ADD1_IN_VALID;
output reg P_ADD2_IN_VALID;
output reg P_Double_IN_VALID;
output reg Mxy_IN_VALID;
output reg axis_translate_in_valid;
output reg PV_IN_VALID;
output reg PV_mode;

output reg X1Clear;
output reg X1Load;
output reg Z1Clear;
output reg Z1Load;
output reg X2Clear;
output reg X2Load;
output reg Z2Clear;
output reg Z2Load;
output reg XvClear;
output reg XvLoad;
output reg ZvClear;
output reg ZvLoad;
output reg XdClear;
output reg XdLoad;
output reg ZdClear;
output reg ZdLoad;

output reg [1: 0] X1Sel;
output reg [1: 0] Z1Sel;
output reg [1: 0] X2Sel;
output reg [1: 0] Z2Sel;
output reg [1: 0] XvSel;
output reg [1: 0] ZvSel;

output reg Group_Sel1;
output reg Group_Sel2;
output reg Group_Sel3;
output reg Group_Sel4;
output reg ADD2_XSel;
output reg [1:0] PV_X1Sel;
output reg [1:0] PV_Z2Sel;
output reg [4: 0] OUT_STATE;

reg [1: 0] delay_cnt;
reg first_loop; //第一次循环
reg first_check; //第一次检查
reg [4: 0] state;
reg P_ADD1_OUT_VALID_TMP;
reg P_ADD2_OUT_VALID_TMP;
reg P_Double_OUT_VALID_TMP;
reg PV_OUT_VALID_TMP;
reg axis_trans_out_valid_tmp;
reg P_checked;
reg [3:0] co_check_cnt;
reg pre_ki;//上一轮ki的值
reg wait_cocheck; //是否等待一致性检查

reg inject_error;

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
    CONSISTENCY_CHECK = 5'b01011,
    DATA_BACKUP = 5'b01001,
    RECOVER = 5'b01000,
    RECOVER_WAIT = 5'b11000,
    SCAN_STATE_CHECK = 5'b11001,
    P_XY = 5'b11011,
    P_XY_OUTPUT = 5'b11010,
    POINT_VERTIFY = 5'b11110,
    OUTPUT = 5'b11111,
    P_AD_1=5'b11101,
    P_AD_2=5'b11100;

parameter
    KEY_IS_ZERO = 2'b01,
    KEY_IS_ONE = 2'b11,
    GAP = 1;

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

        XvClear <= 1;
        XvLoad <= 0;

        ZvClear <= 1;
        ZvLoad <= 0;

        XdClear <= 1;
        XdLoad <= 0;

        ZdClear <= 1;
        ZdLoad <= 0;

        X1Sel <= 0;
        Z1Sel <= 0;
        X2Sel <= 0;
        Z2Sel <= 0;
        XvSel <= 0;
        ZvSel <= 0;
        
        ADD2_XSel <= 0;

        PV_X1Sel <= 0;
        PV_Z2Sel <= 0;

        key_load <= 0;
        key_check <= 0;
        keyscan_en <= 0;
        keysacn_op_code <= 0;
        find_key_first <= 0;
        P_ADD1_IN_VALID <= 0;
        P_ADD2_IN_VALID <= 0;
        P_Double_IN_VALID <= 0;
        Mxy_IN_VALID <= 0;
        axis_translate_in_valid <= 0;
        PV_IN_VALID <= 0;
        PV_mode <= 0;

        P_ADD1_OUT_VALID_TMP <= 0;
        P_ADD2_OUT_VALID_TMP <= 0;
        P_Double_OUT_VALID_TMP <= 0;
        PV_OUT_VALID_TMP <= 0;
        axis_trans_out_valid_tmp <= 0;

        OUT_STATE <= 0;
        state <= 0;
        co_check_cnt<=0;
        delay_cnt <= 0;
        first_loop <= 0;
        first_check <= 0;
        P_checked <= 0;
        pre_ki <= 0;
        wait_cocheck <= 0;

        inject_error<=1;
    end
    else begin
        OUT_STATE <= state;

        if (P_ADD1_OUT_VALID == 1) begin
            P_ADD1_OUT_VALID_TMP <= 1;
        end
        if (P_ADD2_OUT_VALID == 1) begin
            P_ADD2_OUT_VALID_TMP <= 1;
        end
        if (P_Double_OUT_VALID == 1) begin
            P_Double_OUT_VALID_TMP <= 1;
        end
        if (PV_OUT_VALID == 1) begin
            PV_OUT_VALID_TMP <= 1;
        end

        case (state)
            IDLE: begin
                X1Clear <= 0;
                Z1Clear <= 0;
                X2Clear <= 0;
                Z2Clear <= 0;
                XvClear <= 0;
                ZvClear <= 0;
                XdClear <= 0;
                ZdClear <= 0;

                X1Load <= 0;
                Z1Load <= 0;
                X2Load <= 0;
                Z2Load <= 0;
                XvLoad <= 0;
                ZvLoad <= 0;
                XdLoad <= 0;
                ZdLoad <= 0;

                delay_cnt <= 0;
                co_check_cnt<=0;
                first_loop <= 0;
                first_check <= 0;
                key_load <= 0;
                key_check <= 0;
                keyscan_en <= 0;
                keysacn_op_code <= 0;
                find_key_first <= 0;
                P_ADD1_IN_VALID <= 0;
                Mxy_IN_VALID <= 0;
                axis_translate_in_valid <= 0;

                P_ADD1_OUT_VALID_TMP <= 0;
                P_ADD2_OUT_VALID_TMP <= 0;
                PV_OUT_VALID_TMP <= 0;
                axis_trans_out_valid_tmp <= 0;
                P_checked <= 0;
                pre_ki <= 0;
                wait_cocheck <= 0;

                if (IN_VALID) begin
                    state <= INIT;
                end
                else begin
                    state <= IDLE;
                end
            end
            INIT: begin
                key_load <= 1; //装载密钥
                first_loop <= 1;
                first_check <= 1;
                if (!IN_VALID) begin
                    key_load <= 0;
                    key_check <= 1; //密钥装载完毕，通知密钥扫描模块进行密钥检查，判断是否为1或0
                    state <= PRE_JUDGE;
                end
            end
            PRE_JUDGE: begin
                PV_mode <= 1;
                PV_IN_VALID <= 1;
                PV_X1Sel <= 2'b10;
                PV_Z2Sel <= 2'b10;

                //$display($time, "PRE_JUDGE key_state=%h\n", key_state);
                key_check <= 0; 

                //等待密钥判断结果信号稳定，延迟两个clock
                //clock1 密钥扫描模块根据key_check跳转状态
                //clock2 密钥状态key_state存储
                //clock3 判断密钥状态key_state
                if (delay_cnt < 2) begin
                    delay_cnt <= delay_cnt + 1;
                end
                else begin
                    delay_cnt <= 0;

                    if (key_state == KEY_IS_ZERO || key_state == KEY_IS_ONE || P_x_is_0 == 1'b1) begin
                        state <= OUTPUT;
                    end
                    else begin
                        PV_IN_VALID <= 0; //开始基点验证
                        axis_translate_in_valid <= 1; //开启坐标转换
                        find_key_first <= 1; //同时执行密钥一个非零比特查找
                        state <= AXIS_TRANS;
                    end
                end
            end
            AXIS_TRANS: begin
                //$display($time, "PRE_COMPUTE\n");
                //$display($time, "cnt=%h\n",key_cnt);
                axis_translate_in_valid <= 0;
                find_key_first <= 0;
                keysacn_op_code <= 2'b00;

                if (axis_translate_out_valid == 1) begin
                    X1Load <= 1;
                    Z1Load <= 1;

                    X1Sel <= 0;
                    Z1Sel <= 0;
                    
                    state <= PRE_COMPUTE;
                end
            end
            PRE_COMPUTE: begin
                X1Load <= 0;
                Z1Load <= 0;
                state <= WAIT_PRE_COMPUTE;
                P_Double_IN_VALID <= 1;
                Group_Sel3 <= 1;
                Group_Sel4 <= 1;
            end
            WAIT_PRE_COMPUTE: begin
                P_Double_IN_VALID <= 0;
                if (P_Double_OUT_VALID == 1) begin
                    P_Double_OUT_VALID_TMP <= 1;
                    X2Load <= 1;
                    Z2Load <= 1;
                    X2Sel <= 0;
                    Z2Sel <= 0;
                    
                end

                if (PV_OUT_VALID == 1) begin
                    PV_OUT_VALID_TMP <= 1;
                    if (PV_SUCCESS == 1) begin
                        P_checked <= 1; //基点置为已验证
                    end
                    else begin
                        state <= IDLE;
                        $display("base point is wrong\n");
                    end
                end

                if ((P_Double_OUT_VALID_TMP == 1) && (PV_OUT_VALID_TMP == 1 || P_checked==1)) begin
                    PV_OUT_VALID_TMP <= 0;
                    P_Double_OUT_VALID_TMP <= 0;
                    state<=KEY_FIRST_SCAN;
                end
            end

            KEY_FIRST_SCAN: begin
                //如果KEY_FIRST_SCAN尚未在PRE_COMPUTE状态下完成，在KEY_FIRST_SCAN状态继续继续寻找
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
                $display($time, " start key scan\n");
                keyscan_en <= 1;
                co_check_cnt <= co_check_cnt + 1;
                state <= WAIT1;
            end
            WAIT1: begin
                //$display($time, " P_AD state: WAIT1\n");
                keyscan_en <= 0;

                //等待密钥扫描结果信号稳定，延迟四个clock
                //clock1 keyscan_en赋值
                //clock2 密钥扫描模块根据keyscan_en跳转状态
                //clock3 密钥比特ki存储
                //clock4 判断密钥比特ki
                //clock1即KEY_SCAN状态 clock4即KEY_JUDGE状态 因此WAIT1状态需要等待两个周期

                if (delay_cnt < 1) begin
                    delay_cnt <= delay_cnt + 1;
                end
                else begin
                    delay_cnt <= 0;
                    state <= KEY_JUDGE;
                end
            end
            KEY_JUDGE: begin
                $display(" key_cnt = %d, ki=%d\n",key_cnt, ki);
                //$display("KEY_JUDGE ki=%h\n", ki);
                P_ADD1_IN_VALID <= 1; //判断密钥比特，开始进行点加倍点运算
                P_ADD2_IN_VALID <= 1;
                P_Double_IN_VALID <= 1;

                //计算前对输出有效进行复位，因为中断可能造成信号未正常复位情况
                P_ADD2_OUT_VALID_TMP <= 0;
                    P_ADD1_OUT_VALID_TMP <= 0;
                    P_Double_OUT_VALID_TMP <= 0;
                if (ki == 1) begin
                    //P1=P1+P2 P2=2*P2
                    Group_Sel1 <= 1;
                    Group_Sel2 <= 1;
                    Group_Sel3 <= 0;
                    Group_Sel4 <= 0;
                    ADD2_XSel <= 0;

                    //拿到第一轮扫描密钥值，直接对Pv初始化
                    if (first_loop == 1) begin
                        //Pv=P2;
                        XvSel <= 2'b01;
                        ZvSel <= 2'b01;
                        XvLoad <= 1;
                        ZvLoad <= 1;
                    end
                end
                else begin
                    Group_Sel1 <= 0;
                    Group_Sel2 <= 0;
                    Group_Sel3 <= 1;
                    Group_Sel4 <= 1;
                    ADD2_XSel <= 1;

                    if (first_loop == 1) begin
                        //Pv=P1;
                        XvSel <= 2'b10;
                        ZvSel <= 2'b10;
                        XvLoad <= 1;
                        ZvLoad <= 1;
                    end
                end
                state <= WAIT2;
            end
            WAIT2: begin
                P_ADD1_IN_VALID <= 0;
                P_ADD2_IN_VALID <= 0;
                P_Double_IN_VALID <= 0;
                XvLoad <= 0;
                ZvLoad <= 0;
                state <= P_AD;
            end
            
            P_AD: begin
                keysacn_op_code <= 0;
                //等待倍点运算完成，将结果暂存到Pd中，等2*P1运算开始，再转存到P1、P2中。
                if (P_Double_OUT_VALID_TMP==1) begin
                    P_Double_OUT_VALID_TMP<=0;

                    //结果暂存到Xd 和 Zd
                    XdLoad<=1;
                    ZdLoad<=1;

                    //计算一致性检查中的2*P1
                    if (co_check_cnt == GAP) begin
                        P_Double_IN_VALID<=1;
                        Group_Sel3 <= 1;
                        Group_Sel4 <= 1;
                    end

                    state<=P_AD_1;
                end
            end
            P_AD_1: begin
                XdLoad<=0;
                ZdLoad<=0;
                P_Double_IN_VALID<=0;
                
                //数据转存到P1、P2
                if (ki == 1) begin
                    $display(" P_Double 1 finish : ki == 1\n");
                    //save to P2
                    X2Sel <= 2'b11;
                    Z2Sel <= 2'b11;
                    X2Load <= 1;
                    Z2Load <= 1;
                end
                else begin
                    $display(" P_Double 1 finish : ki == 0\n");
                    //save to P1
                    X1Sel <= 2'b11;
                    Z1Sel <= 2'b11;
                    X1Load <= 1;
                    Z1Load <= 1;
                end
                state<=CONSISTENCY_CHECK;
            end
            CONSISTENCY_CHECK: begin
                if (wait_cocheck==0) begin
                    state<=P_AD_2;
                end
                else if (PV_OUT_VALID == 1) begin
                    PV_OUT_VALID_TMP <= 0;
                    $display("CONSISTENCY_CHECK PV_SUCCESS=%h\n",PV_SUCCESS);
                    wait_cocheck<=0;
                    //开启验证时密钥值是否为1
                    if (pre_ki == 1) begin
                        //检查有效且不通过，进行数据恢复
                        if (PV_SUCCESS == 0) begin
                            //如果第一次检查，没有备份数据，直接跳转到最开始的运算状态
                            //并通知密钥扫描模块进行密钥和轮迭代状态恢复
                            if (first_check == 1) begin
                                state <= AXIS_TRANS;
                                keysacn_op_code <= 2'b11;
                            end
                            else begin
                                state <= RECOVER;
                            end
                        end
                        else begin
                            //检查有效且通过
                            state<=DATA_BACKUP;
                        end
                    end
                    else begin
                        $display("ignore the check result\n");
                        state<=P_AD_2;
                    end
                end
            end
            DATA_BACKUP: begin
                //数据备份完毕后继续完成点加倍点运算
                $display($time, " DATA_BACKUP\n");
                keysacn_op_code <= 2'b10;
                first_check <= 0;
                state <= P_AD_2;
            end
            P_AD_2: begin
                X1Load <= 0;
                Z1Load <= 0;
                X2Load <= 0;
                Z2Load <= 0;

                //点加模块1运算完成
                if (P_ADD1_OUT_VALID_TMP == 1) begin
                    if (ki == 1) begin
                        $display(" P_ADD1 finish : ki == 1\n");
                        //P1 = P1 + P2
                        X1Sel <= 2'b01;
                        Z1Sel <= 2'b01;
                        X1Load <= 1;
                        Z1Load <= 1;
                        
                        
                    end
                    else begin
                        $display(" P_ADD1 finish : ki == 0\n");
                        //P2 = P1 + P2
                        X2Sel <= 2'b01;
                        Z2Sel <= 2'b01;
                        X2Load <= 1;
                        Z2Load <= 1;
                    end
                end
                //点加模块2运算完成
                if (P_ADD2_OUT_VALID_TMP == 1) begin
                    //仅限非第一轮时运算，对Pv进行存储，第一轮运算不是在这里存储的
                    if (first_loop == 0) begin
                        XvLoad <= 1;
                        ZvLoad <= 1;
                        XvSel <= 0;
                        ZvSel <= 0;
                    end
                end
                //倍点运算完成
                if (P_Double_OUT_VALID_TMP==1) begin
                    XdLoad<=1;
                    ZdLoad<=1;
                end

                if (P_ADD2_OUT_VALID_TMP == 1 && P_ADD1_OUT_VALID_TMP == 1 && (P_Double_OUT_VALID_TMP==1 || co_check_cnt != GAP)) begin
                    state <= STROAGE;
                    P_ADD2_OUT_VALID_TMP <= 0;
                    P_ADD1_OUT_VALID_TMP <= 0;
                    P_Double_OUT_VALID_TMP <= 0;

                    //故障测试
                        // if (key_cnt==20 && inject_error==1) begin
                        //     inject_error<=0;
                        //     $display("inject error.\n");
                        //     X1Sel <= 2'b00;
                        // end
                end
            end

            STROAGE: begin
                $display($time, " STROAGE\n");
                XvLoad <= 0;
                ZvLoad <= 0;
                X1Load <= 0;
                Z1Load <= 0;
                X2Load <= 0;
                Z2Load <= 0;
                XdLoad<=0;
                ZdLoad<=0;

                first_loop <= 0; //到了这个状态表示第一轮迭代已经完成
                pre_ki <= ki;
                $display("co_check_cnt=%h\n",co_check_cnt);
                if (co_check_cnt == GAP) begin
                    co_check_cnt <= 0;
                    keysacn_op_code <= 2'b01;
                    $display($time, "CONSISTENCY_CHECK START\n");
                    PV_IN_VALID <= 1; //开启一致性检查
                    wait_cocheck <= 1;//要求等待一致性检查运算完成
                    PV_mode <= 0;
                    PV_X1Sel <= 2'b01;
                    PV_Z2Sel <= 2'b01;
                end
                state <= SCAN_STATE_CHECK; //判断扫描是否完成
            end
            SCAN_STATE_CHECK: begin
                //$display($time, " SCAN_STATE_CHECK\n");
                keysacn_op_code <= 0;
                PV_IN_VALID <= 0;
                if (key_cnt == 233) begin
                    state <= P_XY;
                end
                else begin
                    state <= KEY_SCAN;
                end
            end
            
            RECOVER: begin
                $display("RECOVER\n");
                keysacn_op_code <= 2'b11;
                X1Load <= 1;
                Z1Load <= 1;
                X2Load <= 1;
                Z2Load <= 1;
                XvLoad <= 1;
                ZvLoad <= 1;

                XvSel <= 2'b11;
                ZvSel <= 2'b11;
                X1Sel <= 2'b10;
                Z1Sel <= 2'b10;
                X2Sel <= 2'b10;
                Z2Sel <= 2'b10;
                state <= RECOVER_WAIT;
            end
            RECOVER_WAIT: begin
                keysacn_op_code <= 0;
                X1Load <= 0;
                Z1Load <= 0;
                X2Load <= 0;
                Z2Load <= 0;
                XvLoad <= 0;
                ZvLoad <= 0;
                state <= KEY_SCAN;
            end
            
            P_XY: begin
                //$display("state: P_XY\n");
                Mxy_IN_VALID <= 1;
                state <= P_XY_OUTPUT;
            end
            P_XY_OUTPUT: begin
                Mxy_IN_VALID <= 0;
                if (Mxy_OUT_VALID == 1) begin
                    state <= POINT_VERTIFY;
                    PV_mode <= 1;
                    PV_IN_VALID <= 1;
                    PV_X1Sel <= 0;
                    PV_Z2Sel <= 0;
                end
            end
            POINT_VERTIFY: begin
                PV_IN_VALID <= 0;
                if (PV_OUT_VALID == 1) begin
                    PV_OUT_VALID_TMP <= 0;
                    if (PV_SUCCESS == 1) begin
                        state <= OUTPUT;
                    end
                    else begin
                        state <= RECOVER;
                    end
                end
            end
            OUTPUT: begin
                $display("OUTPUT\n");
                state <= IDLE;
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end
end
endmodule
