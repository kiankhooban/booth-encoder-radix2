module tbm;

  logic zero, two, negation;
  logic [7:0] A;
  logic [8:0] p_product;

  mux dut (.zero(zero), .negation(negation), .two(two), .p_product(p_product), .A(A));


  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tbm);

    A = 8'd4;
       zero = 1;  negation = 0;  two = 0;  #10;
       zero = 0;  negation = 0;  two = 0;  #10;
       zero = 0;  negation = 1;  two = 0;  #10;
       zero = 0;  negation = 0;  two = 1;  #10;
       zero = 0;  negation = 1;  two = 1;  #10;
       zero = 1;  negation = 1;  two = 1;  #10;


        $finish;
  end
endmodule
