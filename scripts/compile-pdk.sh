#!/usr/bin/env bash
set -euo pipefail
cd "$PDKPATH/libs.tech/verilog-a"
bash -e openvaf-compile-va.sh --compile-model-generic
for model in psp103 psp103_nqs r3_cmc mosvar cap_cmomi cap_cmomf; do
    test -s "../ngspice/osdi/$model.osdi"
done
