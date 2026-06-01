module tb;
    logic b_prev, b_curr, b_next;
    logic negation, two, zero;

  encoder dut (.b_prev(b_prev), .b_curr(b_curr), .b_next(b_next), .negation(negation), .two(two), .zero(zero));

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
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
