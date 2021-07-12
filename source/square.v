`timescale 1ns / 1ps 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    09:57:54 01/02/2020
// Design Name:
// Module Name:    squar
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
module square(
           input [232: 0] DIN,
           output [232: 0] DOUT
       );

/****************
1
***************/
assign DOUT[0] = DIN[0] ^ DIN[196];
assign DOUT[2] = DIN[1] ^ DIN[197];
assign DOUT[4] = DIN[2] ^ DIN[198];
assign DOUT[6] = DIN[3] ^ DIN[199];
assign DOUT[8] = DIN[4] ^ DIN[200];
assign DOUT[10] = DIN[5] ^ DIN[201];
assign DOUT[12] = DIN[6] ^ DIN[202];
assign DOUT[14] = DIN[7] ^ DIN[203];
assign DOUT[16] = DIN[8] ^ DIN[204];
assign DOUT[18] = DIN[9] ^ DIN[205];
assign DOUT[20] = DIN[10] ^ DIN[206];
assign DOUT[22] = DIN[11] ^ DIN[207];
assign DOUT[24] = DIN[12] ^ DIN[208];
assign DOUT[26] = DIN[13] ^ DIN[209];
assign DOUT[28] = DIN[14] ^ DIN[210];
assign DOUT[30] = DIN[15] ^ DIN[211];
assign DOUT[32] = DIN[16] ^ DIN[212];
assign DOUT[34] = DIN[17] ^ DIN[213];
assign DOUT[36] = DIN[18] ^ DIN[214];
assign DOUT[38] = DIN[19] ^ DIN[215];
assign DOUT[40] = DIN[20] ^ DIN[216];
assign DOUT[42] = DIN[21] ^ DIN[217];
assign DOUT[44] = DIN[22] ^ DIN[218];
assign DOUT[46] = DIN[23] ^ DIN[219];
assign DOUT[48] = DIN[24] ^ DIN[220];
assign DOUT[50] = DIN[25] ^ DIN[221];
assign DOUT[52] = DIN[26] ^ DIN[222];
assign DOUT[54] = DIN[27] ^ DIN[223];
assign DOUT[56] = DIN[28] ^ DIN[224];
assign DOUT[58] = DIN[29] ^ DIN[225];
assign DOUT[60] = DIN[30] ^ DIN[226];
assign DOUT[62] = DIN[31] ^ DIN[227];
assign DOUT[64] = DIN[32] ^ DIN[228];
assign DOUT[66] = DIN[33] ^ DIN[229];
assign DOUT[68] = DIN[34] ^ DIN[230];
assign DOUT[70] = DIN[35] ^ DIN[231];
assign DOUT[72] = DIN[36] ^ DIN[232];
/******************
2
*******************/
assign DOUT[1] = DIN[117];
assign DOUT[3] = DIN[118];
assign DOUT[5] = DIN[119];
assign DOUT[7] = DIN[120];
assign DOUT[9] = DIN[121];
assign DOUT[11] = DIN[122];
assign DOUT[13] = DIN[123];
assign DOUT[15] = DIN[124];
assign DOUT[17] = DIN[125];
assign DOUT[19] = DIN[126];
assign DOUT[21] = DIN[127];
assign DOUT[23] = DIN[128];
assign DOUT[25] = DIN[129];
assign DOUT[27] = DIN[130];
assign DOUT[29] = DIN[131];
assign DOUT[31] = DIN[132];
assign DOUT[33] = DIN[133];
assign DOUT[35] = DIN[134];
assign DOUT[37] = DIN[135];
assign DOUT[39] = DIN[136];
assign DOUT[41] = DIN[137];
assign DOUT[43] = DIN[138];
assign DOUT[45] = DIN[139];
assign DOUT[47] = DIN[140];
assign DOUT[49] = DIN[141];
assign DOUT[51] = DIN[142];
assign DOUT[53] = DIN[143];
assign DOUT[55] = DIN[144];
assign DOUT[57] = DIN[145];
assign DOUT[59] = DIN[146];
assign DOUT[61] = DIN[147];
assign DOUT[63] = DIN[148];
assign DOUT[65] = DIN[149];
assign DOUT[67] = DIN[150];
assign DOUT[69] = DIN[151];
assign DOUT[71] = DIN[152];
assign DOUT[73] = DIN[153];
/******************
3
*******************/
assign DOUT[74] = DIN[37] ^ DIN[196];
assign DOUT[76] = DIN[38] ^ DIN[197];
assign DOUT[78] = DIN[39] ^ DIN[198];
assign DOUT[80] = DIN[40] ^ DIN[199];
assign DOUT[82] = DIN[41] ^ DIN[200];
assign DOUT[84] = DIN[42] ^ DIN[201];
assign DOUT[86] = DIN[43] ^ DIN[202];
assign DOUT[88] = DIN[44] ^ DIN[203];
assign DOUT[90] = DIN[45] ^ DIN[204];
assign DOUT[92] = DIN[46] ^ DIN[205];
assign DOUT[94] = DIN[47] ^ DIN[206];
assign DOUT[96] = DIN[48] ^ DIN[207];
assign DOUT[98] = DIN[49] ^ DIN[208];
assign DOUT[100] = DIN[50] ^ DIN[209];
assign DOUT[102] = DIN[51] ^ DIN[210];
assign DOUT[104] = DIN[52] ^ DIN[211];
assign DOUT[106] = DIN[53] ^ DIN[212];
assign DOUT[108] = DIN[54] ^ DIN[213];
assign DOUT[110] = DIN[55] ^ DIN[214];
assign DOUT[112] = DIN[56] ^ DIN[215];
assign DOUT[114] = DIN[57] ^ DIN[216];
assign DOUT[116] = DIN[58] ^ DIN[217];
assign DOUT[118] = DIN[59] ^ DIN[218];
assign DOUT[120] = DIN[60] ^ DIN[219];
assign DOUT[122] = DIN[61] ^ DIN[220];
assign DOUT[124] = DIN[62] ^ DIN[221];
assign DOUT[126] = DIN[63] ^ DIN[222];
assign DOUT[128] = DIN[64] ^ DIN[223];
assign DOUT[130] = DIN[65] ^ DIN[224];
assign DOUT[132] = DIN[66] ^ DIN[225];
assign DOUT[134] = DIN[67] ^ DIN[226];
assign DOUT[136] = DIN[68] ^ DIN[227];
assign DOUT[138] = DIN[69] ^ DIN[228];
assign DOUT[140] = DIN[70] ^ DIN[229];
assign DOUT[142] = DIN[71] ^ DIN[230];
assign DOUT[144] = DIN[72] ^ DIN[231];
assign DOUT[146] = DIN[73] ^ DIN[232];
/*******************
4
********************/
assign DOUT[75] = DIN[154] ^ DIN[117];
assign DOUT[77] = DIN[155] ^ DIN[118];
assign DOUT[79] = DIN[156] ^ DIN[119];
assign DOUT[81] = DIN[157] ^ DIN[120];
assign DOUT[83] = DIN[158] ^ DIN[121];
assign DOUT[85] = DIN[159] ^ DIN[122];
assign DOUT[87] = DIN[160] ^ DIN[123];
assign DOUT[89] = DIN[161] ^ DIN[124];
assign DOUT[91] = DIN[162] ^ DIN[125];
assign DOUT[93] = DIN[163] ^ DIN[126];
assign DOUT[95] = DIN[164] ^ DIN[127];
assign DOUT[97] = DIN[165] ^ DIN[128];
assign DOUT[99] = DIN[166] ^ DIN[129];
assign DOUT[101] = DIN[167] ^ DIN[130];
assign DOUT[103] = DIN[168] ^ DIN[131];
assign DOUT[105] = DIN[169] ^ DIN[132];
assign DOUT[107] = DIN[170] ^ DIN[133];
assign DOUT[109] = DIN[171] ^ DIN[134];
assign DOUT[111] = DIN[172] ^ DIN[135];
assign DOUT[113] = DIN[173] ^ DIN[136];
assign DOUT[115] = DIN[174] ^ DIN[137];
assign DOUT[117] = DIN[175] ^ DIN[138];
assign DOUT[119] = DIN[176] ^ DIN[139];
assign DOUT[121] = DIN[177] ^ DIN[140];
assign DOUT[123] = DIN[178] ^ DIN[141];
assign DOUT[125] = DIN[179] ^ DIN[142];
assign DOUT[127] = DIN[180] ^ DIN[143];
assign DOUT[129] = DIN[181] ^ DIN[144];
assign DOUT[131] = DIN[182] ^ DIN[145];
assign DOUT[133] = DIN[183] ^ DIN[146];
assign DOUT[135] = DIN[184] ^ DIN[147];
assign DOUT[137] = DIN[185] ^ DIN[148];
assign DOUT[139] = DIN[186] ^ DIN[149];
assign DOUT[141] = DIN[187] ^ DIN[150];
assign DOUT[143] = DIN[188] ^ DIN[151];
assign DOUT[145] = DIN[189] ^ DIN[152];
assign DOUT[147] = DIN[190] ^ DIN[153];
assign DOUT[149] = DIN[191] ^ DIN[154];
assign DOUT[151] = DIN[192] ^ DIN[155];
assign DOUT[153] = DIN[193] ^ DIN[156];
assign DOUT[155] = DIN[194] ^ DIN[157];
assign DOUT[157] = DIN[195] ^ DIN[158];
assign DOUT[159] = DIN[196] ^ DIN[159];
assign DOUT[161] = DIN[197] ^ DIN[160];
assign DOUT[163] = DIN[198] ^ DIN[161];
assign DOUT[165] = DIN[199] ^ DIN[162];
assign DOUT[167] = DIN[200] ^ DIN[163];
assign DOUT[169] = DIN[201] ^ DIN[164];
assign DOUT[171] = DIN[202] ^ DIN[165];
assign DOUT[173] = DIN[203] ^ DIN[166];
assign DOUT[175] = DIN[204] ^ DIN[167];
assign DOUT[177] = DIN[205] ^ DIN[168];
assign DOUT[179] = DIN[206] ^ DIN[169];
assign DOUT[181] = DIN[207] ^ DIN[170];
assign DOUT[183] = DIN[208] ^ DIN[171];
assign DOUT[185] = DIN[209] ^ DIN[172];
assign DOUT[187] = DIN[210] ^ DIN[173];
assign DOUT[189] = DIN[211] ^ DIN[174];
assign DOUT[191] = DIN[212] ^ DIN[175];
assign DOUT[193] = DIN[213] ^ DIN[176];
assign DOUT[195] = DIN[214] ^ DIN[177];
assign DOUT[197] = DIN[215] ^ DIN[178];
assign DOUT[199] = DIN[216] ^ DIN[179];
assign DOUT[201] = DIN[217] ^ DIN[180];
assign DOUT[203] = DIN[218] ^ DIN[181];
assign DOUT[205] = DIN[219] ^ DIN[182];
assign DOUT[207] = DIN[220] ^ DIN[183];
assign DOUT[209] = DIN[221] ^ DIN[184];
assign DOUT[211] = DIN[222] ^ DIN[185];
assign DOUT[213] = DIN[223] ^ DIN[186];
assign DOUT[215] = DIN[224] ^ DIN[187];
assign DOUT[217] = DIN[225] ^ DIN[188];
assign DOUT[219] = DIN[226] ^ DIN[189];
assign DOUT[221] = DIN[227] ^ DIN[190];
assign DOUT[223] = DIN[228] ^ DIN[191];
assign DOUT[225] = DIN[229] ^ DIN[192];
assign DOUT[227] = DIN[230] ^ DIN[193];
assign DOUT[229] = DIN[231] ^ DIN[194];
assign DOUT[231] = DIN[232] ^ DIN[195];
/********************
5
*********************/
assign DOUT[148] = DIN[74];
assign DOUT[150] = DIN[75];
assign DOUT[152] = DIN[76];
assign DOUT[154] = DIN[77];
assign DOUT[156] = DIN[78];
assign DOUT[158] = DIN[79];
assign DOUT[160] = DIN[80];
assign DOUT[162] = DIN[81];
assign DOUT[164] = DIN[82];
assign DOUT[166] = DIN[83];
assign DOUT[168] = DIN[84];
assign DOUT[170] = DIN[85];
assign DOUT[172] = DIN[86];
assign DOUT[174] = DIN[87];
assign DOUT[176] = DIN[88];
assign DOUT[178] = DIN[89];
assign DOUT[180] = DIN[90];
assign DOUT[182] = DIN[91];
assign DOUT[184] = DIN[92];
assign DOUT[186] = DIN[93];
assign DOUT[188] = DIN[94];
assign DOUT[190] = DIN[95];
assign DOUT[192] = DIN[96];
assign DOUT[194] = DIN[97];
assign DOUT[196] = DIN[98];
assign DOUT[198] = DIN[99];
assign DOUT[200] = DIN[100];
assign DOUT[202] = DIN[101];
assign DOUT[204] = DIN[102];
assign DOUT[206] = DIN[103];
assign DOUT[208] = DIN[104];
assign DOUT[210] = DIN[105];
assign DOUT[212] = DIN[106];
assign DOUT[214] = DIN[107];
assign DOUT[216] = DIN[108];
assign DOUT[218] = DIN[109];
assign DOUT[220] = DIN[110];
assign DOUT[222] = DIN[111];
assign DOUT[224] = DIN[112];
assign DOUT[226] = DIN[113];
assign DOUT[228] = DIN[114];
assign DOUT[230] = DIN[115];
assign DOUT[232] = DIN[116];



endmodule
