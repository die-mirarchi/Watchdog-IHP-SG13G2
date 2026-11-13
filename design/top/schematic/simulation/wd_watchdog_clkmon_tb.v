// wd_watchdog_clkmon_tb.v -- integracion de wd_clkmon en el top (Icarus, netlist de xschem, wd_clkmon conductual).
// Casos: (1) el oscilador no arranca; (2) CLK se detiene en 0 y en 1 con el watchdog supervisando; (3) recuperacion.
`timescale 1ns/1ps
module wd_oscillater (output CLK);       assign CLK = tb.clk;             endmodule
module wd_por        (output POR_RAW_N); assign POR_RAW_N = tb.por_raw_n; endmodule
module tb;
  reg clk = 0, run = 0, por_raw_n = 0, S1 = 0, S0 = 0, WDI = 0;
  wire RESET_OUT;
  wd_watchdog dut (.SET1(S1), .SET0(S0), .WDI_IN(WDI), .RESET_OUT(RESET_OUT));
  localparam real T = 97656.25;
  always #(T/2) if (run) clk = ~clk;
  integer nf = 0; real t0, tr;
  task chk(input c, input [8*90:1] m); begin if (c !== 1'b1) begin nf = nf + 1; $display("FALLA: %0s (RESET_OUT=%b t=%0.3f ms)", m, RESET_OUT, $realtime*1e-6); end else $display("ok   : %0s", m); end endtask
  task kick; begin WDI = 1; #(10*T); WDI = 0; end endtask
  initial begin
    // (1) el oscilador no arranca: POR liberado, sin CLK
    #(0.1e6); por_raw_n = 1; #(5e6);
    chk(dut.POR_B === 1'b0, "sin CLK: POR_B no se libera (wd_reset_sync espera 34 flancos)");
    chk(RESET_OUT === 1'b1, "sin CLK: RESET_OUT = 1 (el uC queda en reset en vez de correr sin supervision)");
    // arranca el reloj: CLK_LOST cae en el primer flanco y el watchdog arranca normal
    run = 1; @(posedge clk); #1; chk(RESET_OUT === 1'b0, "el reloj arranca: RESET_OUT vuelve a 0 en el primer flanco");
    @(posedge dut.POR_B); chk(1'b1, "POR_B se libera con el reloj");
    // (2) supervisando (SET = 00, WDI cada 0,5 s); CLK se detiene en 0 durante 20 ms
    repeat (3) begin #(0.5e9); kick; end
    @(negedge clk); run = 0; t0 = $realtime;
    @(posedge RESET_OUT); tr = $realtime - t0;
    $display("      CLK detenido en 0: RESET_OUT sube %0.3f ms despues del ultimo flanco", tr*1e-6);
    chk(tr > 0.3e6 && tr < 2.0e6, "CLK detenido en 0: RESET_OUT = 1 en 0,3-2 ms");
    #(20e6); chk(RESET_OUT === 1'b1, "sigue en reset mientras falta el reloj (20 ms)");
    run = 1; @(clk); #1; chk(RESET_OUT === 1'b0, "CLK vuelve: RESET_OUT = 0 en el primer flanco");
    // la logica no perdio el estado: sigue en modo normal y un WDI la mantiene
    kick; #(0.5e9); chk(RESET_OUT === 1'b0 && dut.BOOT === 1'b0, "despues de la falla: modo normal, sin reset espurio");
    // (3) CLK detenido en 1
    @(posedge clk); run = 0; t0 = $realtime;
    @(posedge RESET_OUT); tr = $realtime - t0;
    $display("      CLK detenido en 1: RESET_OUT sube %0.3f ms despues del ultimo flanco", tr*1e-6);
    chk(tr > 0.3e6 && tr < 2.0e6, "CLK detenido en 1: RESET_OUT = 1 en 0,3-2 ms");
    run = 1; @(clk); #1; chk(RESET_OUT === 1'b0, "CLK vuelve: RESET_OUT = 0");
    if (nf == 0) $display("VEREDICTO: PASS"); else $display("VEREDICTO: FAIL (%0d)", nf);
    $finish;
  end
  initial begin #(10e9); $display("VEREDICTO: FAIL (timeout del TB)"); $finish; end
endmodule
