// Latch dllrq_1 conductual (mismo comportamiento que la celda) con estado accesible para inyectar un "upset"
module sg13g2_dllrq_1 (Q, D, GATE_N, RESET_B);
  output Q; input D, GATE_N, RESET_B;
  reg st = 1'bx;
  always @* if (!RESET_B) st = 1'b0; else if (!GATE_N) st = D;
  assign Q = st;
endmodule
