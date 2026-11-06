import os
W=[('A','0','400u','rampa 10 us'),('B','410u','800u','tras caida a 0.45 V'),('C','810u','2100u','rampa 1 ms')]
DIG=open(os.path.join(os.path.dirname(__file__),'dig.sp')).read()
def block(vdd=1.2,temp=27,tmax='100n',plots=True,opt='method=gear maxord=2 reltol=1e-3 gmin=1e-11',tank=None,fs=None,sig=None,dig=True):
    L=[f'.param vdd={vdd}',f'.temp {temp}',f'.option {opt}',
'** VDD: A) rampa 10 us | B) caida a 0.45 V durante 90 us (400u) | C) apagado 50 us y rampa lenta de 1 ms (860u)',
'VVDD VDD 0 PWL(0 0 10u {vdd} 400u {vdd} 405u 0.45 495u 0.45 500u {vdd} 800u {vdd} 810u 0 860u 0 1860u {vdd} 2100u {vdd})',
'VVSS VSS 0 DC 0',
'** carga del arbol de reloj: ~25 entradas de FF + cableado (la misma que en tb_wd_reset_sync).',
'CCLK CLK 0 200f',
]+([DIG] if dig else [])+[


'.control','  set num_threads=1',f'  tran 10n 2100u 0 {tmax}',
'  * d* > 0 <=> nodo en 1 (> VDD/2); con VDD < 0.3 V no se evalua',
'  let VU = 0.3',
'  let dR = (v(por_raw_n)-0.5*v(vdd))*(v(vdd) gt VU) - 0.01*(v(vdd) le VU)',
'  let dB = (v(por_b)-0.5*v(vdd))*(v(vdd) gt VU) - 0.01*(v(vdd) le VU)',
'  let dP = (v(x2.p1)-0.5*v(vdd))*(v(vdd) gt VU) - 0.01*(v(vdd) le VU)',
'  let dC = (v(clk)-0.5*v(vdd))*(v(vdd) gt VU) - 0.01*(v(vdd) le VU)',
'  let ok = 1']
    for n,a,b,desc in W:
        L+=[f'  * --- ventana {n} ({desc}) ---']
        for v in ['tR','tB','tP','e1','e2','gB','vR','vB']: L.append(f'  let {v}{n} = -1')
        L+=[f'  meas tran tR{n} when dR=0 rise=LAST from={a} to={b}',
            f'  meas tran vR{n} find v(vdd) when dR=0 rise=LAST from={a} to={b}',
            f'  meas tran tB{n} when dB=0 rise=1 from=$&tR{n} to={b}',
            f'  meas tran vB{n} find v(vdd) when dB=0 rise=1 from=$&tR{n} to={b}',
            f'  meas tran gB{n} when dB=0 rise=2 from={a} to={b}',
            f'  meas tran tP{n} when dP=0 rise=1 from=$&tR{n} to={b}',
            f'  meas tran e1{n} when dC=0 rise=1 from=$&tR{n} to={b}',
            f'  meas tran e2{n} when dC=0 rise=2 from=$&tR{n} to={b}',
            f'  let dl{n} = (tB{n}-e2{n})*1e9',
            f'  let dp{n} = (tP{n}-e1{n})*1e9',
            f'  let T{n} = (e2{n}-e1{n})*1e6',
            f'  let lat{n} = (tB{n}-tR{n})*1e6',
            f'  let nT{n} = lat{n}/T{n}',
            f'  let p{n} = (tR{n} gt 0)&(tB{n} gt 0)&(abs(dl{n}) le 20)&(abs(dp{n}) le 20)&(nT{n} ge 0.99)&(nT{n} le 3)&(T{n} ge 80)&(T{n} le 120)&(gB{n} lt 0)',
            f'  let ok = ok & p{n}']
    L+=['  * la caida a 0.45 V debe bajar POR_B (asercion asincronica)','  let tD = -1',
        '  meas tran tD when dB=0 fall=1 from=400u to=500u','  let pD = (tD gt 0)','  let ok = ok & pD',
        '  meas tran idd avg i(VVDD) from=600u to=800u','  let idd_ua = -idd*1e6',
        '  echo RESULT_BEGIN',
        '  print vRA vBA latA TA nTA dlA dpA pA','  print vRB vBB latB TB nTB dlB dpB pB','  print vRC vBC latC TC nTC dlC dpC pC','  print tD pD idd_ua ok',
        '  echo RESULT_END',
        '  if ok > 0.5','    echo VEREDICTO: PASS','  else','    echo VEREDICTO: FAIL','  end',
]
    if plots: L+=['  plot v(vdd) v(clk) v(por_raw_n)+1.5 v(x2.p1)+3 v(por_b)+4.5','  write wd_reset_sync_tb.raw']
    else: L+=['  set wr_singlescale','  wrdata @OUT@ v(vdd) v(clk) v(por_raw_n) v(x2.p1) v(por_b)']
    L+=['.endc']
    return '\n'.join(L)+'\n'
