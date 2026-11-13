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

  integer fd, wi, tr, det; real ws [0:10]; real tlat, tedge = 0;
  always @(posedge EDGE) tedge = $realtime;
  initial begin
    ws[0]=0.1; ws[1]=0.25; ws[2]=0.5; ws[3]=0.75; ws[4]=1.0; ws[5]=1.25; ws[6]=1.5; ws[7]=1.75; ws[8]=2.0; ws[9]=2.5; ws[10]=3.0;
    fd = $fopen("wdi_ancho.csv"); $fdisplay(fd, "ancho_T,prueba,detectado,latencia_T");
    S1 = 0; S0 = 1;
    for (wi = 0; wi <= 10; wi = wi + 1) for (tr = 0; tr < 300; tr = tr + 1) begin
      phase; por_raw_n = 0; #(2*T); phase; por_raw_n = 1; @(posedge POR_B); repeat (3) @(posedge clk);
      phase; WDI = 1; t0 = $realtime; #(ws[wi]*T); WDI = 0;
      repeat (6) @(posedge clk); #1; det = (BOOT === 1'b0); tlat = (tedge > t0) ? (tedge - t0)/T : -1;
      $fdisplay(fd, "%0.3f,%0d,%0d,%0.3f", ws[wi], tr, det, tlat);
    end
    $fclose(fd); $finish;
  end
endmodule
