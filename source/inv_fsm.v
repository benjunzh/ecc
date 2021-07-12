`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    2020-01-03
// Design Name:
// Module Name:    INV_FSM
// Project Name:
// Target Devices:
// Tool versions:
// Description:
// state最高为1表示等待，下一个周期将首位置零。
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

//@TClear 高电平有效

module inv_fsm(
           CLK,
           RST_N,
           ERROR,
           MUL_OUT_VALID,
           IN_VALID,
           TLoad,
           TClear,
           XLoad,
           XClear,
           XSel,
           ESel,
           TSel,
           MUL_IN_VALID,
           OUT_STATE
       );

parameter
    IDLE = 6'b000000,
    INIT = 6'b111011,
    START = 6'b000001;

input CLK;
input RST_N;
input ERROR;                              //乘法器检测到错误
input MUL_OUT_VALID;                      //乘法器输出有效
input IN_VALID;
output reg TLoad;
output reg TClear;
output reg XLoad;
output reg XClear;
output reg XSel;                       //选择器s1的选择信号
output reg ESel;                       //选择器s2的选择信号
output reg [1: 0] TSel;
output reg MUL_IN_VALID;                        //乘法器输入有效
output reg [5 : 0] OUT_STATE;

reg [5 : 0] state;
reg [1 : 0] state6_reg;
reg [2 : 0] state11_reg;
reg [3 : 0] state14_reg;
reg [4 : 0] state19_reg;
reg [5 : 0] state22_reg;
reg [6 : 0] state25_reg;

reg [1: 0] cnt_square;
always @(posedge CLK) begin
    if (!RST_N) begin
        state <= {6{1'b0}};
        state6_reg <= {2{1'b0}};
        state11_reg <= {3{1'b0}};
        state14_reg <= {4{1'b0}};
        state19_reg <= {5{1'b0}};
        state22_reg <= {6{1'b0}};
        state25_reg <= {7{1'b0}};
        OUT_STATE <= {5{1'b0}};
        MUL_IN_VALID <= 1'b0;
        cnt_square <= 0;
    end
    else begin
        OUT_STATE <= state;


        //注意下面出现了=，若模块中无时钟信号，用"="。同步时钟电路用"<="
        //Xsel=1，选择乘法器输出； 	Xsel=0，选择输入数据
        //Esel=1，选择S1输出； 		Esel=0，选择平方器输出
        //乘法结果存储在X内，平方结果存储在T内
        //若计算乘法器结果X的平方T(T=X^2)，Xsel=1, Esel=1.
        //若计算输入数据A的平方T(T=A^2)，Xsel=0, Esel=1.
        //若计算输入数据A与平方结果T的乘积X(X=AT)，Xsel=0.
        ////若计算乘法器结果X与平方结果T的乘积X(X=XT)，Xsel=1.
        //若计算平方结果T的平方T(T=T^2)，ESel <= 0;

        //$display($time, " state=%d MUL_IN_VALID=%d\n", state, MUL_IN_VALID);
        case (state)
            IDLE : begin  //initial state
                TLoad <= 0;
                TClear <= 1;
                XLoad <= 0;
                XClear <= 1;
                XSel <= 0;
                ESel <= 0;
                TSel <= 0;
                MUL_IN_VALID <= 1'b0;
                cnt_square <= 0;
                if (IN_VALID) begin
                    state <= INIT;
                end
                else begin
                    state <= IDLE;
                end
            end
            INIT: begin
                if (!IN_VALID) begin
                    state <= START;
                end
            end
            START : begin //first state   1:T=A^2
                //该周期下，数据通过寄存器x，开始平方运算
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 0;
                ESel <= 1; //输入数据A由S2进入模平方器，结果送入乘法器，与A相乘
                TSel <= 2'b00;
                MUL_IN_VALID <= 1'b1; //乘法器读取数据
                state <= 6'b000010;
                cnt_square <= 0;
            end
            6'b000010 : begin // 2:X=AT

                //该周期下，数据通过寄存器t，开始乘法运算
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 0;
                ESel <= 1;
                if (MUL_OUT_VALID == 1'b1)  //乘法运算结束
                begin
                    state <= 6'b000011;
                end
                else begin
                    if (cnt_square == 2'b10) begin
                        MUL_IN_VALID <= 1'b0; //开始乘法运算
                        cnt_square <= 0;
                    end
                    else begin
                        cnt_square <= cnt_square + 1'b1;
                    end
                end
            end
            6'b000011 : begin   //3:T=X^2
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1; //乘法执行完成后，寄存器x存储乘法结果X，令Xsel=1
                ESel <= 1; //选择X输入平方器
                TSel <= 2'b00;
                MUL_IN_VALID <= 1'b1; //multi input valid !
                state <= 6'b000100;
                cnt_square <= 0;
            end
            6'b000100 : begin // 4:X=AT
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 0;
                ESel <= 1;
                if (MUL_OUT_VALID == 1'b1)  //multi operation finish !
                begin
                    state <= 6'b000101;
                end
                else begin
                    state <= 6'b000100;
                    //进入状态4的时候，控制信号稳定，开始平方运算，cnt+1=1;
                    //下一个时钟周期寄存器t取数据，cnt+1=2;
                    //再下一个时钟周设置IN_VALID=0，此时cnt=2.
                    //此时乘法器读到的数据为最终输入，开始运算。
                    if (cnt_square == 2'b10) begin
                        MUL_IN_VALID <= 1'b0; //开始乘法运算
                        cnt_square <= 0;
                    end
                    else begin
                        cnt_square <= cnt_square + 1'b1;
                    end
                end
            end
            6'b000101 : begin   // 5:T=X^2
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 1;
                TSel <= 2'b00;
                state <= 6'b000110;
                cnt_square <= 0;
            end
            6'b000110 : begin
                state <= 6'b000111;
                //上一个周期Xsel信号发生改变，需要一个周期给寄存器存储。
                //这样到达循环状态的时候，寄存器的值已经是更新后的T。
                //如果Xsel信号没有改变，那么不需要缓冲周期，
                //因为乘法运算完成后，在乘法状态判断MUL_OUT_VALID是否有效的时候，平方器就已经提前一个周期对正确数据进行运算了。
                //等到平方状态，寄存器直接存储正确的数值。
            end
            6'b000111 : begin   // 6:T=T^2    3-1=2 times
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 0;          //由于乘法器结果X平方后存入寄存器T中，故剩余的平方计算由T完成，选择信号为Esel=0.
                TSel <= 2'b01;
                MUL_IN_VALID <= 1'b1;
                state6_reg <= 0;
                state <= 6'b001000;
            end
            6'b001000 : begin
                state <= 6'b001001; //寄存器存储，缓冲一个时钟周期
            end
            6'b001001 : begin  // 7:X=XT
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 0;
                if (MUL_OUT_VALID == 1'b1)  //multi operation finish !
                begin
                    MUL_IN_VALID <= 1'b1;
                    state <= 6'b001010;
                end
                else begin
                    state <= 6'b001001;
                    //上个状态是连续平方，数据实时准备好，此处可以直接开始乘法。
                    MUL_IN_VALID <= 1'b0; //开始乘法运算
                end
            end
            6'b001010 : begin //8:T=X^2
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 1;
                TSel <= 2'b00;
                MUL_IN_VALID <= 1'b1;
                state <= 6'b001011;
                cnt_square <= 0;
            end
            6'b001011 : begin // 9:X=AT
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 0;
                ESel <= 1;
                if (MUL_OUT_VALID == 1'b1) begin
                    state <= 6'b001100;
                end
                else begin
                    state <= 6'b001011;
                    //XSel变了
                    if (cnt_square == 2'b10) begin
                        MUL_IN_VALID <= 1'b0; //开始乘法运算
                        cnt_square <= 0;
                    end
                    else begin
                        cnt_square <= cnt_square + 1'b1;
                    end
                end
            end
            6'b001100 : begin // 10:T=X^2
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 1;
                state <= 6'b001101;
                cnt_square <= 0;
            end
            6'b001101: begin
                state <= 6'b001110;
            end
            6'b001110 : begin // 11:T=T^2   6 times
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 0;
                TSel <= 2'b10;
                if (state11_reg < 2) begin
                    state11_reg <= state11_reg + 3'b001;
                    state <= 6'b001110;
                end
                else begin
                    MUL_IN_VALID <= 1'b1;
                    state11_reg <= 0;
                    state <= 6'b001111;
                end
            end
            6'b001111 : begin // 12:X=XT
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 1;
                if (MUL_OUT_VALID == 1'b1)  //multi operation finish !
                begin
                    state <= 6'b010000;
                end
                else begin
                    state <= 6'b001111;
                    MUL_IN_VALID <= 1'b0; //开始乘法运算
                end
            end
            6'b010000 : begin // 13:T=X^2
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 1;
                TSel <= 2'b00;
                state <= 6'b010010;
                cnt_square <= 0;
            end

            6'b010010 : begin // 14:T <= T^2  13 times
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 0;
                TSel <= 2'b11;
                //在最后一轮，也即第二个分支改变选择信号，该信号生效作用于下一轮，
                //也即下一个状态
                if (state14_reg == 3) begin
                    TSel <= 2'b00;
                end

                if (state14_reg < 3) begin
                    state14_reg <= state14_reg + 1'b1;
                    state <= 6'b010010;
                end
                else begin
                    //$display("leave\n");
                    state14_reg <= 0;
                    state <= 6'b010100;
                    MUL_IN_VALID <= 1'b1;
                end
            end

            6'b010100: begin
                state <= 6'b010101;
            end
            6'b010101: begin // 15:X=XT
                //$display("15\n");
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 1;
                if (MUL_OUT_VALID == 1'b1)  //multi operation finish !
                begin
                    state <= 6'b010110;
                end
                else begin
                    state <= 6'b010101;
                    MUL_IN_VALID <= 1'b0; //开始乘法运算
                end
            end
            6'b010110 : begin // 16: T=X^2
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 1;
                MUL_IN_VALID <= 1'b1;
                state <= 6'b010111;
                cnt_square <= 0;
            end
            6'b010111 : begin // 17: X=AT
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 0;
                ESel <= 1;
                if (MUL_OUT_VALID == 1'b1) begin
                    state <= 6'b011000;
                end
                else begin
                    state <= 6'b010111;
                    //XSel变了
                    if (cnt_square == 2'b10) begin
                        MUL_IN_VALID <= 1'b0; //开始乘法运算
                        cnt_square <= 0;
                    end
                    else begin
                        cnt_square <= cnt_square + 1'b1;
                    end
                end
            end
            6'b011000 : begin // 18: T=X^2
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 1;
                state <= 6'b011001;
                cnt_square <= 0;
            end
            6'b011001: begin
                state <= 6'b011010;
            end
            6'b011010 : begin // 19: T=T^2  28 times
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 0;
                TSel <= 2'b11;
                if (state19_reg < 7) begin
                    state19_reg <= state19_reg + 6'b000001;
                    state <= 6'b011010;
                end
                else begin
                    state19_reg <= 0;
                    state <= 6'b011011;
                    MUL_IN_VALID <= 1'b1;
                end
            end
            6'b011011 : begin // 20: X=XT
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 1;
                if (MUL_OUT_VALID == 1'b1)  //multi operation finish !
                begin
                    state <= 6'b011100;
                end
                else begin
                    state <= 6'b011011;
                    MUL_IN_VALID <= 1'b0; //开始乘法运算
                end
            end
            6'b011100 : begin // 21: T=X^2
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 1;
                TSel <= 2'b00;
                state <= 6'b011110;
                cnt_square <= 0;
            end
            6'b011110 : begin // 22: T=T^2 57 times
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 0;
                TSel <= 2'b11;
                if (state22_reg == 14) begin
                    TSel <= 2'b00;
                end
                if (state22_reg < 14) begin
                    state22_reg <= state22_reg + 6'b000001;
                    state <= 6'b011110;
                end
                else begin
                    state22_reg <= 0;
                    state <= 6'b100000;
                    MUL_IN_VALID <= 1'b1;
                end
            end
            6'b100000: begin
                state <= 6'b100001;
            end
            6'b100001 : begin //23: X=XT
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 1;
                if (MUL_OUT_VALID == 1'b1)  //multi operation finish !
                begin
                    state <= 6'b100010;
                end
                else begin
                    state <= 6'b100001;
                    MUL_IN_VALID <= 1'b0; //开始乘法运算
                end
            end
            6'b100010 : begin //24: T=X^2
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 1;
                state <= 6'b100100;
                cnt_square <= 0;
            end
            6'b100100 : begin //25: T=T^2 115 times
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 0;
                TSel <= 2'b11;
                if (state25_reg == 28) begin
                    TSel <= 2'b10;
                end
                if (state25_reg < 28) begin
                    state25_reg <= state25_reg + 7'b0000001;
                    state <= 6'b100100;
                end
                else begin
                    state25_reg <= 0;
                    state <= 6'b100110;
                    MUL_IN_VALID <= 1'b1;
                end
            end
            6'b100110: begin
                state <= 6'b100111;
            end
            6'b100111 : begin //26: X=XT
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 1;
                if (MUL_OUT_VALID == 1'b1)  //multi operation finish !
                begin
                    state <= 6'b101000;
                end
                else begin
                    state <= 6'b100111;
                    MUL_IN_VALID <= 1'b0; //开始乘法运算
                end
            end
            6'b101000 : begin // 27: INVA <= X^2
                TLoad <= 1;
                TClear <= 0;
                XLoad <= 1;
                XClear <= 0;
                XSel <= 1;
                ESel <= 1;
                TSel <= 2'b00;
                state <= 6'b101001;
                cnt_square <= 0;
            end
            6'b101001: begin
                TLoad <= 0;
                state <= IDLE;
            end
            default : begin
                state <= IDLE;
            end
        endcase
    end
end

endmodule
