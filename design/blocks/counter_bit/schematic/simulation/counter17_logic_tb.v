// counter17_logic_tb.v -- verificacion logica de counter17 con el netlist exportado de xschem
// (counter17.spice -> spice2v.py -> counter17_net.v) y los modelos Verilog de IHP.
// Recorre el ciclo completo de 2^17 cuentas y compara en CADA ciclo las salidas con un
// contador de referencia:
//   T01 = Q10 (cuenta >= 1024 con bit 10), T00 = Q13&Q11, T10 = Q16&Q15&Q12, Q10_N = ~Q10
// Ademas: primera subida de cada toma (1024 / 10240 / 102400), CLR sincronico con prioridad,
// POR_B asincronico y vuelta de 131071 a 0.
`timescale 1ns/1ps
module tb;
  reg CLK = 0, CLR = 0, POR_B = 0, HI = 1;
  wire T00, T10, T01, Q10_N;
  counter17 dut (.CLK(CLK), .CLR(CLR), .POR_B(POR_B), .HI(HI), .T00(T00), .T10(T10), .T01(T01), .Q10_N(Q10_N));
  always #50 CLK = ~CLK;                       // la logica no depende de f
  integer n = 0, k, nfail = 0, nerr = 0, f01 = -1, f00 = -1, f10 = -1;
  task chk(input c, input [8*80:1] m); begin
    if (c !== 1'b1) begin nfail = nfail + 1; $display("FALLA: %0s", m); end
    else $display("ok   : %0s", m); end endtask
  // compara las 4 salidas con la cuenta de referencia n (10 ns despues del flanco)
  task cmp; begin
    if (T01 !== n[10] || Q10_N !== ~n[10] || T00 !== (n[13] & n[11]) || T10 !== (n[16] & n[15] & n[12])) begin
      nerr = nerr + 1;
      if (nerr <= 5) $display("FALLA: cuenta %0d -> T00=%b T10=%b T01=%b Q10_N=%b", n, T00, T10, T01, Q10_N);
    end
  end endtask
  task tick; begin @(posedge CLK); #10; end endtask
  initial begin
    #120; @(negedge CLK); POR_B = 1; #1;
    chk(T00 === 0 && T10 === 0 && T01 === 0 && Q10_N === 1, "POR_B = 0: cuenta en 0");
    // 1) ciclo completo + 5 cuentas (vuelta a 0)
    for (k = 1; k <= 131072 + 5; k = k + 1) begin
      tick; n = k % 131072; cmp;
      if (f01 < 0 && T01 === 1) f01 = k;
      if (f00 < 0 && T00 === 1) f00 = k;
      if (f10 < 0 && T10 === 1) f10 = k;
    end
    chk(nerr == 0, "salidas = referencia en las 131 077 cuentas (incluye 131071 -> 0)");
    $display("      primera subida: T01=%0d T00=%0d T10=%0d", f01, f00, f10);
    chk(f01 == 1024,   "T01 sube por primera vez en la cuenta 1024");
    chk(f00 == 10240,  "T00 sube por primera vez en la cuenta 10240");
    chk(f10 == 102400, "T10 sube por primera vez en la cuenta 102400");
    // 2) CLR sincronico con prioridad: avanzar hasta 1030 y borrar
    while (n != 1030) begin tick; n = (n + 1) % 131072; end
    @(negedge CLK); CLR = 1; #1; chk(T01 === 1, "CLR no actua sin flanco (sincronico)");
    tick; n = 0; cmp; tick; cmp;
    chk(nerr == 0 && T01 === 0, "CLR = 1: cuenta en 0 y se mantiene (prioridad sobre el incremento)");
    @(negedge CLK); CLR = 0; for (k = 1; k <= 1500; k = k + 1) begin tick; n = k; cmp; end
    chk(nerr == 0, "tras CLR vuelve a contar desde 0");
    // 3) POR_B asincronico a mitad de ciclo con cuenta 1500 (T01 = 1)
    @(negedge CLK); #5; POR_B = 0; #1;
    chk(T01 === 0 && Q10_N === 1, "POR_B = 0 borra sin flanco de reloj");
    #200; @(negedge CLK); POR_B = 1; n = 0;
    for (k = 1; k <= 20; k = k + 1) begin tick; n = k; cmp; end
    chk(nerr == 0, "tras POR_B vuelve a contar desde 0");
    if (nfail == 0) $display("VEREDICTO: PASS"); else $display("VEREDICTO: FAIL (%0d)", nfail);
    $finish;
  end
endmodule
