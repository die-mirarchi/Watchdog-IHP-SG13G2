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

  integer fd, nk, N, cfg;
  reg [8*40:1] fn;
  always @(posedge clk) if (fd) $fdisplay(fd, "%0.6f,%0d,%b,%b,%b,%b,%b,%b", $realtime*1e-9, cnt, BOOT, ACTIVE, RESET_OUT, WDI, POR_B, EDGE);
  initial begin
    if (!$value$plusargs("SET=%d", cfg)) cfg = 1;
    N = (cfg == 0) ? 10241 : (cfg == 1) ? 1025 : 102401;
    $sformat(fn, "plot_set%0d%0d.csv", cfg / 2, cfg % 2);
    fd = $fopen(fn); $fdisplay(fd, "t,cnt,boot,active,reset_out,wdi,por_b,edge");
    S1 = cfg / 2; S0 = cfg % 2; #(T*2.3); phase; por_raw_n = 1;
    if (cfg == 3) begin
      #(T*10240.3); WDI = 1; #(T*10); WDI = 0; #(T*10240); WDI = 1; #(T*10); WDI = 0;
      #(T*300000); $fclose(fd); fd = 0; $finish;
    end
    @(posedge RESET_OUT); @(negedge RESET_OUT);                 // arranque de 10 s sin WDI -> pulso
    #(T*300.3); WDI = 1; #(T*10); WDI = 0;                      // sale de arranque
    for (nk = 0; nk < 3; nk = nk + 1) begin #(T*(0.8*N)); WDI = 1; #(T*10); WDI = 0; end   // WDI al 80 % del timeout
    @(posedge RESET_OUT); #(T*500.3); WDI = 1; #(T*10); WDI = 0; // timeout -> pulso; WDI durante el pulso
    @(negedge RESET_OUT); #(T*300.3); WDI = 1; #(T*10); WDI = 0; // sale de arranque
    #(T*(0.5*N + 1000)); $fclose(fd); fd = 0; $finish;
  end
endmodule
