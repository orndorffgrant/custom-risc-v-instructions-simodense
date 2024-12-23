// basing implementation off of pseudocode from https://en.wikipedia.org/wiki/MD5
module MD5
(
  input wire clock,
  input wire [511:0] message,

  output wire [127:0] digest
);
  wire [31:0] a [4:0];
  wire [31:0] b [4:0];
  wire [31:0] c [4:0];
  wire [31:0] d [4:0];
  wire [31:0] a_final, b_final, c_final, d_final;

  assign a[0] = 32'h67452301;
  assign b[0] = 32'hefcdab89;
  assign c[0] = 32'h98badcfe;
  assign d[0] = 32'h10325476;
  assign a_final = a[4] + 32'h67452301;
  assign b_final = b[4] + 32'hefcdab89;
  assign c_final = c[4] + 32'h98badcfe;
  assign d_final = d[4] + 32'h10325476;
  assign digest = {d_final, c_final, b_final, a_final};

  MD5Rounds1To16Sync rounds1to16(clock, a[0], b[0], c[0], d[0], message, a[1], b[1], c[1], d[1]);
  MD5Rounds17To32Sync rounds17to32(clock, a[1], b[1], c[1], d[1], message, a[2], b[2], c[2], d[2]);
  MD5Rounds33To48Sync rounds33to48(clock, a[2], b[2], c[2], d[2], message, a[3], b[3], c[3], d[3]);
  MD5Rounds49To64Sync rounds49to64(clock, a[3], b[3], c[3], d[3], message, a[4], b[4], c[4], d[4]);

endmodule

module MD5Rounds49To64Sync
(
  input wire clock,
  input wire [31:0] a_in,
  input wire [31:0] b_in,
  input wire [31:0] c_in,
  input wire [31:0] d_in,
  input wire [511:0] message,

  output reg [31:0] a_out,
  output reg [31:0] b_out,
  output reg [31:0] c_out,
  output reg [31:0] d_out
);
  wire [31:0] a, b, c, d;
  MD5Rounds49To64 rounds(a_in, b_in, c_in, d_in, message, a, b, c, d);
  always @(posedge clock) begin
    a_out <= a;
    b_out <= b;
    c_out <= c;
    d_out <= d;
  end
endmodule

module MD5Rounds33To48Sync
(
  input wire clock,
  input wire [31:0] a_in,
  input wire [31:0] b_in,
  input wire [31:0] c_in,
  input wire [31:0] d_in,
  input wire [511:0] message,

  output reg [31:0] a_out,
  output reg [31:0] b_out,
  output reg [31:0] c_out,
  output reg [31:0] d_out
);
  wire [31:0] a, b, c, d;
  MD5Rounds33To48 rounds(a_in, b_in, c_in, d_in, message, a, b, c, d);
  always @(posedge clock) begin
    a_out <= a;
    b_out <= b;
    c_out <= c;
    d_out <= d;
  end
endmodule

module MD5Rounds17To32Sync
(
  input wire clock,
  input wire [31:0] a_in,
  input wire [31:0] b_in,
  input wire [31:0] c_in,
  input wire [31:0] d_in,
  input wire [511:0] message,

  output reg [31:0] a_out,
  output reg [31:0] b_out,
  output reg [31:0] c_out,
  output reg [31:0] d_out
);
  wire [31:0] a, b, c, d;
  MD5Rounds17To32 rounds(a_in, b_in, c_in, d_in, message, a, b, c, d);
  always @(posedge clock) begin
    a_out <= a;
    b_out <= b;
    c_out <= c;
    d_out <= d;
  end
endmodule

module MD5Rounds1To16Sync
(
  input wire clock,
  input wire [31:0] a_in,
  input wire [31:0] b_in,
  input wire [31:0] c_in,
  input wire [31:0] d_in,
  input wire [511:0] message,

  output reg [31:0] a_out,
  output reg [31:0] b_out,
  output reg [31:0] c_out,
  output reg [31:0] d_out
);
  wire [31:0] a, b, c, d;
  MD5Rounds1To16 rounds(a_in, b_in, c_in, d_in, message, a, b, c, d);
  always @(posedge clock) begin
    a_out <= a;
    b_out <= b;
    c_out <= c;
    d_out <= d;
  end
endmodule

module MD5Rounds49To64
(
  input wire [31:0] a_in,
  input wire [31:0] b_in,
  input wire [31:0] c_in,
  input wire [31:0] d_in,
  input wire [511:0] message,

  output wire [31:0] a_out,
  output wire [31:0] b_out,
  output wire [31:0] c_out,
  output wire [31:0] d_out
);
  reg [4:0] shifts [15:0];
  initial begin
    shifts[0] = 6;
    shifts[1] = 10;
    shifts[2] = 15;
    shifts[3] = 21;
    shifts[4] = 6;
    shifts[5] = 10;
    shifts[6] = 15;
    shifts[7] = 21;
    shifts[8] = 6;
    shifts[9] = 10;
    shifts[10] = 15;
    shifts[11] = 21;
    shifts[12] = 6;
    shifts[13] = 10;
    shifts[14] = 15;
    shifts[15] = 21;
  end
  reg [31:0] k [15:0];
  initial begin
    k[0] = 32'hf4292244;
    k[1] = 32'h432aff97;
    k[2] = 32'hab9423a7;
    k[3] = 32'hfc93a039;
    k[4] = 32'h655b59c3;
    k[5] = 32'h8f0ccc92;
    k[6] = 32'hffeff47d;
    k[7] = 32'h85845dd1;
    k[8] = 32'h6fa87e4f;
    k[9] = 32'hfe2ce6e0;
    k[10] = 32'ha3014314;
    k[11] = 32'h4e0811a1;
    k[12] = 32'hf7537e82;
    k[13] = 32'hbd3af235;
    k[14] = 32'h2ad7d2bb;
    k[15] = 32'heb86d391;
  end
  wire [31:0] a [16:0];
  wire [31:0] b [16:0];
  wire [31:0] c [16:0];
  wire [31:0] d [16:0];

  assign a[0] = a_in;
  assign b[0] = b_in;
  assign c[0] = c_in;
  assign d[0] = d_in;
  assign a_out = a[16];
  assign b_out = b[16];
  assign c_out = c[16];
  assign d_out = d[16];

  genvar i;
  for (i=0; i<16; i=i+1) begin
    wire [5:0] round_num = i;
    MD5RoundType4 round(a[i], b[i], c[i], d[i], k[i], shifts[i], round_num, message, a[i+1], b[i+1], c[i+1], d[i+1]);
  end
endmodule

module MD5Rounds33To48
(
  input wire [31:0] a_in,
  input wire [31:0] b_in,
  input wire [31:0] c_in,
  input wire [31:0] d_in,
  input wire [511:0] message,

  output wire [31:0] a_out,
  output wire [31:0] b_out,
  output wire [31:0] c_out,
  output wire [31:0] d_out
);
  reg [4:0] shifts [15:0];
  initial begin
    shifts[0] = 4;
    shifts[1] = 11;
    shifts[2] = 16;
    shifts[3] = 23;
    shifts[4] = 4;
    shifts[5] = 11;
    shifts[6] = 16;
    shifts[7] = 23;
    shifts[8] = 4;
    shifts[9] = 11;
    shifts[10] = 16;
    shifts[11] = 23;
    shifts[12] = 4;
    shifts[13] = 11;
    shifts[14] = 16;
    shifts[15] = 23;
  end
  reg [31:0] k [15:0];
  initial begin
    k[0] = 32'hfffa3942;
    k[1] = 32'h8771f681;
    k[2] = 32'h6d9d6122;
    k[3] = 32'hfde5380c;
    k[4] = 32'ha4beea44;
    k[5] = 32'h4bdecfa9;
    k[6] = 32'hf6bb4b60;
    k[7] = 32'hbebfbc70;
    k[8] = 32'h289b7ec6;
    k[9] = 32'heaa127fa;
    k[10] = 32'hd4ef3085;
    k[11] = 32'h04881d05;
    k[12] = 32'hd9d4d039;
    k[13] = 32'he6db99e5;
    k[14] = 32'h1fa27cf8;
    k[15] = 32'hc4ac5665;
  end
  wire [31:0] a [16:0];
  wire [31:0] b [16:0];
  wire [31:0] c [16:0];
  wire [31:0] d [16:0];

  assign a[0] = a_in;
  assign b[0] = b_in;
  assign c[0] = c_in;
  assign d[0] = d_in;
  assign a_out = a[16];
  assign b_out = b[16];
  assign c_out = c[16];
  assign d_out = d[16];

  genvar i;
  for (i=0; i<16; i=i+1) begin
    wire [5:0] round_num = i;
    MD5RoundType3 round(a[i], b[i], c[i], d[i], k[i], shifts[i], round_num, message, a[i+1], b[i+1], c[i+1], d[i+1]);
  end
endmodule

module MD5Rounds17To32
(
  input wire [31:0] a_in,
  input wire [31:0] b_in,
  input wire [31:0] c_in,
  input wire [31:0] d_in,
  input wire [511:0] message,

  output wire [31:0] a_out,
  output wire [31:0] b_out,
  output wire [31:0] c_out,
  output wire [31:0] d_out
);
  reg [4:0] shifts [15:0];
  initial begin
    shifts[0] = 5;
    shifts[1] = 9;
    shifts[2] = 14;
    shifts[3] = 20;
    shifts[4] = 5;
    shifts[5] = 9;
    shifts[6] = 14;
    shifts[7] = 20;
    shifts[8] = 5;
    shifts[9] = 9;
    shifts[10] = 14;
    shifts[11] = 20;
    shifts[12] = 5;
    shifts[13] = 9;
    shifts[14] = 14;
    shifts[15] = 20;
  end
  reg [31:0] k [15:0];
  initial begin
    k[0] = 32'hf61e2562;
    k[1] = 32'hc040b340;
    k[2] = 32'h265e5a51;
    k[3] = 32'he9b6c7aa;
    k[4] = 32'hd62f105d;
    k[5] = 32'h02441453;
    k[6] = 32'hd8a1e681;
    k[7] = 32'he7d3fbc8;
    k[8] = 32'h21e1cde6;
    k[9] = 32'hc33707d6;
    k[10] = 32'hf4d50d87;
    k[11] = 32'h455a14ed;
    k[12] = 32'ha9e3e905;
    k[13] = 32'hfcefa3f8;
    k[14] = 32'h676f02d9;
    k[15] = 32'h8d2a4c8a;
  end
  wire [31:0] a [16:0];
  wire [31:0] b [16:0];
  wire [31:0] c [16:0];
  wire [31:0] d [16:0];

  assign a[0] = a_in;
  assign b[0] = b_in;
  assign c[0] = c_in;
  assign d[0] = d_in;
  assign a_out = a[16];
  assign b_out = b[16];
  assign c_out = c[16];
  assign d_out = d[16];

  genvar i;
  for (i=0; i<16; i=i+1) begin
    wire [5:0] round_num = i;
    MD5RoundType2 round(a[i], b[i], c[i], d[i], k[i], shifts[i], round_num, message, a[i+1], b[i+1], c[i+1], d[i+1]);
  end
endmodule

module MD5Rounds1To16
(
  input wire [31:0] a_in,
  input wire [31:0] b_in,
  input wire [31:0] c_in,
  input wire [31:0] d_in,
  input wire [511:0] message,

  output wire [31:0] a_out,
  output wire [31:0] b_out,
  output wire [31:0] c_out,
  output wire [31:0] d_out
);
  reg [4:0] shifts [15:0];
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
  end
  reg [31:0] k [15:0];
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
  end
  wire [31:0] a [16:0];
  wire [31:0] b [16:0];
  wire [31:0] c [16:0];
  wire [31:0] d [16:0];

  assign a[0] = a_in;
  assign b[0] = b_in;
  assign c[0] = c_in;
  assign d[0] = d_in;
  assign a_out = a[16];
  assign b_out = b[16];
  assign c_out = c[16];
  assign d_out = d[16];

  genvar i;
  for (i=0; i<16; i=i+1) begin
    wire [5:0] round_num = i;
    MD5RoundType1 round(a[i], b[i], c[i], d[i], k[i], shifts[i], round_num, message, a[i+1], b[i+1], c[i+1], d[i+1]);
  end
endmodule

module MD5RoundType4
(
  input wire [31:0] a_in,
  input wire [31:0] b_in,
  input wire [31:0] c_in,
  input wire [31:0] d_in,
  input wire [31:0] k_in,
  input wire [4:0] shift_amount,
  input wire [5:0] round_num,
  input wire [511:0] message,

  output wire [31:0] a_out,
  output wire [31:0] b_out,
  output wire [31:0] c_out,
  output wire [31:0] d_out
);
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

  assign a_out = d_in;
  leftrotate lr(.in(f_two), .shift_amount(shift_amount), .out(b_partial));
  assign b_out = b_in + b_partial;
  assign c_out = b_in;
  assign d_out = c_in;
endmodule

module MD5RoundType3
(
  input wire [31:0] a_in,
  input wire [31:0] b_in,
  input wire [31:0] c_in,
  input wire [31:0] d_in,
  input wire [31:0] k_in,
  input wire [4:0] shift_amount,
  input wire [5:0] round_num,
  input wire [511:0] message,

  output wire [31:0] a_out,
  output wire [31:0] b_out,
  output wire [31:0] c_out,
  output wire [31:0] d_out
);
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

  assign a_out = d_in;
  leftrotate lr(.in(f_two), .shift_amount(shift_amount), .out(b_partial));
  assign b_out = b_in + b_partial;
  assign c_out = b_in;
  assign d_out = c_in;
endmodule

module MD5RoundType2
(
  input wire [31:0] a_in,
  input wire [31:0] b_in,
  input wire [31:0] c_in,
  input wire [31:0] d_in,
  input wire [31:0] k_in,
  input wire [4:0] shift_amount,
  input wire [5:0] round_num,
  input wire [511:0] message,

  output wire [31:0] a_out,
  output wire [31:0] b_out,
  output wire [31:0] c_out,
  output wire [31:0] d_out
);
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

  assign a_out = d_in;
  leftrotate lr(.in(f_two), .shift_amount(shift_amount), .out(b_partial));
  assign b_out = b_in + b_partial;
  assign c_out = b_in;
  assign d_out = c_in;
endmodule

module MD5RoundType1
(
  input wire [31:0] a_in,
  input wire [31:0] b_in,
  input wire [31:0] c_in,
  input wire [31:0] d_in,
  input wire [31:0] k_in,
  input wire [4:0] shift_amount,
  input wire [5:0] round_num,
  input wire [511:0] message,

  output wire [31:0] a_out,
  output wire [31:0] b_out,
  output wire [31:0] c_out,
  output wire [31:0] d_out
);
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

  assign a_out = d_in;
  leftrotate lr(.in(f_two), .shift_amount(shift_amount), .out(b_partial));
  assign b_out = b_in + b_partial;
  assign c_out = b_in;
  assign d_out = c_in;
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