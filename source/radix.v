`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    11:39:55 01/02/2020
// Design Name:
// Module Name:    radix
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
///
///Refer:  https://wenku.baidu.com/view/d535f041b90d6c85ec3ac690.html
///文中提出计算逆需要2m个时钟周期，但有些运算并非一个时钟周期即可完成。存在需要if判断的分支，而分支中需要状态机进行控制，
///对于这种情况不知道怎么写verilog代码。暂且用ready表示分支运算是否完毕，if语句直接对state进行阻塞赋值。
module radix(
           input CLK,
           input RST_N,
           input [N - 1: 0] A,
           input IN_VALID,
           output reg [N - 1: 0] OUT,
           output reg OUT_VALID,
           output reg [2: 0] state
       );
parameter N = 5; //位宽
reg [N: 0] S;
reg [N: 0] R;
reg [N: 0] U;
reg [N: 0] V;
reg [7: 0] delta; //delta表示deg(S)-deg(R)
reg ready;
reg [8: 0] cnt;
reg [7: 0] cnt_extra;


// always @(posedge CLK) begin
//   if (!RST_N) begin
//       S <= 0;
//       S[N] <= 1;
//       S[74] <= 1;
//       S[0] <= 1;
//       R <= {1'b0, A};
//       U <= 1;
//       V <= 0;
//       delta <= 0;
//       ready <= 1;
//       cnt<=0;
//       OUT<=0;
//   end
//   else begin
//       cnt<=cnt+1;
//       if (S==0) begin
//         OUT<=U[N-1:0];
//       end
//       else if (R[N] == 0) begin
//           state <= 4'h1;
//       end
//       else if (S[N] == 0 && delta != 0 && ready == 1) begin
//           state <= 4'h2;
//       end
//       else if (S[N] == 1 && delta != 0 && ready == 1) begin
//           state <= 4'h3;
//       end
//       else if (S[N] == 0 && delta == 0 && ready == 1) begin
//           state <= 4'h5;
//       end
//       else if (S[N] == 1 && delta == 0 && ready == 1) begin
//           state <= 4'h6;
//       end
//       case (state)
//           4'h1: begin
//               //计算R=xR
//               R <= {R[N - 1: 0], 1'b0}; //左移一位

//               //计算U=(xU)modf
//               U <= {U[N - 1: 0], 1'b0}; //左移一位
//               if (U[N - 1] == 1) begin
//                   U[N] <= 1'b0;
//                   U[74] <= U[73] ^ 1'b1;
//                   U[0] <= 1'b1; //左移右侧补0，0与1异或仍为1
//               end

//               delta <= delta - 1'b1;
//           end
//           4'h2: begin
//               //计算S=xS
//               S <= {S[N - 1: 0], 1'b0}; //左移一位

//               //计算U=(U/x)modf
//               U <= {1'b0, U[N: 1]}; //右移一位

//               delta <= delta - 1'b1;
//           end
//           4'h3: begin
//               //计算S-R
//               S <= S ^ R;
//               V <= U ^ V;

//               //计算U=(U/x)modf
//               U <= {1'b0, U[N: 1]}; //右移一位

//               delta <= delta - 1'b1;
//               state <= 4'h4;
//               ready <= 0;
//           end
//           4'h4: begin
//               S <= {S[N - 1: 0], 1'b0}; //左移一位

//               if (V[N] == 1) begin
//                   V[N] <= 1'b0;
//                   V[74] <= V[74] ^ 1'b1;
//                   V[0] <= V[0] ^ 1'b1;
//               end
//               ready <= 1;
//           end
//           4'h5: begin
//               //计算R=xS
//               R <= {S[N - 1: 0], 1'b0};
//               S <= R;

//               //计算U=(xV)modf
//               U <= {V[N - 1: 0], 1'b0};
//               if (U[N - 1] == 1) begin
//                   U[N] <= 1'b0;
//                   U[74] <= U[73] ^ 1'b1;
//                   U[0] <= 1'b1;
//               end

//               V <= U;
//               delta <= delta + 1;
//           end
//           4'h6: begin
//               //计算S-R、V-U
//               R <= S ^ R;
//               U <= U ^ V;
//               S <= R;
//               V <= U;


//               delta <= delta + 1'b1;
//               state <= 4'h7;
//               ready <= 0;
//           end
//           4'h7: begin
//               //计算R=x(S-R)
//               R <= {R[N - 1: 0], 1'b0}
//               //计算U=x(V-U)modf
//               U <= {U[N - 1: 0], 1'b0}; //左移一位
//               if (U[N-1] == 1) begin
//                   U[N] <= 1'b0;
//                   U[74] <= U[73] ^ 1'b1;
//                   U[0] <= 1'b1;
//               end
//               ready <= 1;
//           end
//       end
//   end
// end
//
//



always @(posedge CLK) begin
    if (!RST_N) begin
        S <= 0;
        S[N] <= 1;
        S[2] <= 1;
        S[0] <= 1;
        R <= 0;
        U <= 1;
        V <= 0;
        delta <= 0;
        ready <= 1;
        cnt <= 0;
        cnt_extra <= 0;
        OUT <= 0;
        state <= 0;
        OUT_VALID <= 0;
    end
    else if (IN_VALID) begin
        R <= {1'b0, A[N - 1: 0]};
        cnt <= 0;
        cnt_extra <= 0;
    end
    else begin
        cnt <= cnt + 1;

        $display($time, " R=%b S=%b U=%b V=%b ready=%b, cnt=%d, delta=%d, state=%h", R, S, U, V, ready, cnt, delta, state);
        if (S == 0 || R == 0) begin
            //if (cnt - cnt_extra==2*N) begin
            OUT <= U[N - 1: 0];
            OUT_VALID <= 1;
            state <= 0;
        end
        else if (R[N] == 0 && ready == 1) begin
            state = 4'h1; //这里不知道怎么处理state，比如需要本周期进入state1，可是非阻塞赋值不会使得state立刻得到需要的值，从而进入错误的分支
        end
        else if (S[N] == 0 && delta != 0 && ready == 1) begin
            state = 4'h2;
        end
        else if (S[N] == 1 && delta != 0 && ready == 1) begin
            state = 4'h3;
        end
        else if (S[N] == 0 && delta == 0 && ready == 1) begin
            state = 4'h5;
        end
        else if (S[N] == 1 && delta == 0 && ready == 1) begin
            state = 4'h6;
        end
        case (state)
            4'h0: begin
                OUT_VALID <= 0;
                cnt <= 0;
            end
            4'h1: begin
                //计算R=xR
                R <= {R[N - 1: 0], 1'b0}; //左移一位

                //计算U=(xU)modf
                U <= {U[N - 1: 0], 1'b0}; //左移一位
                if (U[N - 1] == 1) begin
                    U[N] <= 1'b0;
                    U[2] <= U[1] ^ 1'b1;
                    U[0] <= 1'b1; //左移右侧补0，0与1异或仍为1
                end

                delta <= delta + 1'b1;
            end
            4'h2: begin
                //计算S=xS
                S <= {S[N - 1: 0], 1'b0}; //左移一位

                //计算U=(U/x)modf
                U <= {1'b0, U[N: 1]}; //右移一位

                delta <= delta - 1'b1;
            end
            4'h3: begin
                //计算S-R
                S <= S ^ R;

                //计算V-U
                V <= U ^ V;

                //计算U=(U/x)modf
                U <= {1'b0, U[N: 1]}; //右移一位

                delta <= delta - 1'b1;
                state <= 4'h4;
                ready <= 0;
                cnt_extra <= cnt_extra + 1'b1;
            end
            4'h4: begin
                S <= {S[N - 1: 0], 1'b0}; //左移一位

                if (V[N] == 1) begin
                    V[N] <= 1'b0;
                    V[2] <= V[2] ^ 1'b1;
                    V[0] <= V[0] ^ 1'b1;
                end
                ready <= 1;
            end
            4'h5: begin
                //计算R=xS
                R <= {S[N - 1: 0], 1'b0};
                S <= R;

                //计算U=(xV)modf
                U <= {V[N - 1: 0], 1'b0};
                if (U[N - 1] == 1) begin
                    U[N] <= 1'b0;
                    U[2] <= U[1] ^ 1'b1;
                    U[0] <= 1'b1;
                end

                V <= U;
                delta <= delta + 1;
            end
            4'h6: begin
                //计算S-R、V-U
                R <= S ^ R;
                U <= U ^ V;
                S <= R;
                V <= U;


                delta <= delta + 1'b1;
                state <= 4'h7;
                ready <= 0;
                cnt_extra <= cnt_extra + 1'b1;
            end
            4'h7: begin
                //计算R=x(S-R)
                R <= {R[N - 1: 0], 1'b0};
                //计算U=x(V-U)modf
                U <= {U[N - 1: 0], 1'b0}; //左移一位
                if (U[N - 1] == 1) begin
                    U[N] <= 1'b0;
                    U[2] <= U[1] ^ 1'b1;
                    U[0] <= 1'b1;
                end
                ready <= 1;
            end
            default: begin
                ready <= 1;
            end
        endcase
    end
end
endmodule
