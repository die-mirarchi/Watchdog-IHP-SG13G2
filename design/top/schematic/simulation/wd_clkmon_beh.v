// Modelo conductual de wd_clkmon (para Icarus): CLK_LOST = 1 si CLK no cambia durante TDET; vuelve a 0 en el primer flanco.
// TDET tipico (tt/27 C) = 0,86 ms; rango verificado a nivel transistor 0,31-1,87 ms.
module wd_clkmon (CLK, CLK_LOST);
  input CLK; output reg CLK_LOST = 1'b0;
  parameter real TDET = 860000.0;   // ns
  real tlast = 0.0;
  always @(CLK) begin tlast = $realtime; CLK_LOST = 1'b0; end
  // vigilancia: cada TDET/8 compara el tiempo desde el ultimo flanco (error de deteccion <= TDET/8)
  always begin #(TDET/8.0); if ($realtime - tlast >= TDET) CLK_LOST = 1'b1; end
endmodule
