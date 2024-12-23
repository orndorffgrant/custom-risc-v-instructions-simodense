module test;

  reg [31:0] a_in, b_in, c_in, d_in;
  reg [31:0] message [15:0];
  wire [31:0] a_out, b_out, c_out, d_out;

  wire [511:0] message_combined;
  assign message_combined = {
    message[15],
    message[14],
    message[13],
    message[12],
    message[11],
    message[10],
    message[9],
    message[8],
    message[7],
    message[6],
    message[5],
    message[4],
    message[3],
    message[2],
    message[1],
    message[0]
  };
  
  MD5Rounds17To32 UUT(
    .a_in(a_in),
    .b_in(b_in),
    .c_in(c_in),
    .d_in(d_in),
    .message(message_combined),
    .a_out(a_out),
    .b_out(b_out),
    .c_out(c_out),
    .d_out(d_out)
  );
  
  initial begin
    $dumpfile("md5rounds17to32.vcd");
    $dumpvars(1, UUT);
    
    a_in = 32'h67452301;
    b_in = 32'hefcdab89;
    c_in = 32'h98badcfe;
    d_in = 32'h10325476;
    message[0] = 32'h6c6c6548;
    message[1] = 32'h4e45206f;
    message[2] = 32'h30384d50;
    message[3] = 32'h54202138;
    message[4] = 32'h20736968;
    message[5] = 32'h6d207369;
    message[6] = 32'h444d2079;
    message[7] = 32'h6d692035;
    message[8] = 32'h6d656c70;
    message[9] = 32'h61746e65;
    message[10] = 32'h6e6f6974;
    message[11] = 32'h206e6920;
    message[12] = 32'h69726576;
    message[13] = 32'h80676f6c;
    message[14] = 32'h000001b8;
    message[15] = 32'h00000000;

    #1;

    $finish;
  end
  
  initial begin
    $monitor(
      "a_out: %0h, b_out: %0h, c_out: %0h, d_out: %0h",
      a_out,
      b_out,
      c_out,
      d_out
    );
  end

endmodule
