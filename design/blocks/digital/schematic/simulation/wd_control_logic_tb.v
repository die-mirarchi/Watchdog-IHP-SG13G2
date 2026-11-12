// wd_control_logic_tb.v -- verificacion logica de wd_control con el netlist exportado de xschem
// (wd_control.spice -> spice2v.py -> wd_control_net.v) y los modelos Verilog de IHP.
// Lazo cerrado con un contador ideal de 17 bits: constantes reales (T = 97,656 us):
//   arranque 102 401 T, pulso 1025 T, timeouts 10 241 / 1025 / 102 401 T (SET = 00 / 01 / 10), 11 = deshabilitado.
// Chequea WDI en el ultimo ciclo, SET cambiado en marcha, WDI justo despues del pulso, POR en marcha.
`timescale 1ns/1ps
module tb;
  reg CLK=0, POR_B=0, S0=0, S1=0, WE=0; wire RESET, ACTIVE, BOOT, CLR;
  // contador de referencia de 17 bits (ideal) en lazo cerrado con wd_control
  reg [16:0] cnt = 0;
  always @(posedge CLK or negedge POR_B) if (!POR_B) cnt <= 0; else cnt <= CLR ? 17'd0 : cnt + 1'b1;
  wire T01 = cnt[10], Q10_N = ~cnt[10], T00 = cnt[13] & cnt[11], T10 = cnt[16] & cnt[15] & cnt[12];
  supply1 HI;
  wd_control dut (.POR_B(POR_B), .SET0(S0), .CLR(CLR), .RESET(RESET), .SET1(S1), .HI(HI), .T01(T01),
                  .ACTIVE(ACTIVE), .BOOT(BOOT), .CLK(CLK), .T10(T10), .T00(T00), .Q10_N(Q10_N), .WDI_EDGE(WE));
  always #48828 CLK=~CLK;                      // T = 97,656 us (1024 T = 100 ms)
  integer nfail=0, k, ta, tr, cfg, fd, seed=11;
  task tick; begin @(posedge CLK); #100; end endtask
  task kick; begin @(negedge CLK); WE=1; @(posedge CLK); #100; @(negedge CLK); WE=0; end endtask
  task chk(input c, input [8*90:1] m); begin
    if (c!==1'b1) begin nfail=nfail+1; $display("FALLA: %0s (A=%b R=%b B=%b cnt=%0d)", m, ACTIVE, RESET, BOOT, cnt); end
    else $display("ok   : %0s", m); end endtask
  // ciclos desde ahora hasta que RESET sube (incluye el flanco que lo sube), y duracion del pulso
  task measure; begin
    ta=0; while (!RESET) begin tick; ta=ta+1; if (ta>400000) begin chk(0,"sin timeout"); disable measure; end end
    tr=0; while (RESET) begin tick; tr=tr+1; end
  end endtask
  task por(input a, input b); begin
    @(negedge CLK); POR_B=0; S1=a; S0=b; #1000; @(negedge CLK); POR_B=1; end endtask
  integer exp_n [0:3];
  initial begin exp_n[0]=10241; exp_n[1]=1025; exp_n[2]=102401; exp_n[3]=0; end
  initial begin #400000000000; $display("VEREDICTO: FAIL (timeout del TB)"); $finish; end
  initial begin
    for (cfg=0; cfg<3; cfg=cfg+1) begin
      por(cfg[1], cfg[0]); $display("--- SET=%b%b", cfg[1], cfg[0]);
      chk(ACTIVE && BOOT && !RESET, "tras POR: supervisando en modo arranque, sin intervencion");
      measure; chk(ta==102401-1 || ta==102401, "1er timeout sin WDI = 10,24 s (arranque)");
      $display("      arranque=%0d T, pulso=%0d T", ta, tr);
      chk(tr==1025, "pulso de reset 1025 T (100,1 ms)");
      chk(ACTIVE && BOOT, "tras el pulso vuelve a modo arranque");
      measure; chk(ta==102401 && tr==1025, "2do ciclo sin WDI: 102401 + 1025 T (cuenta borrada al final del pulso)");
      repeat(50) tick; kick; chk(!BOOT && cnt==0, "1er WDI: sale de arranque y borra");
      measure; chk(ta==exp_n[cfg], "timeout normal segun SET (desde el flanco del WDI)");
      $display("      normal=%0d T", ta);
      // WDI en el ultimo ciclo valido del modo normal
      repeat(100) tick; kick;
      while (cnt !== exp_n[cfg]-1) tick; kick; chk(ACTIVE && !RESET && cnt==0, "WDI en el ultimo ciclo es valido");
      // cambiar los pines en marcha no cambia nada (latcheados en POR)
      @(negedge CLK); S1=1; S0=1; measure; chk(ta+1==exp_n[cfg], "SET cambiado en marcha: sin efecto");
      // WDI durante el pulso: ignorado y vuelve a arranque
      chk(BOOT, "tras el pulso: modo arranque"); kick; chk(!BOOT && !RESET, "WDI justo despues del pulso: sale de arranque");
    end
    por(1,1); $display("--- SET=11");
    repeat(300000) tick; chk(!ACTIVE && !RESET, "SET=11: deshabilitado (300 000 T sin reset)");
    // POR en medio del modo normal -> vuelve a arranque
    por(0,0); repeat(10) tick; kick; repeat(5000) tick; chk(!BOOT, "modo normal");
    por(0,0); chk(BOOT && ACTIVE, "POR -> modo arranque otra vez");
    if (nfail==0) $display("VEREDICTO: PASS"); else $display("VEREDICTO: FAIL (%0d)", nfail);
    $finish;
  end
endmodule
