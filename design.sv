module encoder(
  input logic b_prev, b_curr, b_next,
  output logic negation, two, zero
);

  always_comb
    begin
      case ({b_next, b_curr, b_prev})
        3'b000: begin zero=1; two=0; negation=0; end
        3'b001: begin zero=0; two=0; negation=0; end
        3'b010: begin zero=0; two=0; negation=0; end
        3'b011: begin zero=0; two=1; negation=0; end
        3'b100: begin zero=0; two=1; negation=1; end
        3'b101: begin zero=0; two=0; negation=1; end
        3'b110: begin zero=0; two=0; negation=1; end
        3'b111: begin zero=1; two=0; negation=0; end
      endcase
    end
endmodule



module mux(
  input logic negation, two, zero,
  input logic [7:0] A,
  output logic [8:0] p_product

);

  always_comb
    begin
      if (zero) begin p_product = 0; end
      else begin case({negation, two})
        2'b00: begin p_product = A;end
        2'b01: begin p_product = {A,1'b0};end
        2'b10: begin p_product = ~A+1 ;end
        2'b11: begin p_product = ~{A, 1'b0}+1;end
      endcase
    end
    end
endmodule


module booth_unit(
  input  logic [7:0] A,
  input  logic b_prev, b_curr, b_next,
  output logic [8:0] p_product
);

  logic zero, two, negation;

  encoder enc (.b_prev(b_prev), .b_curr(b_curr), .b_next(b_next),
                 .zero(zero), .two(two), .negation(negation));

  mux m (.zero(zero), .two(two), .negation(negation),
           .A(A), .p_product(p_product));

endmodule


module booth_multiplier(
    input  logic [7:0] A, B,
    output logic [15:0] product
);
    logic [8:0] pp0, pp1, pp2, pp3;

  booth_unit u0 (.A(A), .b_prev(1'b0), .b_curr(B[0]), .b_next(B[1]), .p_product(pp0));
  booth_unit u1 (.A(A), .b_prev(B[1]), .b_curr(B[2]), .b_next(B[3]), .p_product(pp1));
  booth_unit u2 (.A(A), .b_prev(B[3]), .b_curr(B[4]), .b_next(B[5]), .p_product(pp2));
  booth_unit u3 (.A(A), .b_prev(B[5]), .b_curr(B[6]), .b_next(B[7]), .p_product(pp3));

  assign product = pp0 + {pp1, 2'b0} + {pp2, 4'b0} + {pp3, 6'b0};

endmodule
