// basing implementation off of pseudocode from https://en.wikipedia.org/wiki/MD5
module MD5Chunk
(
  input wire clock,
  input wire [511:0] message,
  output wire [127:0] digest
);
  reg [4:0] shifts [63:0];
  initial begin
    shifts[0] = 7;
    shifts[1] = 12;
    shifts[2] = 17;
    shifts[3] = 22;
    shifts[4] = 7;
    shifts[5] = 12;
    shifts[6] = 17;
    shifts[7] = 22;
    shifts[8] = 7;
    shifts[9] = 12;
    shifts[10] = 17;
    shifts[11] = 22;
    shifts[12] = 7;
    shifts[13] = 12;
    shifts[14] = 17;
    shifts[15] = 22;
    shifts[16] = 5;
    shifts[17] = 9;
    shifts[18] = 14;
    shifts[19] = 20;
    shifts[20] = 5;
    shifts[21] = 9;
    shifts[22] = 14;
    shifts[23] = 20;
    shifts[24] = 5;
    shifts[25] = 9;
    shifts[26] = 14;
    shifts[27] = 20;
    shifts[28] = 5;
    shifts[29] = 9;
    shifts[30] = 14;
    shifts[31] = 20;
    shifts[32] = 4;
    shifts[33] = 11;
    shifts[34] = 16;
    shifts[35] = 23;
    shifts[36] = 4;
    shifts[37] = 11;
    shifts[38] = 16;
    shifts[39] = 23;
    shifts[40] = 4;
    shifts[41] = 11;
    shifts[42] = 16;
    shifts[43] = 23;
    shifts[44] = 4;
    shifts[45] = 11;
    shifts[46] = 16;
    shifts[47] = 23;
    shifts[48] = 6;
    shifts[49] = 10;
    shifts[50] = 15;
    shifts[51] = 21;
    shifts[52] = 6;
    shifts[53] = 10;
    shifts[54] = 15;
    shifts[55] = 21;
    shifts[56] = 6;
    shifts[57] = 10;
    shifts[58] = 15;
    shifts[59] = 21;
    shifts[60] = 6;
    shifts[61] = 10;
    shifts[62] = 15;
    shifts[63] = 21;
  end
  reg [31:0] k [63:0];
  initial begin
    k[0] = 32'hd76aa478;
    k[1] = 32'he8c7b756;
    k[2] = 32'h242070db;
    k[3] = 32'hc1bdceee;
    k[4] = 32'hf57c0faf;
    k[5] = 32'h4787c62a;
    k[6] = 32'ha8304613;
    k[7] = 32'hfd469501;
    k[8] = 32'h698098d8;
    k[9] = 32'h8b44f7af;
    k[10] = 32'hffff5bb1;
    k[11] = 32'h895cd7be;
    k[12] = 32'h6b901122;
    k[13] = 32'hfd987193;
    k[14] = 32'ha679438e;
    k[15] = 32'h49b40821;
    k[16] = 32'hf61e2562;
    k[17] = 32'hc040b340;
    k[18] = 32'h265e5a51;
    k[19] = 32'he9b6c7aa;
    k[20] = 32'hd62f105d;
    k[21] = 32'h02441453;
    k[22] = 32'hd8a1e681;
    k[23] = 32'he7d3fbc8;
    k[24] = 32'h21e1cde6;
    k[25] = 32'hc33707d6;
    k[26] = 32'hf4d50d87;
    k[27] = 32'h455a14ed;
    k[28] = 32'ha9e3e905;
    k[29] = 32'hfcefa3f8;
    k[30] = 32'h676f02d9;
    k[31] = 32'h8d2a4c8a;
    k[32] = 32'hfffa3942;
    k[33] = 32'h8771f681;
    k[34] = 32'h6d9d6122;
    k[35] = 32'hfde5380c;
    k[36] = 32'ha4beea44;
    k[37] = 32'h4bdecfa9;
    k[38] = 32'hf6bb4b60;
    k[39] = 32'hbebfbc70;
    k[40] = 32'h289b7ec6;
    k[41] = 32'heaa127fa;
    k[42] = 32'hd4ef3085;
    k[43] = 32'h04881d05;
    k[44] = 32'hd9d4d039;
    k[45] = 32'he6db99e5;
    k[46] = 32'h1fa27cf8;
    k[47] = 32'hc4ac5665;
    k[48] = 32'hf4292244;
    k[49] = 32'h432aff97;
    k[50] = 32'hab9423a7;
    k[51] = 32'hfc93a039;
    k[52] = 32'h655b59c3;
    k[53] = 32'h8f0ccc92;
    k[54] = 32'hffeff47d;
    k[55] = 32'h85845dd1;
    k[56] = 32'h6fa87e4f;
    k[57] = 32'hfe2ce6e0;
    k[58] = 32'ha3014314;
    k[59] = 32'h4e0811a1;
    k[60] = 32'hf7537e82;
    k[61] = 32'hbd3af235;
    k[62] = 32'h2ad7d2bb;
    k[63] = 32'heb86d391;
  end
  wire [31:0] a [64:0];
  wire [31:0] b [64:0];
  wire [31:0] c [64:0];
  wire [31:0] d [64:0];
  wire [31:0] a_final, b_final, c_final, d_final;

  assign a[0] = 32'h67452301;
  assign b[0] = 32'hefcdab89;
  assign c[0] = 32'h98badcfe;
  assign d[0] = 32'h10325476;
  assign a_final = a[64] + 32'h67452301;
  assign b_final = b[64] + 32'hefcdab89;
  assign c_final = c[64] + 32'h98badcfe;
  assign d_final = d[64] + 32'h10325476;
  assign digest = {d_final, c_final, b_final, a_final};

  genvar i;
  for (i=0; i<16; i=i+1) begin
    wire [5:0] round_num = i;
    MD5RoundType1 round(clock, a[i], b[i], c[i], d[i], k[i], shifts[i], round_num, message, a[i+1], b[i+1], c[i+1], d[i+1]);
  end
  for (i=16; i<32; i=i+1) begin
    wire [5:0] round_num = i;
    MD5RoundType2 round(clock, a[i], b[i], c[i], d[i], k[i], shifts[i], round_num, message, a[i+1], b[i+1], c[i+1], d[i+1]);
  end
  for (i=32; i<48; i=i+1) begin
    wire [5:0] round_num = i;
    MD5RoundType3 round(clock, a[i], b[i], c[i], d[i], k[i], shifts[i], round_num, message, a[i+1], b[i+1], c[i+1], d[i+1]);
  end
  for (i=48; i<64; i=i+1) begin
    wire [5:0] round_num = i;
    MD5RoundType4 round(clock, a[i], b[i], c[i], d[i], k[i], shifts[i], round_num, message, a[i+1], b[i+1], c[i+1], d[i+1]);
  end
endmodule

module MD5RoundType4
(
  input wire clock,
  input wire [31:0] a_in,
  input wire [31:0] b_in,
  input wire [31:0] c_in,
  input wire [31:0] d_in,
  input wire [31:0] k_in,
  input wire [4:0] shift_amount,
  input wire [5:0] round_num,
  input wire [511:0] message,

  output reg [31:0] a_out,
  output reg [31:0] b_out,
  output reg [31:0] c_out,
  output reg [31:0] d_out
);
  wire [31:0] a;
  wire [31:0] b;
  wire [31:0] c;
  wire [31:0] d;
  wire [31:0] f_one, f_two;
  wire [31:0] b_partial;
  wire [5:0] round_num_modified;
  wire [3:0] g;
  wire [31:0] message_g;
  wire [31:0] message_internal [15:0];

  genvar i;
  for (i=0; i<16; i=i+1) begin
    assign message_internal[i] = message[((i+1)*32)-1 -: 32];
  end

  assign f_one = c_in ^ (b_in | ~d_in);
  assign round_num_modified = (round_num << 2) + round_num + round_num + round_num;
  assign g = round_num_modified[3:0];
  assign message_g = message_internal[g];
  assign f_two = f_one + a_in + k_in + message_g;

  assign a = d_in;
  leftrotate lr(.in(f_two), .shift_amount(shift_amount), .out(b_partial));
  assign b = b_in + b_partial;
  assign c = b_in;
  assign d = c_in;

  always @(posedge clock) begin
    a_out <= a;
    b_out <= b;
    c_out <= c;
    d_out <= d;
  end
endmodule

module MD5RoundType3
(
  input wire clock,
  input wire [31:0] a_in,
  input wire [31:0] b_in,
  input wire [31:0] c_in,
  input wire [31:0] d_in,
  input wire [31:0] k_in,
  input wire [4:0] shift_amount,
  input wire [5:0] round_num,
  input wire [511:0] message,

  output reg [31:0] a_out,
  output reg [31:0] b_out,
  output reg [31:0] c_out,
  output reg [31:0] d_out
);
  wire [31:0] a;
  wire [31:0] b;
  wire [31:0] c;
  wire [31:0] d;
  wire [31:0] f_one, f_two;
  wire [31:0] b_partial;
  wire [5:0] round_num_modified;
  wire [3:0] g;
  wire [31:0] message_g;
  wire [31:0] message_internal [15:0];

  genvar i;
  for (i=0; i<16; i=i+1) begin
    assign message_internal[i] = message[((i+1)*32)-1 -: 32];
  end

  assign f_one = (b_in ^ c_in) ^ d_in;
  assign round_num_modified = round_num + round_num + round_num + 5;
  assign g = round_num_modified[3:0];
  assign message_g = message_internal[g];
  assign f_two = f_one + a_in + k_in + message_g;

  assign a = d_in;
  leftrotate lr(.in(f_two), .shift_amount(shift_amount), .out(b_partial));
  assign b = b_in + b_partial;
  assign c = b_in;
  assign d = c_in;

  always @(posedge clock) begin
    a_out <= a;
    b_out <= b;
    c_out <= c;
    d_out <= d;
  end
endmodule

module MD5RoundType2
(
  input wire clock,
  input wire [31:0] a_in,
  input wire [31:0] b_in,
  input wire [31:0] c_in,
  input wire [31:0] d_in,
  input wire [31:0] k_in,
  input wire [4:0] shift_amount,
  input wire [5:0] round_num,
  input wire [511:0] message,

  output reg [31:0] a_out,
  output reg [31:0] b_out,
  output reg [31:0] c_out,
  output reg [31:0] d_out
);
  wire [31:0] a;
  wire [31:0] b;
  wire [31:0] c;
  wire [31:0] d;
  wire [31:0] f_one, f_two;
  wire [31:0] b_partial;
  wire [5:0] round_num_modified;
  wire [3:0] g;
  wire [31:0] message_g;
  wire [31:0] message_internal [15:0];

  genvar i;
  for (i=0; i<16; i=i+1) begin
    assign message_internal[i] = message[((i+1)*32)-1 -: 32];
  end

  assign f_one = (d_in & b_in) | (~d_in & c_in);
  assign round_num_modified = (round_num << 2) + round_num + 1;
  assign g = round_num_modified[3:0];
  assign message_g = message_internal[g];
  assign f_two = f_one + a_in + k_in + message_g;

  assign a = d_in;
  leftrotate lr(.in(f_two), .shift_amount(shift_amount), .out(b_partial));
  assign b = b_in + b_partial;
  assign c = b_in;
  assign d = c_in;

  always @(posedge clock) begin
    a_out <= a;
    b_out <= b;
    c_out <= c;
    d_out <= d;
  end
endmodule

module MD5RoundType1
(
  input wire clock,
  input wire [31:0] a_in,
  input wire [31:0] b_in,
  input wire [31:0] c_in,
  input wire [31:0] d_in,
  input wire [31:0] k_in,
  input wire [4:0] shift_amount,
  input wire [5:0] round_num,
  input wire [511:0] message,

  output reg [31:0] a_out,
  output reg [31:0] b_out,
  output reg [31:0] c_out,
  output reg [31:0] d_out
);
  wire [31:0] a;
  wire [31:0] b;
  wire [31:0] c;
  wire [31:0] d;
  wire [31:0] f_one, f_two;
  wire [31:0] b_partial;
  wire [3:0] g;
  wire [31:0] message_g;
  wire [31:0] message_internal [15:0];

  genvar i;
  for (i=0; i<16; i=i+1) begin
    assign message_internal[i] = message[((i+1)*32)-1 -: 32];
  end

  assign f_one = (b_in & c_in) | (~b_in & d_in);
  assign g = round_num[3:0];
  assign message_g = message_internal[g];
  assign f_two = f_one + a_in + k_in + message_g;

  assign a = d_in;
  leftrotate lr(.in(f_two), .shift_amount(shift_amount), .out(b_partial));
  assign b = b_in + b_partial;
  assign c = b_in;
  assign d = c_in;

  always @(posedge clock) begin
    a_out <= a;
    b_out <= b;
    c_out <= c;
    d_out <= d;
  end
endmodule

// inspired by https://stackoverflow.com/questions/7543592/verilog-barrel-shifter
module leftrotate
(
  input wire [31:0] in,
  input wire [4:0] shift_amount,
  output wire [31:0] out
);
  wire [63:0] in_double;
  assign in_double = {in, in};
  assign out = in_double[63 - shift_amount -: 32];
endmodule