// wd_watchdog_logic_tb.v -- verificacion logica del TOP (wd_watchdog sin pads) con el netlist exportado
// de xschem (wd_watchdog.spice -> spice2v.py --skip <bloques analogicos> -> wd_watchdog_net.v) y los
// modelos Verilog de IHP. Oscilador y POR: modelos conductuales (T = 97,656 us; POR_RAW_N desde el TB).
// 1) Chequeos dirigidos en el pin (RESET_OUT) con constantes reales.
// 2) Comparacion ciclo a ciclo contra un modelo de referencia escrito desde las ecuaciones de diseno
//    (estimulo aleatorio de WDI, POR y SET).
`timescale 1ns/1ps
module wd_oscillater (output CLK);       assign CLK = tb.clk;             endmodule
module wd_por        (output POR_RAW_N); assign POR_RAW_N = tb.por_raw_n; endmodule

module tb;
  reg clk = 0, por_raw_n = 0, S1 = 0, S0 = 0, WDI = 0;
  wire RESET_OUT;
  wd_watchdog dut (.SET1(S1), .SET0(S0), .WDI_IN(WDI), .RESET_OUT(RESET_OUT));
  localparam real T = 97656.25;               // ns: 1024 T = 100 ms
  always #(T/2) clk = ~clk;

  // ---------------- observacion interna ----------------
  wire POR_B = dut.POR_B, BOOT = dut.BOOT, ACTIVE = dut.ACTIVE, RESET = dut.x5.RESET, EDGE = dut.net1;
  wire [16:0] cnt = {dut.x5.x2.Q16, dut.x5.x2.Q15, dut.x5.x2.Q14, dut.x5.x2.Q13, dut.x5.x2.Q12, dut.x5.x2.Q11,
                     dut.x5.x2.T01, dut.x5.x2.Q9, dut.x5.x2.Q8, dut.x5.x2.Q7, dut.x5.x2.Q6, dut.x5.x2.Q5,
                     dut.x5.x2.Q4, dut.x5.x2.Q3, dut.x5.x2.Q2, dut.x5.x2.Q1, dut.x5.x2.Q0};

  // ---------------- modelo de referencia (ecuaciones de diseno) ----------------
  reg g_p1 = 0, g_porb = 0, g_meta = 0, g_sync = 0, g_hist = 0, g_rs = 0, g_nb = 0, g_c0 = 0, g_c1 = 0;
  reg [16:0] g_cnt = 0;
  always @(posedge clk or negedge por_raw_n)
    if (!por_raw_n) begin g_p1 <= 0; g_porb <= 0; end else begin g_p1 <= 1; g_porb <= g_p1; end
  always @(g_porb or S0 or S1) if (!g_porb) begin g_c0 = S0; g_c1 = S1; end   // dllrq: transparente con POR_B = 0
  wire g_edge = g_sync & ~g_hist;
  wire g_dis  = g_c0 & g_c1;
  wire g_act  = ~(g_dis | g_rs);
  wire g_t01  = g_cnt[10], g_t00 = g_cnt[13] & g_cnt[11], g_t10 = g_cnt[16] & g_cnt[15] & g_cnt[12];
  wire g_ton  = ({g_c1, g_c0} == 2'd0) ? g_t00 : ({g_c1, g_c0} == 2'd1) ? g_t01 : ({g_c1, g_c0} == 2'd2) ? g_t10 : 1'b0;
  wire g_to   = g_nb ? g_ton : g_t10;
  wire g_hit  = g_act & g_to & ~g_edge;
  wire g_clr  = g_rs ? g_t01 : (g_dis | g_edge | g_hit);
  always @(posedge clk or negedge g_porb)
    if (!g_porb) begin g_meta <= 0; g_sync <= 0; g_hist <= 0; g_rs <= 0; g_nb <= 0; g_cnt <= 0; end
    else begin
      g_meta <= WDI; g_sync <= g_meta; g_hist <= g_sync;
      g_rs  <= g_hit | (g_rs & ~g_t01);
      g_nb  <= (g_nb | (g_edge & g_act)) & ~g_rs;
      g_cnt <= g_clr ? 17'd0 : g_cnt + 1'b1;
    end
  wire g_out = g_porb & g_rs;

  integer nmis = 0, ncmp = 0; reg cmp_on = 0;
  always @(negedge clk) if (cmp_on) begin
    ncmp = ncmp + 1;
    if (RESET_OUT !== g_out || BOOT !== ~g_nb || ACTIVE !== g_act || cnt !== g_cnt || POR_B !== g_porb) begin
      nmis = nmis + 1;
      if (nmis <= 5) $display("  DIFERENCIA t=%0.6f s: RESET_OUT=%b/%b BOOT=%b/%b ACTIVE=%b/%b cnt=%0d/%0d POR_B=%b/%b",
        $realtime*1e-9, RESET_OUT, g_out, BOOT, ~g_nb, ACTIVE, g_act, cnt, g_cnt, POR_B, g_porb);
    end
  end

  // ---------------- utilidades ----------------
  integer nfail = 0, seed = 7, n, k, i;
  real t0, t1;
  task chk(input c, input [8*96:1] m); begin
    if (c !== 1'b1) begin nfail = nfail + 1; $display("FALLA: %0s  (RESET_OUT=%b BOOT=%b ACTIVE=%b cnt=%0d t=%0.4f s)", m, RESET_OUT, BOOT, ACTIVE, cnt, $realtime*1e-9); end
    else $display("ok   : %0s", m); end endtask
  // espera a una fase aleatoria lejos de los flancos (5..95 % del periodo)
  task phase; begin @(posedge clk); #(T*(0.05 + 0.9*($urandom(seed) % 1000)/1000.0)); end endtask
  task wait_T(input integer m); begin repeat (m) @(posedge clk); end endtask
  // pulso en WDI_IN de ancho w (en T) a fase aleatoria
  task kick(input real w); begin phase; WDI = 1; t0 = $realtime; #(w*T); WDI = 0; end endtask
  // POR: VDD "cae" (POR_RAW_N = 0) y vuelve con los straps SET dados
  task por(input a, input b); begin
    phase; por_raw_n = 0; S1 = a; S0 = b; #(3*T); phase; por_raw_n = 1; t0 = $realtime; end endtask
  // T desde t0 hasta que RESET_OUT sube; y ancho del pulso
  real ta, tw;
  task measure; begin
    @(posedge RESET_OUT or posedge por_raw_n); t1 = $realtime; ta = (t1 - t0)/T;
    @(negedge RESET_OUT); tw = ($realtime - t1)/T;
  end endtask

  integer exp_n [0:2];
  initial begin exp_n[0] = 10241; exp_n[1] = 1025; exp_n[2] = 102401; end
  integer cfg, edges, kmax;
  real tp;
  initial begin
    $display("=== wd_watchdog: verificacion logica del top (T = %0.3f us) ===", T/1000);
    // ---- 1) encendido ----
    #(T*2.3); chk(RESET_OUT === 1'b0, "durante el POR: RESET_OUT = 0");
    phase; por_raw_n = 1; t0 = $realtime; edges = 0;
    while (POR_B !== 1'b1) begin @(posedge clk); #1; edges = edges + 1; end
    chk(edges == 2, "POR_B sube en el 2.o flanco de CLK tras liberar POR_RAW_N");
    cmp_on = 1;
    #1; chk(BOOT === 1 && ACTIVE === 1 && RESET_OUT === 0, "tras el POR: modo arranque, supervisando, sin reset");
    for (cfg = 0; cfg < 3; cfg = cfg + 1) begin
      por(cfg[1], cfg[0]); $display("--- SET1 SET0 = %b%b", cfg[1], cfg[0]);
      @(posedge POR_B); t0 = $realtime;
      measure; $display("      arranque: %0.2f T = %0.4f s ; pulso %0.2f T = %0.2f ms", ta, ta*T*1e-9, tw, tw*T*1e-6);
      chk(ta > 102400.9 && ta < 102401.1, "1er timeout sin WDI (arranque) = 102 401 T = 10,0 s");
      chk(tw > 1024.9 && tw < 1025.1, "pulso RESET_OUT = 1025 T = 100,1 ms");
      #1; chk(BOOT === 1 && ACTIVE === 1, "tras el pulso: vuelve a modo arranque");
      // primer WDI: sale de arranque
      wait_T(30); kick(10.24);        // WDI de 1 ms
      wait_T(4); chk(BOOT === 0, "WDI de 1 ms: sale del modo arranque en <= 3 T");
      measure; $display("      normal (desde el flanco de WDI_IN): %0.2f T = %0.4f s", ta, ta*T*1e-9);
      chk(ta > exp_n[cfg] + 1 && ta < exp_n[cfg] + 3, "timeout normal segun SET (00 = 1 s, 01 = 0,1 s, 10 = 10 s)");
      // WDI periodico al 90 % del timeout: nunca resetea
      wait_T(10); kick(10.24); n = 0;
      for (k = 0; k < 8; k = k + 1) begin
        tp = $realtime; while (($realtime - tp) < 0.9*exp_n[cfg]*T) begin @(posedge clk); if (RESET_OUT) n = n + 1; end
        #(T*0.37); WDI = 1; #(10.24*T); WDI = 0;
      end
      chk(n == 0, "WDI cada 0,9 timeout (8 veces): sin reset");
      // WDI trabado en alto: un solo flanco -> igual vence
      wait_T(5); phase; WDI = 1; t0 = $realtime; measure; WDI = 0;
      chk(ta > exp_n[cfg] + 1 && ta < exp_n[cfg] + 3, "WDI trabado en 1: vence igual (detecta flancos, no nivel)");
      // pulsos minimos de 2 T
      wait_T(20); kick(2.0); wait_T(4); chk(BOOT === 0, "pulso WDI de 2 T (0,2 ms) reconocido");
      // cambiar SET en marcha no tiene efecto (latcheado en el POR)
      #(T*0.4); S1 = ~S1; S0 = ~S0; kick(10.24); measure;
      chk(ta > exp_n[cfg] + 1 && ta < exp_n[cfg] + 3, "SET cambiado en marcha: sin efecto");
      // WDI durante el pulso: ignorado
      t1 = $realtime; @(posedge RESET_OUT); #(T*100.4); WDI = 1; #(T*10); WDI = 0;
      @(negedge RESET_OUT); #1; chk(BOOT === 1, "WDI durante el pulso: ignorado (vuelve a arranque)");
      S1 = cfg[1]; S0 = cfg[0];
    end
    // ---- SET = 11 ----
    por(1, 1); $display("--- SET1 SET0 = 11");
    n = 0; repeat (300000) begin @(posedge clk); if (RESET_OUT) n = n + 1; end
    chk(n == 0 && ACTIVE === 0, "SET = 11: deshabilitado (300 000 T = 29 s sin reset, ACTIVE = 0)");
    // ---- POR durante el pulso ----
    por(0, 1); @(posedge POR_B); wait_T(5); kick(10.24); @(posedge RESET_OUT); #(T*300);
    phase; por_raw_n = 0; #2; chk(RESET_OUT === 0, "POR durante el pulso: RESET_OUT baja asincronicamente (< 2 ns)");
    #(3*T); phase; por_raw_n = 1; @(posedge POR_B); #1; chk(BOOT === 1 && RESET_OUT === 0, "tras el POR: arranque");
    // ---- 2) aleatorio contra el modelo de referencia ----
    $display("--- aleatorio: WDI/POR/SET contra el modelo de referencia");
    for (i = 0; i < 1500; i = i + 1) begin
      k = $urandom(seed) % 100;
      if (k < 2) por($urandom(seed) % 2, $urandom(seed) % 2);
      else if (k < 6) begin S1 = $urandom(seed) % 2; S0 = $urandom(seed) % 2; end
      kmax = (k < 50) ? 1100 : (k < 80) ? 11000 : 3000;  // intervalos alrededor de los timeouts de 0,1 y 1 s
      wait_T($urandom(seed) % kmax);
      kick(0.5 + ($urandom(seed) % 400)/10.0);
    end
    $display("      ciclos comparados: %0d, diferencias: %0d", ncmp, nmis);
    chk(nmis == 0 && ncmp > 1000000, "netlist = modelo de referencia ciclo a ciclo (RESET_OUT, BOOT, ACTIVE, cuenta, POR_B)");
    if (nfail == 0) $display("VEREDICTO: PASS"); else $display("VEREDICTO: FAIL (%0d)", nfail);
    $finish;
  end
  initial begin #(T*30000000.0); $display("VEREDICTO: FAIL (timeout del TB)"); $finish; end
endmodule
