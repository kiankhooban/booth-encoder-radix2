module tb_multiplier;
  logic [7:0] A, B;
  logic [15:0] product;

  booth_multiplier dut (.A(A), .B(B), .product(product));

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_multiplier);

    // 0 * anything = 0
    A = 8'd0;   B = 8'd7;   #10;

    // identity
    A = 8'd1;   B = 8'd1;   #10;

    // small positive values
    A = 8'd3;   B = 8'd4;   #10;   // 12
    A = 8'd7;   B = 8'd7;   #10;   // 49
    A = 8'd12;  B = 8'd10;  #10;   // 120

    // power-of-two operands (exercises the two=1 path)
    A = 8'd4;   B = 8'd4;   #10;   // 16
    A = 8'd8;   B = 8'd8;   #10;   // 64

    // larger values
    A = 8'd15;  B = 8'd15;  #10;   // 225
    A = 8'd100; B = 8'd2;   #10;   // 200
    A = 8'd127; B = 8'd1;   #10;   // 127

    // negative A in two's complement (-1 * 2 = -2 = 16'hFFFE)
    A = 8'hFF;  B = 8'd2;   #10;

    // negative B (-1 * 4 = -4 = 16'hFFFC)
    A = 8'd4;   B = 8'hFF;  #10;

    // both negative (-2 * -3 = 6)
    A = 8'hFE;  B = 8'hFD;  #10;

    // max positive * max positive (127 * 127 = 16129)
    A = 8'd127; B = 8'd127; #10;

    // min * min (-128 * -128 = 16384 = 16'h4000)
    A = 8'h80;  B = 8'h80;  #10;

    $finish;
  end
endmodule
