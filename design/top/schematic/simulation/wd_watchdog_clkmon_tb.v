// wd_watchdog_clkmon_tb.v -- wd_clkmon en el top (Icarus, netlist de xschem, wd_clkmon conductual).
// Si el reloj falla, CLK_LOST reinicia solo el watchdog (POR_RAW_N = POR_DET_N & !CLK_LOST): RESET_OUT NO se activa.
// Casos: (1) el oscilador no arranca; (2) CLK detenido en 0 y (3) en 1 supervisando; (4) CLK vuelve 1 us despues de la
// deteccion; (5) el reloj se cae durante un pulso de reset.
`timescale 1ns/1ps
module wd_oscillater (output CLK);       assign CLK = tb.clk;             endmodule
module wd_por        (output POR_RAW_N); assign POR_RAW_N = tb.por_raw_n; endmodule
module tb;
  reg clk = 0, run = 0, por_raw_n = 0, S1 = 0, S0 = 0, WDI = 0;
  wire RESET_OUT;
  wd_watchdog dut (.SET1(S1), .SET0(S0), .WDI_IN(WDI), .RESET_OUT(RESET_OUT));
  localparam real T = 97656.25;
  always #(T/2) if (run) clk = ~clk;
  integer nf = 0, nr = 0, ne; real t0, tr, tup;
  always @(posedge RESET_OUT) begin nr = nr + 1; tup = $realtime; end
  task chk(input c, input [8*100:1] m); begin if (c !== 1'b1) begin nf = nf + 1; $display("FALLA: %0s (t=%0.3f ms)", m, $realtime*1e-6); end else $display("ok   : %0s", m); end endtask
  task kick; begin WDI = 1; #(10*T); WDI = 0; end endtask
  // cuenta flancos de CLK desde que vuelve el reloj hasta POR_B
  task recover(input [8*40:1] m); begin
    ne = 0; fork begin @(posedge dut.POR_B); end begin forever begin @(posedge clk); ne = ne + 1; end end join_any disable fork;
    $display("      %0s: POR_B sube en el flanco %0d despues de volver el reloj", m, ne);
    chk(ne >= 34 && ne <= 35, "POR_B vuelve a los 34 flancos (reinicio completo del watchdog)");
    chk(dut.BOOT === 1'b1, "tras el reinicio: modo arranque");
    nr = 0; #(1e9); chk(nr == 0 && RESET_OUT === 1'b0, "1 s en arranque sin WDI: sin reset (timeout de 10 s)");
    kick; #(0.2e9); chk(dut.BOOT === 1'b0 && RESET_OUT === 1'b0, "el primer WDI lo pasa a modo normal");
  end endtask
  task stop_and_watch(input lvl, input [8*40:1] m); begin
    if (lvl) @(posedge clk); else @(negedge clk);
    run = 0; t0 = $realtime; nr = 0;
    @(negedge dut.POR_B); tr = $realtime - t0;
    $display("      %0s: POR_B baja %0.3f ms despues del ultimo flanco", m, tr*1e-6);
    chk(tr > 0.3e6 && tr < 2.0e6, "deteccion en 0,3-2 ms y reinicio asincrono del watchdog (POR_B = 0)");
    #(20e6); chk(nr == 0 && RESET_OUT === 1'b0, "20 ms sin reloj: RESET_OUT = 0 (no se resetea al uC)");
    run = 1; recover(m);
  end endtask
  initial begin
    // (1) el oscilador no arranca
    #(0.1e6); por_raw_n = 1; #(5e6);
    chk(dut.POR_B === 1'b0, "sin CLK: POR_B no se libera");
    chk(RESET_OUT === 1'b0, "sin CLK: RESET_OUT = 0");
    run = 1; recover("arranque tardio del oscilador");
    // (2) y (3) supervisando con SET = 00 (1 s)
    repeat (3) begin #(0.5e9); kick; end
    stop_and_watch(0, "CLK detenido en 0");
    repeat (3) begin #(0.5e9); kick; end
    stop_and_watch(1, "CLK detenido en 1");
    // (4) el reloj vuelve 1 us despues de la deteccion
    repeat (2) begin #(0.5e9); kick; end
    @(negedge clk); run = 0; @(negedge dut.POR_B); #(1000); run = 1;
    chk(RESET_OUT === 1'b0, "CLK vuelve 1 us despues de la deteccion: RESET_OUT = 0");
    recover("vuelta inmediata");
    // (5) el reloj se cae durante un pulso de reset (timeout de 1 s sin WDI)
    @(posedge RESET_OUT); #(30e6); run = 0; t0 = $realtime;
    @(negedge RESET_OUT); tr = $realtime - tup;
    $display("      reloj caido a los 30 ms del pulso: RESET_OUT dura %0.3f ms (se corta al reiniciarse el watchdog)", tr*1e-6);
    chk(tr > 30e6 && tr < 33e6, "pulso de reset recortado = 30 ms + deteccion");
    #(5e6); run = 1; recover("caida durante el pulso");
    if (nf == 0) $display("VEREDICTO: PASS"); else $display("VEREDICTO: FAIL (%0d)", nf);
    $finish;
  end
  initial begin #(30e9); $display("VEREDICTO: FAIL (timeout del TB)"); $finish; end
endmodule
