`timescale 1ns / 1ps

module mul_fault(
           CLK,
           RST_N,
           IN_VALID,
           A,
           B,
           DOUT,
           OUT_VALID,
           ERROR
       );

// integer out_file; //定义文件句柄
// initial begin
//     out_file = $fopen("log.txt", "w");
// end

//-------------------------------------------------------------------
// parameter list
//-------------------------------------------------------------------

parameter w = 4;    //字长
parameter n = 233;  //field width
parameter delay_cyc = 8'd59;
parameter
    IDLE = 2'b00,
    INIT = 2'b01,
    START = 2'b10;
//-------------------------------------------------------------------
// port list
//-------------------------------------------------------------------
//input
input CLK;
input RST_N;
input IN_VALID;

input [n - 1: 0] A; //乘数A
input [n - 1: 0] B; //乘数B

//output
output reg [n - 1: 0] DOUT; //不参与运算，存储最终运算结果
output reg OUT_VALID;
output ERROR;

//-------------------------------------------------------------------
// inner variable
//-------------------------------------------------------------------
reg [1: 0] state;
reg [n - 1: 0] A_in;    //乘数A
reg [n - 1: 0] B_in;    //乘数B
reg [n - 1: 0] A_initial;    //乘数A备份
reg [n - 1: 0] B_initial;    //乘数B备份
reg [n - 1: 0] C;
reg [7: 0] cnt;             //计数器
//reg [14: 0] test_cnt;       //故障测试计数器
reg a_parity;
reg predict_parity;

//ASWi=A*x^i
reg [n - 1: 0] ASW1;
reg [n - 1: 0] ASW2;
reg [n - 1: 0] ASW3;
reg [n - 1: 0] ASW4;

//bitmuli=A*B[jw+i];
wire [n - 1: 0] bitmul0;
wire [n - 1: 0] bitmul1;
wire [n - 1: 0] bitmul2;
wire [n - 1: 0] bitmul3;

wire ASW1_parity;
wire ASW2_parity;
wire ASW3_parity;
wire ASW4_parity;
wire [n - 1: 0] c_next;
wire predict_parity_next;
wire c_ptree;
wire EC;
//-------------------------------------------------------------------
// function description
//-------------------------------------------------------------------
task SHLW;
    input [n - 1: 0] in;
    output [n - 1: 0] out;
    reg [n - 1: 0] out;
    begin
        out = in << 1;
        out[0] = in[n - 1];
        out[74] = in[73] ^ in[n - 1];
    end
endtask

//A*B[i]
assign bitmul0 = {n{B_in[0]}} & A_in;
assign bitmul1 = {n{B_in[1]}} & ASW1;
assign bitmul2 = {n{B_in[2]}} & ASW2;
assign bitmul3 = {n{B_in[3]}} & ASW3;

//部分积
assign c_next = C ^ bitmul0 ^ bitmul1 ^ bitmul2 ^ bitmul3;

//奇偶校验
assign ASW1_parity = a_parity ^ A_in[n - 1];
assign ASW2_parity = ASW1_parity ^ ASW1[n - 1];
assign ASW3_parity = ASW2_parity ^ ASW2[n - 1];
assign ASW4_parity = ASW3_parity ^ ASW3[n - 1];

assign predict_parity_next = predict_parity
       ^ (B_in[0] & a_parity)
       ^ (B_in[1] & ASW1_parity)
       ^ (B_in[2] & ASW2_parity)
       ^ (B_in[3] & ASW3_parity);

assign c_ptree = ^ C;

assign EC = c_ptree ^ predict_parity;

assign ERROR = EC;

//移位运算
always @( * ) begin
    //A*x^i
    SHLW(A_in, ASW1);
    SHLW(ASW1, ASW2);
    SHLW(ASW2, ASW3);
    SHLW(ASW3, ASW4);
end


//输出
always @(posedge CLK) begin
    if (!RST_N) begin
        C <= {n{1'b0}};
        OUT_VALID <= 1'b0;
        DOUT <= 0;
        state <= IDLE;
        A_in <= {n{1'b0}};
        B_in <= {n{1'b0}};
        cnt <= 0;
        a_parity <= 0;
        predict_parity <= 1'b0;
        A_initial<=0;
        B_initial<=0;
        //test_cnt <= 0;
    end
    else begin
        //test_cnt<=test_cnt+1;
        case (state)
            IDLE: begin
                a_parity <= 0;
                predict_parity <= 1'b0;
                C <= {n{1'b0}};
                OUT_VALID <= 0;
                cnt <= 0;
                if (IN_VALID) begin
                    state <= INIT;
                    //遇到输入有效信号，立即初始化一次，
                    //因为输入有效可能只维持一个时钟周期，到下一个状态后IN_VALID信号就无效了
                    //如果维持多个时钟周期，数据更新由INIT状态执行。
                    A_in <= A;
                    B_in <= B;
                    A_initial <= A;
                    B_initial <= B;
                    $display($time, " MULT A=%h, B=%h\n", A, B);
                    //$fwrite(out_file, " MULT A=%h, B=%h\n", A, B);
                    a_parity <= ^ A;
                end
            end
            INIT: begin
                if (!IN_VALID) begin
                    state <= START;
                end
                else begin
                    A_in <= A;
                    B_in <= B;
                    A_initial <= A;
                    B_initial <= B;
                    //$display($time, " MULT A=%h, B=%h\n", A, B);
                    //$fwrite(out_file, " MULT A=%h, B=%h\n", A, B);
                    a_parity <= ^ A;

                    //不赋值的寄存器置零 增加于2020-12-19
                    C <= {n{1'b0}};  
                    predict_parity <= 1'b0;
                    OUT_VALID <= 0;
                    cnt <= 0;
                end
            end
            START: begin
                cnt <= cnt + 1'b1;
                B_in <= B_in >> w;
                A_in <= ASW4;

                predict_parity <= predict_parity_next;
                a_parity <= ASW4_parity;
                //$display("test_cnt=%d, C[10]=%h\n", test_cnt, C[10]);
                C <= c_next;

                // 故障注入
                // if (test_cnt==30) begin
                //     $display("C[10]=%h\n", C[10]);
                //     C[10]<=0;
                // end

                if (cnt == delay_cyc ) begin
                    $display("C=%h\n", C);
                    OUT_VALID <= 1'b1;
                    DOUT <= C;
                    state <= IDLE;
                end
                else begin
                    OUT_VALID <= 1'b0;
                end

                //若检测到在运算过程中输入有效，则重新开始运算 增加于2020-12-19
                if (IN_VALID) begin
                    state <= INIT;
                    //遇到输入有效信号，立即初始化一次，
                    //因为输入有效可能只维持一个时钟周期。
                    //如果维持多个时钟周期，数据更新由INIT状态执行。
                    A_in <= A;
                    B_in <= B;
                    A_initial <= A;
                    B_initial <= B;
                    $display($time, " MULT A=%h, B=%h\n", A, B);
                    //$fwrite(out_file, " MULT A=%h, B=%h\n", A, B);
                    a_parity <= ^ A;

                    //不赋值的寄存器置零 
                    C <= {n{1'b0}};  
                    predict_parity <= 1'b0;
                    OUT_VALID <= 0;
                    cnt <= 0;
                end

                if (ERROR == 1'b1) begin
                    $display($time, "error oucred!\n");
                    //a_parity <= 0;
                    predict_parity <= 1'b0;
                    C <= 0;
                    cnt <= 0;
                    A_in <= A_initial;
                    B_in <= B_initial;
                    a_parity <= ^ A_initial;
                end
            end
            default: begin
                state <= IDLE;
            end
        endcase

    end

end

endmodule

