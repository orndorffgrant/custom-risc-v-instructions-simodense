module test;

  reg [31:0] in;
  reg [4:0] shift_amount;
  wire [31:0] out;
  
  leftrotate UUT(
    .in(in),
    .shift_amount(shift_amount),
    .out(out)
  );
  
  initial begin
    $dumpfile("leftrotate.vcd");
    $dumpvars(1);
    
    in = 32'b11110011_10000111_01010101_00011010;
    shift_amount = 5'd1;
    #1;

    shift_amount = 5'd5;
    #1;

    shift_amount = 5'd31;
    #1;

    #1;
    $finish;
  end
  
  initial begin
    $monitor(
      "in: %0b, shift_amount: %0d, out:%0b",
      in,
      shift_amount,
      out
    );
  end

endmodule
