// upset_tb.v -- robustez de la configuracion latcheada frente a un cambio espurio de estado (SEU, caida de VDD
// que no llega al umbral del POR, ESD). Se fuerza el estado interno de los latches CFG y se mira RESET_OUT.
`timescale 1ns/1ps
module wd_oscillater (output CLK);       assign CLK = tb.clk;             endmodule
module wd_por        (output POR_RAW_N); assign POR_RAW_N = tb.por_raw_n; endmodule
module tb;
  reg clk = 0, por_raw_n = 0, S1 = 0, S0 = 0, WDI = 0;
  wire RESET_OUT;
  wd_watchdog dut (.SET1(S1), .SET0(S0), .WDI_IN(WDI), .RESET_OUT(RESET_OUT));
  localparam real T = 97656.25, S = 1e9;      // ns
  always #(T/2) clk = ~clk;
  integer nres = 0; real tres [0:99];
  always @(posedge RESET_OUT) begin if (nres < 100) tres[nres] = $realtime/S; nres = nres + 1; end
  reg kick_on = 0; real kper = 0.5e9;
  always begin wait (kick_on); #(kper); if (kick_on) begin WDI = 1; #(2e6); WDI = 0; end end
  task upset(input c1, input c0); begin dut.x5.x1.x2.st = c1; dut.x5.x1.x1.st = c0; end endtask
  integer i, n0, fails = 0;
  initial begin
    if ($test$plusargs("B")) begin
      // B: SET = 10 (10 s), firmware sano patea cada 5 s; a t = 20 s un upset pone CFG = 01 (0,1 s)
      S1 = 1; S0 = 0; #(1e6); por_raw_n = 1; kper = 5e9; kick_on = 1;
      #(20e9 - $realtime); n0 = nres; upset(0, 1);
      $display("B: t=20 s upset CFG 10 -> 01 (CFG=%b%b)", dut.x5.x1.CFG1, dut.x5.x1.CFG0);
      #(100e9);
      $display("B: resets en 20-120 s con firmware sano = %0d (CFG final=%b%b)", nres - n0, dut.x5.x1.CFG1, dut.x5.x1.CFG0);
      for (i = n0; i < nres && i < n0 + 6; i = i + 1) $display("   reset %0d en t = %0.3f s", i - n0 + 1, tres[i]);
      if (nres - n0 <= 1) $display("VEREDICTO B: PASS (a lo sumo un reset espurio y se autocorrige)");
      else $display("VEREDICTO B: FAIL (lazo de resets con firmware sano)");
    end else begin
      // A: SET = 00 (1 s); patea cada 0,5 s; a t = 15 s un upset pone CFG = 11; el firmware se cuelga a t = 16 s
      S1 = 0; S0 = 0; #(1e6); por_raw_n = 1; kper = 0.5e9; kick_on = 1;
      #(15e9 - $realtime); n0 = nres; upset(1, 1);
      $display("A: t=15 s upset CFG 00 -> 11 (CFG=%b%b, ACTIVE=%b)", dut.x5.x1.CFG1, dut.x5.x1.CFG0, dut.ACTIVE);
      #(1e9); kick_on = 0; $display("A: t=16 s el firmware se cuelga (sin WDI)");
      #(30e9);
      $display("A: resets en 16-46 s con el firmware colgado = %0d (CFG final=%b%b)", nres - n0, dut.x5.x1.CFG1, dut.x5.x1.CFG0);
      for (i = n0; i < nres && i < n0 + 4; i = i + 1) $display("   reset %0d en t = %0.3f s", i - n0 + 1, tres[i]);
      if (nres - n0 >= 1 && tres[n0] < 16 + 10.5) $display("VEREDICTO A: PASS (el watchdog sigue vivo)");
      else $display("VEREDICTO A: FAIL (watchdog silenciado hasta un ciclo de alimentacion)");
    end
    $finish;
  end
endmodule
