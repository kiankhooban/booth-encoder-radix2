module booth_tb;
  logic b_prev, b_curr, b_next;
  logic signed [7:0] A;
  logic signed [8:0] p_product;

  booth_unit dut (.b_prev(b_prev), .b_curr(b_curr), .b_next(b_next), .A(A), .p_product(p_product));

    initial begin
      $dumpfile("dump.vcd");
      $dumpvars(0, booth_tb);

      A = 8'd4;

      b_next = 0;  b_curr = 0;  b_prev = 0;  #10;
      b_next = 0;  b_curr = 0;  b_prev = 1;  #10;
      b_next = 0;  b_curr = 1;  b_prev = 0;  #10;
      b_next = 0;  b_curr = 1;  b_prev = 1;  #10;
      b_next = 1;  b_curr = 0;  b_prev = 0;  #10;
      b_next = 1;  b_curr = 0;  b_prev = 1;  #10;
      b_next = 1;  b_curr = 1;  b_prev = 0;  #10;
      b_next = 1;  b_curr = 1;  b_prev = 1;  #10;

        $finish;
    end
endmodule
