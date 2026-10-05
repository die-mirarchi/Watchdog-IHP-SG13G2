#!/usr/bin/env python3
# Tool/PDK health check. Creates disposable artifacts in build/, never designs.
import json
import math
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone

root = Path('/workspace')
out = root / 'build' / 'environment-check'
out.mkdir(parents=True, exist_ok=True)
pdk = Path(os.environ['PDKPATH'])
lock = dict(line.split('=', 1) for line in (root / 'tools-config/toolchain.lock').read_text().splitlines() if line and not line.startswith('#'))
report = {'timestamp_utc': datetime.now(timezone.utc).isoformat(), 'image': os.environ['THESIS_IMAGE'], 'checks': {}, 'scope': 'Installation only; no watchdog validation, DRC or LVS signoff.'}

def run(name, args, env=None, timeout=90):
    result = subprocess.run(args, cwd=root, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=env, timeout=timeout)
    (out / f'{name}.log').write_text(result.stdout)
    if result.returncode:
        raise RuntimeError(f'{name}: exit {result.returncode}. See {out / (name + ".log")}')
    return result.stdout

try:
    assert report['image'] == lock['OSIC_IMAGE'], 'Image mismatch'
    commit = (pdk / 'COMMIT').read_text().strip()
    assert commit == lock['IHP_PDK_COMMIT'], f'PDK mismatch: {commit}'
    report['pdk_commit'] = commit
    for name in ('xschem', 'ngspice', 'klayout', 'magic', 'netgen', 'cace'):
        assert shutil.which(name), f'Missing executable: {name}'
    report['checks']['executables'] = 'PASS'
    for name, args in {'xschem': ['xschem', '--version'], 'ngspice': ['ngspice', '--version'], 'klayout': ['klayout', '-v']}.items():
        value = run(name + '-version', args, env={**os.environ, 'QT_QPA_PLATFORM': 'offscreen'})
        report[name] = value.strip().splitlines()[:3]

    tcl = out / 'check_xschem.tcl'
    tcl.write_text('''
if {![info exists THESIS_ROOT]} {error "Project xschemrc not loaded"}
foreach sym {sg13g2_pr/sg13_lv_nmos.sym sg13g2_pr/sg13_lv_pmos.sym} {
    set found 0
    foreach dir [split $XSCHEM_LIBRARY_PATH :] {
        if {[file exists [file join $dir $sym]]} {set found 1; break}
    }
    if {!$found} {error "Missing PDK symbol: $sym"}
}
set f [open /workspace/build/environment-check/xschem.ok w]
puts $f "IHP symbols and project configuration loaded"
close $f
''')
    marker = out / 'xschem.ok'
    marker.unlink(missing_ok=True)
    run('xschem', ['xschem', '-x', '-q', '--rcfile', str(root / 'xschemrc'), '--script', str(tcl)])
    assert marker.is_file(), 'Xschem configuration check did not finish'
    report['checks']['xschem_ihp_symbols'] = 'PASS'

    bench = out / 'pdk_device_smoke.spice'
    bench.write_text(f'''Installation smoke test - NOT a watchdog circuit
.lib {pdk}/libs.tech/ngspice/models/cornerMOSlv.lib mos_tt
Vd d 0 1.2
Vg g 0 1.2
Xd d g 0 0 sg13_lv_nmos w=1u l=0.13u ng=1 m=1
.control
op
let idrain = -i(Vd)
print idrain
quit
.endc
.end
''')
    log = run('ngspice', ['ngspice', '-b', str(bench)])
    assert not re.search(r'(?im)^\s*(?:error|fatal)\b', log), 'ngspice reported an error'
    match = re.search(r'idrain\s*=\s*([+\-\d.eE]+)', log)
    assert match, 'No transistor operating point in output'
    current = float(match.group(1))
    assert math.isfinite(current) and 1e-7 < current < .1, f'Unexpected NMOS current: {current}'
    report['checks']['ngspice_ihp_osdi'] = 'PASS'
    report['nmos_smoke_current_A'] = current

    macro = out / 'check_klayout.py'
    macro.write_text('''import pya
from pathlib import Path
t = pya.Technology()
t.load('/foss/pdks/ihp-sg13g2/libs.tech/klayout/tech/sg13g2.lyt')
assert t.name
import sg13g2_pycell_lib
libraries = pya.Library.library_names()
assert any('sg13' in x.lower() for x in libraries), libraries
Path('/workspace/build/environment-check/klayout.ok').write_text(str(libraries))
''')
    marker = out / 'klayout.ok'
    marker.unlink(missing_ok=True)
    run('klayout', ['klayout', '-b', '-r', str(macro)], env={**os.environ, 'QT_QPA_PLATFORM': 'offscreen'})
    assert marker.is_file(), 'KLayout technology/PCells check did not finish'
    report['checks']['klayout_ihp_technology_pcells'] = 'PASS'
    for rel in ('libs.tech/klayout/tech/drc/ihp-sg13g2.drc', 'libs.tech/klayout/tech/lvs/sg13g2.lvs'):
        assert (pdk / rel).is_file(), f'Missing rule deck {rel}'
    report['checks']['drc_lvs_decks_present'] = 'PASS (not run: no layout exists)'
    report['status'] = 'PASS'
except Exception as exc:
    report['status'] = 'FAIL'
    report['error'] = str(exc)
finally:
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))
sys.exit(0 if report['status'] == 'PASS' else 1)
